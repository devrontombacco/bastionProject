
variable "vpc_cidr_block" {
    type = string
    description = "Main VPC CIDR Block"
}

variable "public_subnet_cidr_block" {
    type = string
    description = "Public Subnet's CIDR Block"
}

variable "private_subnet_cidr_block" {
    type = string
    description = "Private Subnet's CIDR Block"
}

variable "availability_zone" {
    type = string
    description = "AZ of subnets and EC2 instances"
}

variable "keypair_name" {
    type = string
    description = "KeyPair for SSH-ing into EC2"
}

