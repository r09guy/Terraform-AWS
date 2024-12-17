#!/bin/bash

sudo apt-get update -y
sudo apt install ansible -y
sleep 300
sudo curl http://10.0.1.50 >> /home/ubuntu/.ssh/authorized_keys
touch /home/ubuntu/script.sh
sudo chmod 777 /home/ubuntu/script.sh

echo "#!/bin/bash" | sudo tee -a /home/ubuntu/script.sh
echo "for i in {1..10}; do" | sudo tee -a /home/ubuntu/script.sh
echo "    sudo curl http://10.0.1.50 >> /home/ubuntu/.ssh/authorized_keys" | sudo tee -a /home/ubuntu/script.sh
echo "    sleep 10" | sudo tee -a /home/ubuntu/script.sh
echo "done" | sudo tee -a /home/ubuntu/script.sh

sudo ./home/ubuntu/script.sh &