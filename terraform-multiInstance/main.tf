provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Ubuntu official account

    filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}


data "local_file" "pubkey" {
  filename = replace(var.public_key_path, "~", pathexpand("~"))

}

resource "aws_key_pair" "deploy_key" {
  key_name   = var.key_name
  public_key = chomp(data.local_file.pubkey.content)
}

 
# VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr
  tags = { Name = "app-vpc" }
}

# Subnets
resource "aws_subnet" "backend_subnet" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.subnet_cidr_backend
  availability_zone = "${var.region}a"
  tags = { Name = "backend-subnet" }
}

resource "aws_subnet" "frontend_subnet" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.subnet_cidr_frontend
  availability_zone = "${var.region}a"
  tags = { Name = "frontend-subnet" }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.app_vpc.id
}

# Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "backend_association" {
  subnet_id      = aws_subnet.backend_subnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "frontend_association" {
  subnet_id      = aws_subnet.frontend_subnet.id
  route_table_id = aws_route_table.rt.id
}

# Security Group
resource "aws_security_group" "app_sg" {
  name   = "app-sg"
  vpc_id = aws_vpc.app_vpc.id

  # Allow internal communication
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  # Expose backend to internet
  ingress {
    from_port   = var.backend_port
    to_port     = var.backend_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # or restrict to your IP
}


  # Expose frontend to internet
  ingress {
    from_port   = var.frontend_port
    to_port     = var.frontend_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Backend EC2
resource "aws_instance" "backend" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.backend_subnet.id
  key_name               = aws_key_pair.deploy_key.key_name
  security_groups        = [aws_security_group.app_sg.id]
  user_data              = file("user_data/backend.sh")
  associate_public_ip_address = true
  tags = { Name = "Flask-Backend" }
}

# Frontend EC2
resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.frontend_subnet.id
  key_name               = aws_key_pair.deploy_key.key_name
  security_groups        = [aws_security_group.app_sg.id]
  user_data              = file("user_data/frontend.sh")
  associate_public_ip_address = true
  tags = { Name = "Express-Frontend" }
}
