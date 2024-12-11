#!/bin/bash

sudo apt update -y
sudo apt install apache2 -y
sudo systemctl start apache2
sudo systemctl enable apache2
sudo apt install php libapache2-mod-php php-mysql -y
sudo apt install mysql-server -y
sudo systemctl start mysql
sudo systemctl enable mysql

sudo apt-get install -y nfs-common
sudo mkdir /mnt/efs

sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
sudo unzip awscliv2.zip
sudo ./aws/install


sudo mkdir  /var/www/html/webpages
sudo mkdir  /var/www/html/php

sudo rm /var/www/html/index.html
echo "<h1>Apache is Running</h1>" | sudo tee /var/www/html/webpages/index.html
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php
echo "<?php echo '<h1>Apache with PHP is Running</h1>'; ?>" | sudo tee /var/www/html/php/index.php

sudo chmod 777 /var/www/html/webpages/
sudo chmod 777 /var/www/html/

sudo aws s3 sync s3://r0938274-terraform-file-upload-bucket /var/www/html/

echo '#!/bin/bash' | sudo tee /home/ubuntu/s3-loop.sh
echo "while true; do" | sudo tee -a /home/ubuntu/s3-loop.sh
echo "  sudo aws s3 sync s3://r0938274-terraform-file-upload-bucket /var/www/html/" | sudo tee -a /home/ubuntu/s3-loop.sh

echo "  for file in /var/www/html/*; do" | sudo tee -a /home/ubuntu/s3-loop.sh
echo "    if [[ -f \"\$file\" ]]; then" | sudo tee -a /home/ubuntu/s3-loop.sh
echo "      if [[ \$(file \"\$file\") == *\"ASCII text\"* ]] && [[ \$(cat \"\$file\" | grep -E '^[A-Za-z0-9+/=]*\$') ]]; then" | sudo tee -a /home/ubuntu/s3-loop.sh
echo "        echo \"Decoding Base64 file: \$file\"" | sudo tee -a /home/ubuntu/s3-loop.sh
echo "        base64 --decode \"\$file\" > \"\$file.decoded\"" | sudo tee -a /home/ubuntu/s3-loop.sh
echo "        mv \"\$file.decoded\" \"\$file\"" | sudo tee -a /home/ubuntu/s3-loop.sh
echo "        for filename in \$(ls -1 /var/www/html); do mysql -u remote -premote -h 10.0.1.31 -e \"USE files; INSERT INTO file (name) VALUES ('\$filename');\"; done" > /home/ubuntu/sqlInsert.sh
echo "      fi" | sudo tee -a /home/ubuntu/s3-loop.sh
echo "    fi" | sudo tee -a /home/ubuntu/s3-loop.sh
echo "  done" | sudo tee -a /home/ubuntu/s3-loop.sh


echo "done" | sudo tee -a /home/ubuntu/s3-loop.sh

sudo chmod 777 /home/ubuntu/s3-loop.sh
sudo nohup /home/ubuntu/s3-loop.sh &
sudo cd /home/ubuntu
sleep 5
sudo ./s3-loop.sh &


#sudo mysql -h 10.0.1.31 -u remote -premote
sleep 10
 
echo "* * * * * root sudo aws s3 sync s3://r0938274-terraform-file-upload-bucket /var/www/html" >> /etc/crontab

echo "for filename in \$(ls -1 /var/www/html); do mysql -u remote -premote -h 10.0.1.31 -e \"USE files; INSERT INTO file (name) VALUES ('\$filename');\"; done" > /home/ubuntu/sqlInsert.sh
sudo chmod 755 /home/ubuntu/sqlInsert.sh
echo "* * * * * root sudo /home/ubuntu/sqlInsert.sh" >> /etc/crontab