variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
  default     = "vpc-0d8c0e07f388271df"
}

variable "subnet_id" {
  description = "Existing subnet ID"
  type        = string
  default     = "subnet-03ded541d98e1b7a6"
}

variable "ami_id" {
  description = "Ubuntu AMI ID"
  type        = string
  default     = "ami-01a00762f46d584a1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 key pair"
  type        = string
  default     = "portfolio-web-key"
}

variable "admin_cidr" {
  description = "CIDR allowed to SSH"
  type        = string
  default     = "13.233.153.70/32"
}
