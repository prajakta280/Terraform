terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}

resource "aws_vpc" "Praj-terraform" {
  cidr_block = "10.0.0.0/26"

  tags = {
    Name = "Praj-terraform"
  }
}

resource "aws_subnet" "Praj-terraform-pub-1" {
  vpc_id     = aws_vpc.Praj-terraform.id
  cidr_block = "10.0.0.0/28"

  tags = {
    Name = "Praj-terraform-pub-1"
  }
}

resource "aws_internet_gateway" "Praj-igw" {
  vpc_id = aws_vpc.Praj-terraform.id

  tags = {
    Name = "Praj-igw"
  }
}

resource "aws_route_table" "Praj-RT" {
  vpc_id = aws_vpc.Praj-terraform.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Praj-igw.id
  }

   tags = {
    Name = "Praj-RT"
  }

}

resource "aws_route_table_association" "Pub-RT" {
  subnet_id      = aws_subnet.Praj-terraform-pub-1.id
  route_table_id = aws_route_table.Praj-RT.id
}

resource "aws_security_group" "Praj-sg" {
  name        = "Praj-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.Praj-terraform.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
resource "aws_instance" "Praj-terraform-server" {
  ami                     = "ami-0fc5d935ebf8bc3bc"
  instance_type           = "t2.micro"
  subnet_id               =  aws_subnet.Praj-terraform-pub-1.id
  key_name               =   "Praj-terraform-server-key"
  vpc_security_group_ids = [aws_security_group.Praj-sg.id] 
  
  tags = {
    Name = "Praj-terraform-server"
  }
}

resource "aws_key_pair" "Praj-terraform-server-key" {
  key_name   = "Praj-terraform-server-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}
