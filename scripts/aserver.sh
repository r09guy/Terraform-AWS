#!/bin/bash

sudo apt-get update -y
sudo apt install ansible -y
sudo apt install apache2 -y
sudo systemctl start apache2
sudo systemctl enable apache2
sudo mkdir /etc/ansible
sudo touch /etc/ansible/hosts
echo "[webservers]" | sudo tee -a /etc/ansible/hosts
echo "10.0.1.51" | sudo tee -a /etc/ansible/hosts
echo "10.0.1.52" | sudo tee -a /etc/ansible/hosts
sleep 10
sudo -u ubuntu ssh-keygen -t rsa -b 2048 -f /home/ubuntu/.ssh/id_rsa -N "" -q
chmod 777 /var/www/html/
chmod 777 /var/www/html/index.html
sudo cat /home/ubuntu/.ssh/id_rsa.pub > /var/www/html/index.html

sleep 10

ansible webservers -m file -a "path=/home/ubuntu/ansible.txt state=touch"
ansible webservers -m copy -a "content='Hello from Ansible' dest=/home/ubuntu/ansible.txt"

