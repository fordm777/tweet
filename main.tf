provider "aws" {
  region = "us-east-1"
}

data "external" "myipaddr" {
  program = ["bash", "-c", "curl -s 'https://ipinfo.io/json'"]
}


resource "aws_instance" "demo-server" {
  ami                    = "ami-051f8a213df8bc089"
  instance_type          = "t2.micro"
  key_name               = "ford30066"
  vpc_security_group_ids = [aws_security_group.ssh-sg.id]
  subnet_id              = aws_subnet.dpw-public_subnet_01.id

}

resource "aws_vpc" "dpw-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "dpw-vpc"
  }
}

//Create a Subnet 
resource "aws_subnet" "dpw-public_subnet_01" {
  vpc_id                  = aws_vpc.dpw-vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "dpw-public_subnet_01"
  }
}

resource "aws_subnet" "dpw-public_subnet_02" {
  vpc_id                  = aws_vpc.dpw-vpc.id
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "dpw-public_subnet_02"
  }
}

//Creating an Internet Gateway 
resource "aws_internet_gateway" "dpw-igw" {
  vpc_id = aws_vpc.dpw-vpc.id
  tags = {
    Name = "dpw-igw"
  }
}

// Create a route table 
resource "aws_route_table" "dpw-public-rt" {
  vpc_id = aws_vpc.dpw-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dpw-igw.id
  }
  tags = {
    Name = "dpw-public-rt"
  }
}

// Associate subnet with route table

resource "aws_route_table_association" "dpw-rta-public-subnet-1" {
  subnet_id      = aws_subnet.dpw-public_subnet_01.id
  route_table_id = aws_route_table.dpw-public-rt.id
}

resource "aws_security_group" "ssh-sg" {
  name        = "SSH"
  description = "Allow SSH Only"
  vpc_id      = aws_vpc.dpw-vpc.id

  tags = {
    Name = "dpw-SSH"
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = ["${data.external.myipaddr.result.ip}/32"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

