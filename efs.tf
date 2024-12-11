# Declare the AWS region data source
data "aws_region" "current" {}

resource "aws_efs_file_system" "terraform_efs" {
  creation_token = "terraform-efs"

  tags = {
    Name = "Terraform-EFS"
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

