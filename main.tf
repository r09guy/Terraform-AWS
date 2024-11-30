#Networking-------------------------------------------------------------------------------------------------------------------------------------------
# Create VPC with IP address 10.0.0.0/16
resource "aws_vpc" "Terraform-VPC-test" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Terraform-VPC-test"
  }
}


#Subnets-------------------------------------------------------------------------------------------------------------------------------------------
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

# Internet Gateway------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_internet_gateway" "Terraform-IGW" {
  vpc_id = aws_vpc.Terraform-VPC-test.id

  tags = {
    Name = "Terraform-IGW"
  }
}

# Route Table------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "Terraform-RT" {
  vpc_id = aws_vpc.Terraform-VPC-test.id

  tags = {
    Name = "Terraform-RouteTable"
  }
}


# Route for Internet Access------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_route" "InternetAccess" {
  route_table_id         = aws_route_table.Terraform-RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.Terraform-IGW.id
}



# Associate Route Table with Subnet 1----------------------------------------------------------------------------------------------------------------
resource "aws_route_table_association" "Subnet1Association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.Terraform-RT.id
}



#Security Group------------------------------------------------------------------------------------------------------------------------------------
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


# Create a new SSH Key Pair for EC2 instances
resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-key"                      # Name for the new key pair
  public_key = file("~/.ssh/id_rsa.pub")            # Path to the public key file on my pc

  tags = {
    Name = "Terraform-Key"
  }
}


#VMs---------------------------------------------------------------------------------------------------------------------------------------
#Apache2 webserver
resource "aws_instance" "Terraform-Apache" {
  ami           = "ami-0d64bb532e0502c46"                   #Ubuntu AMI(image) for Ireland
  instance_type = "t2.micro"                                #From the Free tier
  subnet_id     = aws_subnet.subnet1.id                     #Put it to a subnet 
  key_name = aws_key_pair.terraform_key.key_name

  tags = {
    Name = "Apache-Webserver"
  }
  user_data = file("apache.sh")
  vpc_security_group_ids = [aws_security_group.Terraform-SG.id]

  
   metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
}

#API server
resource "aws_instance" "Terraform-API" {
  ami           = "ami-0d64bb532e0502c46"                   #Ubuntu AMI(image) for Ireland
  instance_type = "t2.micro"                                #From the Free tier
  subnet_id     = aws_subnet.subnet1.id
  key_name = aws_key_pair.terraform_key.key_name

  tags = {
    Name = "API-Server"
  }
  user_data = file("apache.sh")
  vpc_security_group_ids = [aws_security_group.Terraform-SG.id]

   metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
}

#MySql webserver
resource "aws_instance" "Terraform-MySql" {
  ami           = "ami-0d64bb532e0502c46"                   #Ubuntu AMI(image) for Ireland
  instance_type = "t2.micro"                                #From the Free tier
  subnet_id     = aws_subnet.subnet1.id
  key_name = aws_key_pair.terraform_key.key_name

  tags = {
    Name = "MySql-Server"
  }
  user_data = file("mysql.sh")
  vpc_security_group_ids = [aws_security_group.Terraform-SG.id]

   metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
}