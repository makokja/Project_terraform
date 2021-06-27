terraform {
  required_providers{
      aws = {
          source = "hashicorp/aws"
          version = "~>3.0"
      }
  }
}
#configured the aws provider
provider "aws" {
    region     = "ap-southeast-1" 
}

#create a VPC
resource "aws_vpc" "Project-VPC" {
    cidr_block = "172.20.0.0/16"
    tags = {
        Name = "Project-VPC"
    }
}

# Create subnet (public)
resource "aws_subnet" "Project-Subnet1" {
    vpc_id = aws_vpc.Project-VPC.id
    cidr_block = "172.20.10.0/24"
    tags = {
      "Name" = "Project-Subnet1"
    }
}
#create Internet Gateway

resource "aws_internet_gateway" "Project-IntGW" {
    vpc_id = aws_vpc.Project-VPC.id
    tags = {
        Name = "Project-IntGW"
    }
}

#create Secerity Group

resource "aws_security_group" "Project_Sec_Group" {
    name = "My Project Security Group"
    description = "To allow inbound and outbound traffic to my project"
    vpc_id = aws_vpc.Project-VPC.id
    ingress {
        from_port = 22
        to_port = 22     
        protocol = "tcp" 
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0     
        protocol = "-1"  /*-1 is equal to all*/
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "allow traffic"
    }
  
}

