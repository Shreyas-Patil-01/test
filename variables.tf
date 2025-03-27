variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-0d5a234080f9fa9b5"
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "clouvix"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-071226ecf16aa7d96"
}