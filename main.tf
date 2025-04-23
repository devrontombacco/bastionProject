
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
