#!/bin/bash

sudo apt-get update -y
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get update -y
sudo apt-get install -y ansible
