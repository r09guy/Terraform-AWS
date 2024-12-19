#All about Security
# Security Group ------------------------------------------------------------------------------------------------------------------------
# Update EC2 Instance Security Group
resource "aws_security_group" "Terraform-SG" {
  vpc_id = aws_vpc.Terraform-VPC-test.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP traffic
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH traffic
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow MySQL traffic
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"] # Allow ping (ICMP) traffic
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "Terraform-SG"
  }
}

# IAM Role for Lambda --------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_role" {
  name               = "terraform-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "LambdaRole"
  }
}

# IAM Policy for Lambda to interact with S3
resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "lambda-s3-policy"
  description = "Allow Lambda to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:PutObject", "s3:GetObject"]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.Terraform-Bucket.arn}/*"
      }
    ]
  })
}

# Attach the policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_iam_role" "terraform_role" {
  name = "terraform-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

#S3 Security Group--------------------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "terraform_s3_policy" {
  name        = "TerraformS3Policy"
  description = "S3 permissions for Terraform"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::r0938274-terraform-file-upload-bucket",
          "arn:aws:s3:::r0938274-terraform-file-upload-bucket/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  policy_arn = aws_iam_policy.terraform_s3_policy.arn
  role       = aws_iam_role.terraform_role.name
}

resource "aws_iam_instance_profile" "terraform_instance_profile" {
  name = "terraform-instance-profile"
  role = aws_iam_role.terraform_role.name
}


#EFS Security Group--------------------------------------------------------------------------------------------------------------------------------
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

#Mustafa Karabayir