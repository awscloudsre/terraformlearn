resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
  Name = "firstterravpc"
  }
}
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "publicsubnet-1"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "myinternetgateway"
  }
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "publicroutetable"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.example.id
}

resource "aws_security_group" "main" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "http"
    cidr_blocks      = ["0.0.0.0/0"]
}
}
resource "aws_instance" "web" {
  ami           = "ami-0d5eff06f840b45e9"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  user_data = <<EOF
                #! /bin/bash
                sudo yum install java-1.8.0 -y
                sudo yum update -y
                sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
                sudo rpm - import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
                sudo yum install jenkins -y
                sudo systemctl start jenkins
                sudo systemctl enable jenkins
  EOF
  tags = {
    Name = "HelloWorld"
  }
}
