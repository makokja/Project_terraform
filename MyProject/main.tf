terraform {
  required_providers{
      aws = {
          source = "hashicorp/aws"
          version = "~>3.0"
      }
  }
}
#configured the aws provider
#no specific secret key and access key here becuase we configuired in aws cli
provider "aws" {
    region     = "ap-southeast-1" 
}

#create a VPC resource
resource "aws_vpc" "Project-VPC" {
    cidr_block = var.cidr_block[0]
    tags = {
        Name = "Project-VPC"
    }
}

# Create subnet (public)
resource "aws_subnet" "Project-Subnet1" {
    vpc_id = aws_vpc.Project-VPC.id
    cidr_block = var.cidr_block[1]
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
    dynamic ingress {
        iterator = port
        for_each = var.ports
        content{
            from_port = port.value
            to_port = port.value  
            protocol = "tcp" 
            cidr_blocks = ["0.0.0.0/0"]
        }      
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

#Create route table 

resource "aws_route_table" "Project_RouteTable" {
    vpc_id = aws_vpc.Project-VPC.id
    #specifiy a route block
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.Project-IntGW.id
    }
        tags = {
        Name = "Project_RouteTable"
    } 
  
}

#create route table association

resource "aws_route_table_association" "Project_Associate" {
    subnet_id = aws_subnet.Project-Subnet1.id
    route_table_id = aws_route_table.Project_RouteTable.id 
}

#create aws ec2 instance when Jenkins install #Creation complete after 1m4s
resource "aws_instance" "ProjectInstance" {
    ami           = var.ami
    instance_type = var.instance_type
    key_name = "EC2"
    vpc_security_group_ids = [aws_security_group.Project_Sec_Group.id]
    subnet_id = aws_subnet.Project-Subnet1.id
    associate_public_ip_address = true #allow connect via pubilc ip
    user_data = file("./installJenkins.sh")  #install jenkins using shell script check Cloud-init at /var/log to see if it completed
    tags = {
        Name = "Jenkins-Server"
    }
}

# Create an AWS EC2 Instance to host Ansible Controller (Control node)
# Creation complete after 43s
resource "aws_instance" "AnsibleController" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "EC2"
  vpc_security_group_ids = [aws_security_group.Project_Sec_Group.id]
  subnet_id = aws_subnet.Project-Subnet1.id
  associate_public_ip_address = true
  user_data = file("./installAnsibleCN.sh")

  tags = {
    Name = "Ansible-ControlNode"
  }
}

# Create an AWS EC2 Instance to host Ansible Manage Node1 to host apache tomcat
# aws_instance.AnsibleManageNode1: Creation complete after 54s 
resource "aws_instance" "AnsibleManageNode1" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "EC2"
  vpc_security_group_ids = [aws_security_group.Project_Sec_Group.id]
  subnet_id = aws_subnet.Project-Subnet1.id
  associate_public_ip_address = true
  user_data = file("./ansibleManagedNode.sh")

  tags = {
    Name = "AnsibleMN-ApacheTomcat"
  }
}
# Create an AWS EC2 Instance  Ansible Managed Node2 to host Docker
# aws_instance.DockerHost: Creation complete after 1m4s 
resource "aws_instance" "DockerHost" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "EC2"
  vpc_security_group_ids = [aws_security_group.Project_Sec_Group.id]
  subnet_id = aws_subnet.Project-Subnet1.id
  associate_public_ip_address = true
  user_data = file("./docker.sh")

  tags = {
    Name = "AnsibleMN-DockerHost"
  }
}

# Create an AWS EC2 Instance to host Sonatype Nexus
# aws_instance.Nexus: Creation complete after 54s 
resource "aws_instance" "Nexus" {
  ami           = var.ami
  instance_type = var.instance_type_nexus
  key_name = "EC2"
  vpc_security_group_ids = [aws_security_group.Project_Sec_Group.id]
  subnet_id = aws_subnet.Project-Subnet1.id
  associate_public_ip_address = true
  user_data = file("./installNexus.sh")

  tags = {
    Name = "Nexus-Server"
  }
}

# #assign Elastic IP
# resource "aws_eip" "ProjectInstanceEIP" {
#   instance = aws_instance.ProjectInstance.id
#   vpc      = true

#   tags = {
#       Name = "ProjectInstanceEIP"
#   }
# }

