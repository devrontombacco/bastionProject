
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {

   region = "eu-west-1"
   shared_credentials_files = ["/home/devron/.aws/credentials"]

}

# Create main VPC
resource "aws_vpc" "main_vpc" {

    cidr_block = "12.0.0.0/16"
        tags = {
            Name = "main_vpc"
        }
}

# Create IGW 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "igw"
  }
}

# Create Public Subnet 
resource "aws_subnet" "public_subnet_1A" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "12.0.1.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_1A"
  }

}

# Create Private Subnet 
resource "aws_subnet" "private_subnet_1A" {

  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "12.0.2.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet_1A"
  }

}

# Create Route Table for Public Subnet
resource "aws_route_table" "route_table_public" {

  vpc_id = "${aws_vpc.main_vpc.id}"

  tags = {
    Name = "route_table_public"
  }

}

# Associate Public Route Table with Public Subnet
resource "aws_route_table_association" "public_route_table_association" {

  subnet_id      = aws_subnet.public_subnet_1A.id
  route_table_id = aws_route_table.route_table_public.id

}


# Create Route Table for Private Subnet
resource "aws_route_table" "route_table_private" {

  vpc_id = "${aws_vpc.main_vpc.id}"

  tags = {
    Name = "route_table_private"
  }

}

# Associate Private Route Table with Private Subnet
resource "aws_route_table_association" "private_route_table_association" {

  subnet_id      = aws_subnet.private_subnet_1A.id
  route_table_id = aws_route_table.route_table_private.id
  
}

# Insert Route into Public RT
resource "aws_route" "internet_access" {
    
  route_table_id         = aws_route_table.route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

}


# Create EC2 instance in public subnet
resource "aws_instance" "ec2_public_bastion" {

  ami           = "ami-0df368112825f8d8f"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1A.id

  tags = {
    Name = "ec2_public_bastion"
  }
  #security_groups  = [aws_security_group.web_sg.name]
  key_name        = "MY_EC2_INSTANCE_KEYPAIR"

}

# Create EC2 instance in private subnet
resource "aws_instance" "ec2_private" {

  ami           = "ami-0df368112825f8d8f"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet_1A.id

  tags = {
    Name = "ec2_private"
  }
  #security_groups  = [aws_security_group.web_sg.name]
  key_name        = "MY_EC2_INSTANCE_KEYPAIR"

}