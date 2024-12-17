# Apache2 Webserver
resource "aws_instance" "Terraform-Apache" {
  count = 2
  ami           = "ami-0d64bb532e0502c46" # Ubuntu AMI (Ireland)
  instance_type = "t2.micro"               # Free tier
  subnet_id     = aws_subnet.subnet1.id
  #key_name      = aws_key_pair.terraform_key.key_name
  key_name = "terraform-keypair"
  iam_instance_profile   = aws_iam_instance_profile.terraform_instance_profile.name

  tags = {
    Name = "Apache-Webserver"
  }
  user_data = file("scripts/apache.sh")
  vpc_security_group_ids = [aws_security_group.Terraform-SG.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
}

# Ansible Server 
resource "aws_instance" "Terraform-AnsibleServer" {
  ami           = "ami-0d64bb532e0502c46" # Ubuntu AMI (Ireland)
  instance_type = "t2.micro"               # Free tier
  subnet_id     = aws_subnet.subnet1.id
  #key_name      = aws_key_pair.terraform_key.key_name
  key_name = "terraform-keypair"
  private_ip = "10.0.1.50"

  tags = {
    Name = "Ansible-Server"
  }
  user_data = file("scripts/aserver.sh")
  vpc_security_group_ids = [aws_security_group.Terraform-SG.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
}

# Ansible Client 1
resource "aws_instance" "Terraform-AnsibleClient1" {
  ami           = "ami-0d64bb532e0502c46" # Ubuntu AMI (Ireland)
  instance_type = "t2.micro"               # Free tier
  subnet_id     = aws_subnet.subnet1.id
  #key_name      = aws_key_pair.terraform_key.key_name
  key_name = "terraform-keypair"
  private_ip = "10.0.1.51"

  tags = {
    Name = "Ansible-Client-1"
  }
  user_data = file("scripts/aclient.sh")
  vpc_security_group_ids = [aws_security_group.Terraform-SG.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
}

# Ansible Client 2
resource "aws_instance" "Terraform-AnsibleClient2" {
  ami           = "ami-0d64bb532e0502c46" # Ubuntu AMI (Ireland)
  instance_type = "t2.micro"               # Free tier
  subnet_id     = aws_subnet.subnet1.id
  #key_name      = aws_key_pair.terraform_key.key_name
  key_name = "terraform-keypair"
  private_ip = "10.0.1.52"

  tags = {
    Name = "Ansible-Client-2"
  }
  user_data = file("scripts/aclient.sh")
  vpc_security_group_ids = [aws_security_group.Terraform-SG.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
}

# MySQL Server
resource "aws_instance" "Terraform-MySql" {
  ami           = "ami-0d64bb532e0502c46" # Ubuntu AMI (Ireland)
  instance_type = "t2.micro"               # Free tier
  subnet_id     = aws_subnet.subnet1.id
  #key_name      = aws_key_pair.terraform_key.key_name
  key_name = "terraform-keypair"
  private_ip = "10.0.1.31"

  tags = {
    Name = "MySql-Server"
  }
  user_data = file("scripts/mysql.sh")
  vpc_security_group_ids = [aws_security_group.Terraform-SG.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
}

# Mount Client 1 Web-Server
resource "aws_instance" "Terraform-MountClient1" {
  ami           = "ami-0d64bb532e0502c46" # Ubuntu AMI (Ireland)
  instance_type = "t2.micro"               # Free tier
  subnet_id     = aws_subnet.subnet1.id
  #key_name      = aws_key_pair.terraform_key.key_name
  key_name = "terraform-keypair"

  tags = {
    Name = "MountClient1-Server"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo systemctl enable apache2 
              sudo apt-get install -y nfs-common
              sudo mkdir /mnt/efs
              sudo chmod 777 /mnt/
              sudo chmod 777 /mnt/efs
              sudo chmod 777 /mnt/efs/index.html
              sleep 200
              sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.terraform_efs.dns_name}:/ /mnt/efs
              sudo touch /mnt/efs/index.html
              echo "<h1>Welcome to the EFS Apache Web Server!</h1>" | sudo tee /mnt/efs/index.html
              sudo rm -rf /var/www/html
              sudo sed -i 's|DocumentRoot /var/www/html|DocumentRoot /mnt/efs|g' /etc/apache2/sites-available/000-default.conf
              echo 's|/var/www|/mnt/efs|g' > sed.sed
              sudo sed -f sed.sed /etc/apache2/apache2.conf -i
              sudo systemctl restart apache2
              
              EOF
  vpc_security_group_ids = [aws_security_group.Terraform-SG.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
}

# Mount Client 2 Web-Server
resource "aws_instance" "Terraform-MountClient2" {
  ami           = "ami-0d64bb532e0502c46" # Ubuntu AMI (Ireland)
  instance_type = "t2.micro"               # Free tier
  subnet_id     = aws_subnet.subnet1.id
  #key_name      = aws_key_pair.terraform_key.key_name
  key_name = "terraform-keypair"

  tags = {
    Name = "MountClient2-Server"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo systemctl enable apache2 
              sudo apt-get install -y nfs-common
              sudo mkdir /mnt/efs
              sudo chmod 777 /mnt/
              sudo chmod 777 /mnt/efs
              sudo chmod 777 /mnt/efs/index.html
              sleep 200
              sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.terraform_efs.dns_name}:/ /mnt/efs
              sudo touch /mnt/efs/user.txt
              echo "Top Secret" >> /mnt/efs/user.txt
              sudo rm -rf /var/www/html/
              sudo sed -i 's|DocumentRoot /var/www/html|DocumentRoot /mnt/efs|g' /etc/apache2/sites-available/000-default.conf
              echo 's|/var/www|/mnt/efs|g' > sed.sed
              sudo sed -f sed.sed /etc/apache2/apache2.conf -i
              sudo systemctl restart apache2
              
              EOF

  vpc_security_group_ids = [aws_security_group.Terraform-SG.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
}

output "sql" {
  value = "sudo mysql -h 10.0.1.31 -u remote -premote -e 'SELECT * FROM files.file'"
}


