provider "aws" {
  region = var.aws_region
}

# Get VPC data
data "aws_vpc" "selected_vpc" {
  id = var.vpc_id
}

# Create security group
resource "aws_security_group" "flask_app_sg" {
  name        = "flask-app-sg"
  description = "Allow inbound traffic for Flask app"
  vpc_id      = var.vpc_id

  # Allow HTTP access on port 8000
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access to the Flask app"
  }

  # Allow SSH access (optional, for troubleshooting)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access"
  }

  # Allow outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "flask-app-security-group"
  }
}

# Get subnet IDs in the VPC
data "aws_subnets" "vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# Use the first subnet in the VPC
data "aws_subnet" "selected_subnet" {
  id = tolist(data.aws_subnets.vpc_subnets.ids)[0]
}

# Create IAM role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2_flask_app_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach managed policy for SSM
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_flask_app_profile"
  role = aws_iam_role.ec2_role.name
}

# Create EC2 instance
resource "aws_instance" "flask_app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.selected_subnet.id
  vpc_security_group_ids = [aws_security_group.flask_app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  user_data              = templatefile("\${path.module}/user_data.tftpl", {
    app_code = file("\${path.module}/app.py")
  })
  
  tags = {
    Name = var.instance_name
  }
}