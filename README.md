# mysql_mongodb_simple_bench
This is shell script for simple benchmark test of MySQL and MongoDB.
It is assumed only CentOS and MySQL5.7 !

# How to use

## 1. install MongoDB and MySQL5.7 by yum repository

## 2. install dummy-json command (ref. https://github.com/webroo/dummy-json)

    # curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -
    # yum -y install nodejs
    # npm install dummy-json

## 3. move "json-templete.hbs" under /tmp/

    # mv ./json-templete.hbs /tmp/

## 4. execute "mysql_mongodb_simple_bench"

    # ./mysql_mongodb_simple_bench
    
## 5. create test data -> please input "1" (it mean "yes")

## 6. select the target to do benchmark ("1" = MySQL / "2" = MongoDB)

