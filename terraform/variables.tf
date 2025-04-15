variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability zone for subnets"
  type        = string
  default     = "us-east-1a"
}

variable "default_route_cidr_block" {
  description = "Default route CIDR block"
  type        = string
  default     = "0.0.0.0/0"
}

variable "security_group_name" {
  description = "Name of the security group"
  type        = string
  default     = "xyz_security_group"
}

variable "ssh_cidr_block" {
  description = "CIDR block for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "http_cidr_block" {
  description = "CIDR block for HTTP access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "iam_role_name" {
  description = "Name of the IAM role"
  type        = string
  default     = "xyz_iam_role"
}

variable "iam_policy_name" {
  description = "Name of the IAM policy"
  type        = string
  default     = "xyz_iam_policy"
}

variable "key_pair_name" {
  description = "Name of the key pair"
  type        = string
  default     = "xyz_key_pair"
}

variable "public_key" {
  description = "Public key for EC2 key pair"
  type        = string
  default     = "<YOUR_PUBLIC_KEY>"
}

variable "instance_ami" {
  description = "AMI for the EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ec2_instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "xyz_ec2_instance"
}

variable "ebs_volume_size" {
  description = "Size of the EBS volume"
  type        = number
  default     = 10
}

variable "ebs_volume_name" {
  description = "Name tag for the EBS volume"
  type        = string
  default     = "xyz_ebs_volume"
}

variable "ebs_device_name" {
  description = "Device name for the EBS volume attachment"
  type        = string
  default     = "/dev/sdh"
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
  default     = "xyz_cloudwatch_log_group"
}

variable "cpu_alarm_name" {
  description = "Name of the CPU alarm"
  type        = string
  default     = "xyz_cpu_alarm"
}

variable "cpu_alarm_threshold" {
  description = "Threshold for CPU alarm"
  type        = number
  default     = 80
}