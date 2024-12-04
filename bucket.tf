resource "aws_s3_bucket" "Terraform-Bucket" {
  bucket = "r0938274-terraform-file-upload-bucket"
  acl    = "private"

  tags = {
    Name = "Terraform-Bucket"
  }
}