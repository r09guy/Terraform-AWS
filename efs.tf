resource "aws_efs_file_system" "terraform_efs" {
  creation_token = "terraform-efs"

  tags = {
    Name = "Terraform-EFS"
  }
}

resource "aws_security_group" "terraform_efs_sg" {
  vpc_id = aws_vpc.Terraform-VPC-test.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EFS-Security-Group"
  }
}

resource "aws_efs_mount_target" "subnet1_mount_target" {
  file_system_id   = aws_efs_file_system.terraform_efs.id
  subnet_id        = aws_subnet.subnet1.id
  security_groups  = [aws_security_group.terraform_efs_sg.id]
}

resource "aws_efs_mount_target" "subnet2_mount_target" {
  file_system_id   = aws_efs_file_system.terraform_efs.id
  subnet_id        = aws_subnet.subnet2.id
  security_groups  = [aws_security_group.terraform_efs_sg.id]
}

