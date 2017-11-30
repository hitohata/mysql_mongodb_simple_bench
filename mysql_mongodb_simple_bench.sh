#!/usr/bin/bash

echo -e "Do you want to create test JSON data ? please select number.\n"

select VAR in yes no exit
do
  case $VAR in
  
  "yes" )
  echo -e "\nyou need 'dummy-json' package for creating data. Have you already installed it ?"
  echo "check: https://github.com/webroo/dummy-json"
  echo -e "And please put 'json-schema.hbs' under /tmp/\n"

  echo "[how to install in CentOS]"
  echo "# curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -"
  echo "# yum -y install nodejs"
  echo -e "# npm install -g dummy-json\n"
  
  select VAR2 in yes no exit
  do
    case $VAR2 in
  
    "yes" )
    dummyjson /tmp/json-templete.hbs > /tmp/sample_data.json
    sed -i '$d' /tmp/sample_data.json
    echo "finished creating test data"
    break;;
    
    "no" )
    echo "please install by above steps."
    exit;;
    
    * )
    echo "please input again";;
    
    esac
  done
  break;;
  
  "no" )
  echo "OK, skip creating test data."
  break;;
  
  "exit" )
  echo "Exit from script."
  exit;;
  
  * )
  echo "please input again";;
  
  esac
done

echo "1) MySQL(JSON on InnoDB)"
echo "2) MongoDB"
echo "3) exit from script"

echo "Please select number for your DB: "
while :
do
    read -p: VAR 
    case "$VAR" in
     
     1 ) 
     echo "You need to set secure_file_priv='/tmp' in your my.cnf"
     
     echo "Target DB is MySQL(JSON on InnoDB)"
     echo "please input username"
     read user
     echo "please input password"
     read password
     
     mysql -u$user -p$password d1 -e "CREATE TABLE IF NOT EXISTS bench (id INT auto_increment primary key, col1 JSON)"
     mysql -u$user -p$password d1 -e "DELETE FROM bench"
     sleep 5s
     
     systemctl stop mysqld
     sync
     echo 3 > /proc/sys/vm/drop_caches
     sleep 5s
     systemctl start mysqld
     sleep 5s
     
     echo "INSERT bench" > /tmp/mysql_bench_result.log
     ( time mysql -u$user -p$password d1 -e "LOAD DATA INFILE '/tmp/sample_data.json' INTO TABLE bench(col1)" ) >> /tmp/mysql_bench_result.log 2>&1
     
     echo "SELECT bench" >> /tmp/mysql_bench_result.log
     ( time mysql -u$user -p$password d1 -e "SELECT count(*) FROM bench WHERE JSON_EXTRACT(col1,'$.nation') = 'Japan'" ) >> /tmp/mysql_bench_result.log 2>&1

### In other word, "SELECT count(*) FROM bench WHERE col1->'$.nation' = 'Japan'"

     echo "UPDATE bench" >> /tmp/mysql_bench_result.log
     ( time mysql -u$user -p$password d1 -e "UPDATE bench SET col1 = JSON_SET(col1, '$.phone', '000-000-0000') WHERE JSON_UNQUOTE( JSON_EXTRACT(col1,'$.phone') ) LIKE '080%'" ) >> /tmp/mysql_bench_result.log 2>&1

### In other word, "UPDATE bench SET col1 = JSON_SET(col1, '$.phone', '000-000-0000') WHERE col1->>'$.phone' LIKE '080%'"

     echo "DELETE bench" >> /tmp/mysql_bench_result.log
     ( time mysql -u$user -p$password d1 -e "DELETE FROM bench WHERE JSON_EXTRACT(col1,'$.birth') >= '1990-01-01'" ) >> /tmp/mysql_bench_result.log 2>&1

### In other word, "DELETE FROM bench WHERE col1->'$.birth' >= '1990-01-01'"

     echo "test finished"
     exit;;
     
     
     2 ) 
     echo "Target DB is MongoDB"
    
     echo 'db.bench.drop()' | mongo d1
     echo 'db.dropDatabase()' | mongo d1 
     sleep 5s
 
     systemctl stop mongod
     sync
     echo 3 > /proc/sys/vm/drop_caches
     sleep 5s
     systemctl start mongod
     sleep 5s
     
     echo 'use d1' | mongo
     echo 'db.createCollection(`bench`)' | mongo d1

     echo "INSERT bench" > /tmp/mongodb_bench_result.log
     ( time mongoimport --db d1 --collection bench --file /tmp/sample_data.json ) >> /tmp/mongodb_bench_result.log 2>&1
     
     echo "SELECT bench" >> /tmp/mongodb_bench_result.log
     ( time echo 'db.bench.count( { nation : "Japan"} )' | mongo d1 ) >> /tmp/mongodb_bench_result.log 2>&1
     
     echo "UPDATE bench" >> /tmp/mongodb_bench_result.log
     ( time echo 'db.bench.updateMany( { phone : /^080/ } , { $set : { phone : 000-000-0000 } } )' | mongo d1 ) >> /tmp/mongodb_bench_result.log 2>&1
     
     echo "DELETE bench" >> /tmp/mongodb_bench_result.log
     ( time echo 'db.bench.deleteMany( { birth : { $gte : "1990-01-01" } } )' | mongo d1 ) >> /tmp/mongodb_bench_result.log 2>&1
     
     echo "test finished"
     exit;;
     
     
     3 ) 
     echo "Exit from script."
     exit;;
     
     
     * ) 
     echo "please input again";;
     
   esac
done
