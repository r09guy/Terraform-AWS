# Networking ----------------------------------------------------------------------------------------------------------------------------
# Create VPC with IP address 10.0.0.0/16
resource "aws_vpc" "Terraform-VPC-test" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Terraform-VPC"
  }
}

# Subnets ----------------------------------------------------------------------------------------------------------------------------
# Create Subnet 1
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.Terraform-VPC-test.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Terraform-subnet-1"
  }
}

# Create Subnet 2
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.Terraform-VPC-test.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "Terraform-subnet-2"
  }
}

# Internet Gateway -------------------------------------------------------------------------------------------------------------------
resource "aws_internet_gateway" "Terraform-IGW" {
  vpc_id = aws_vpc.Terraform-VPC-test.id

  tags = {
    Name = "Terraform-IGW"
  }
}

# Route Table ------------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "Terraform-RT" {
  vpc_id = aws_vpc.Terraform-VPC-test.id

  tags = {
    Name = "Terraform-RouteTable"
  }
}

# Route for Internet Access
resource "aws_route" "InternetAccess" {
  route_table_id         = aws_route_table.Terraform-RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.Terraform-IGW.id
}

# Associate Route Table with Subnet 1
resource "aws_route_table_association" "Subnet1Association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.Terraform-RT.id
}

# SSH Key Pair for EC2 instances---------------------------------------------------------------------------------------------------------------------------------------------------
#resource "aws_key_pair" "terraform_key" {
#  key_name   = "terraform-key"
#  public_key = file("C:/Users/musta/.ssh/id_rsa.pub") # Path to the public key file on your system
#
#  tags = {    Name = "Terraform-Key"
#  }
#}
resource "tls_private_key" "Terraform-PrivateKey" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "keypair" {
  key_name = "terraform-keypair"
  public_key = tls_private_key.Terraform-PrivateKey.public_key_openssh
}