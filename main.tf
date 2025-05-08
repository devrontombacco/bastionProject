
# Create main VPC
resource "aws_vpc" "main_vpc" {

    cidr_block = var.vpc_cidr_block
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
  cidr_block = var.public_subnet_cidr_block
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_1A"
  }

}

# Create Private Subnet 
resource "aws_subnet" "private_subnet_1A" {

  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_cidr_block
  availability_zone = var.availability_zone
  
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

# Dynamically create Ubuntu AMI for EC2
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Create EC2 instance in public subnet
resource "aws_instance" "ec2_public_bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  availability_zone = var.availability_zone
  subnet_id         = aws_subnet.public_subnet_1A.id
  key_name          = var.keypair_name

  tags = {
    Name = "ec2_public_bastion"
  }
  vpc_security_group_ids = [aws_security_group.public_ec2_sg.id]

  user_data = <<-EOF
  #!/bin/bash
  yes | sudo apt update 
  yes | sudo apt install apache2
  echo "<h1>Server Details</h1><p><strong>Hostname:</strong> $(hostname)</p><p><strong>IP Address:</strong>$(hostname -I | cut -d" " -f1)</strong></p>"> /var/www/html/index.html
  sudo systemctl restart apache2
  EOF 

}


# Create EC2 instance in private subnet
resource "aws_instance" "ec2_private" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet_1A.id

  tags = {
    Name = "ec2_private"
  }
  vpc_security_group_ids = [aws_security_group.private_ec2_sg.id]
  key_name        = "MY_EC2_INSTANCE_KEYPAIR"

}

#Create env var for my ip address 

variable "my_ip_address" {
  type    = string
  default = "0.0.0.0/0" # fallback IP
}

# Create Security Group for public ec2

resource "aws_security_group" "public_ec2_sg" {
  name        = "public_ec2_sg"
  description = "Allow inbound traffic on ports 22 and 80"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_address]
  }

  ingress {
    description = "allow http traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_address]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allows all outbound traffic
  }
}

# Create Security Group for private ec2

resource "aws_security_group" "private_ec2_sg" {
  name        = "private_ec2_sg"
  description = "Allow inbound traffic on port 22"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "allow SSH traffic"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_ec2_sg.id]
  }

  ingress {
    description = "allow http traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.public_ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allows all outbound traffic
  }
}