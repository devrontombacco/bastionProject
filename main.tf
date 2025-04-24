
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


# Create Route Table for Private Subnet
resource "aws_route_table" "route_table_private" {

  vpc_id = "${aws_vpc.main_vpc.id}"

  tags = {
    Name = "route_table_private"
  }

}