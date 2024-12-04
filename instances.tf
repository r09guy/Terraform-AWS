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
  user_data = file("scripts/efs.sh")
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