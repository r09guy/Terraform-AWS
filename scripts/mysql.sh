#!/bin/bash

sudo apt update -y
sudo apt install mysql-server -y
sudo systemctl start mysql
sudo systemctl enable mysql

sudo mysql -u root -psecret -e "CREATE USER 'remote'@'%' IDENTIFIED BY 'remote';" >> /home/ubuntu/mysql.sh
sudo mysql -u root -psecret -e  "GRANT ALL PRIVILEGES ON *.* TO 'remote'@'%' WITH GRANT OPTION;" >> /home/ubuntu/mysql.sh
sudo sleep 10
sudo mysql -u root -psecret -e  "FLUSH PRIVILEGES;" >> /home/ubuntu/mysql.sh

sudo mysql -u root -psecret -e "CREATE DATABASE IF NOT EXISTS files;"
sleep 10
sudo mysql -u root -psecret -e "USE files; CREATE TABLE IF NOT EXISTS file (name VARCHAR(255) PRIMARY KEY);"

sudo sed -i 's/^bind-address.*$/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql.service 
