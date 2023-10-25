# RDS
For creating database because we don't have access to the cloud panel we use docker:
```
docker run –name mysqldb -d -p 0.0.0.0:3306:3306 -e MYSQL_ROOT_PASSWORD=123 mysql
```
After spinning up database we set the settings on it:
```
docker exec -it mysqldb mysql -u root -p
<Enter the root pasword>

###
> CREATE USER admin@'%' identified by 'Skills53';
> GRANT ALL PRIVILEGES ON *.* TO admin@'%';
> FLUSH PRIVILEGES;
> exit;
```
# apisrv_1
Install package For connecting to the db:
```
apt install mysql-client
```
After install connect to db and do the followings:
```
mysql -u admin -h <ip-mysql> -P 3306 -p
<Enter password>

###
> CREATE DATABASE dataset;
> USE dataset;
> CREATE TABLE INFO (name varchar(10), emaill varchar(30), password varchar(20));
> exit;
```

# ElastiCache
`ElastiCache Directory`

# Continue to apisrv_1
`production_application Directory` 
