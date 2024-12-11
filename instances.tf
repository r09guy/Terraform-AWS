# Apache2 Webserver
resource "aws_instance" "Terraform-Apache" {
  ami           = "ami-0d64bb532e0502c46" # Ubuntu AMI (Ireland)
  instance_type = "t2.micro"               # Free tier
  subnet_id     = aws_subnet.subnet1.id
  key_name      = aws_key_pair.terraform_key.key_name
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

# API Server
resource "aws_instance" "Terraform-API" {
  ami           = "ami-0d64bb532e0502c46" # Ubuntu AMI (Ireland)
  instance_type = "t2.micro"               # Free tier
  subnet_id     = aws_subnet.subnet1.id
  key_name      = aws_key_pair.terraform_key.key_name

  tags = {
    Name = "API-Server"
  }
  user_data = file("scripts/ansible.sh")
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
  key_name      = aws_key_pair.terraform_key.key_name
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
  key_name      = aws_key_pair.terraform_key.key_name

  tags = {
    Name = "MountClient1-Server"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y nfs-common
              sudo mkdir /mnt/efs
              sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.terraform_efs.dns_name}:/ /mnt/efs
              sudo touch /mnt/efs/hallo-1
              
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
  key_name      = aws_key_pair.terraform_key.key_name

  tags = {
    Name = "MountClient2-Server"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y nfs-common
              sudo mkdir /mnt/efs
              sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.terraform_efs.dns_name}:/ /mnt/efs
              sudo touch /mnt/efs/hallo-2
              
              EOF

  vpc_security_group_ids = [aws_security_group.Terraform-SG.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
}


