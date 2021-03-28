#!/bin/bash
yum install mariadb-server -y
systemctl start mariadb
systemctl enable mariadb

mysql --user=root <<EOF
UPDATE mysql.user SET Password=PASSWORD('itsme@2020') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

mysql -u root -pitsme@2020 -e "create database ${db_name};create user '${db_user}'@'%' identified by '${db_pass}';grant all on ${db_name}.* to '${db_user}'@'%';flush privileges;" 
