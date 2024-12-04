#!/bin/bash

sudo apt-get update -y
sudo apt update -y
sudo apt install fontconfig openjdk-17-jre -y


sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Print Jenkins initial admin password location
echo "Jenkins installation complete. Access Jenkins at port 8080."
echo "To configure Jenkins, retrieve the initial admin password from:"
echo "/var/lib/jenkins/secrets/initialAdminPassword"
