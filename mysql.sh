#!/bin/bash

sudo apt update -y
sudo apt install mysql-server -y
sudo systemctl start mysql-server
sudo systemctl enable mysql

