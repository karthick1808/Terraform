provider "aws" {
  region = "ap-south-1"
}

#
data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_region" "current" {}

#Valiables(local)
locals {
  team        = "api_mgmt_dev"
  application = "corp_api"
  server_name = "ec2-${var.environment}-api-${var.variables_sub_az}"
}


resource "aws_vpc" "terraform" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name   = "karthick-vpc"
    Region = data.aws_region.current.name
    AZ     = data.aws_availability_zones.available.names[0]
    Environment = "DEV"
  }
}


resource "aws_subnet" "karthick-subnet-1" {
  vpc_id            = aws_vpc.terraform.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "karthick-subnet-1"
  }
}
resource "aws_subnet" "karthick-subnet-2" {
  vpc_id            = aws_vpc.terraform.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "karthick-subnet-2"
  }
}
resource "aws_subnet" "karthick-subnet-3" {
  vpc_id            = aws_vpc.terraform.id
  cidr_block        = "192.168.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "karthick-subnet-3"
  }
}
#Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.terraform.id
  tags = {
    Name = "karthick-igw"
  }
}

#Create route tables for public and private subnets 
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.terraform.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
    #nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name      = "Public-Route-Table"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "public-1" {
  subnet_id      = aws_subnet.karthick-subnet-1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public-2" {
  subnet_id      = aws_subnet.karthick-subnet-2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public-3" {
  subnet_id      = aws_subnet.karthick-subnet-3.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "terraform" {
  name        = "https"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = aws_vpc.terraform.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_tls"
  }
}

resource "aws_s3_bucket" "terraform" {
  bucket = "karthick-selvam-1808-my-test-12345"
  tags = {
    Name        = "Terraform"
    Environment = "Dev"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.karthick-subnet-1.id
  tags = {
    Name  = local.server_name
    Owner = local.team
    App   = local.application
  }
}
