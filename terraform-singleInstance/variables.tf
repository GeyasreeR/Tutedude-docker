variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
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

variable "allowed_ip" {
  description = "CIDR allowed for SSH and app ports. Set to 0.0.0.0/0 to allow from anywhere (not recommended for SSH)."
  type        = string
  default     = "0.0.0.0/0"
}

variable "repo_url" {
  description = "GitHub repository URL for the app code"
  type        = string
}