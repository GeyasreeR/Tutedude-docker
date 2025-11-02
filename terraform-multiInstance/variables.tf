variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr_backend" {
  default = "10.0.1.0/24"
}

variable "subnet_cidr_frontend" {
  default = "10.0.2.0/24"
}

variable "backend_port" {
  default = 5000
}

variable "frontend_port" {
  default = 3000
}

variable "key_name" {
  description = "Name for the EC2 key pair to create"
  type        = string
  default     = "tf-ec2-key"
}

variable "public_key_path" {
  description = "Path to your public SSH key (e.g. ~/.ssh/id_ed25519.pub)"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "instance_type" {
  default = "t2.micro"
}
