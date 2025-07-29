provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "capital_hub_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "capital_hub_public_subnet" {
  vpc_id            = aws_vpc.capital_hub_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "capital_hub_private_subnet" {
  vpc_id            = aws_vpc.capital_hub_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_internet_gateway" "capital_hub_internet_gateway" {
  vpc_id = aws_vpc.capital_hub_vpc.id
}

resource "aws_route_table" "capital_hub_route_table" {
  vpc_id = aws_vpc.capital_hub_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.capital_hub_internet_gateway.id
  }
}

resource "aws_route_table_association" "capital_hub_public_subnet_association" {
  subnet_id      = aws_subnet.capital_hub_public_subnet.id
  route_table_id = aws_route_table.capital_hub_route_table.id
}

resource "aws_security_group" "capital_hub_ec2_sg" {
  vpc_id = aws_vpc.capital_hub_vpc.id
  name   = "capital_hub_ec2_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "capital_hub_ec2_role" {
  name = "capital_hub_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

resource "aws_iam_policy" "capital_hub_s3_access_policy" {
  name        = "capital_hub_s3_access_policy"
  description = "Policy for EC2 to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          "${aws_s3_bucket.capital_hub_s3.arn}",
          "${aws_s3_bucket.capital_hub_s3.arn}/*"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "capital_hub_attach_policy" {
  policy_arn = aws_iam_policy.capital_hub_s3_access_policy.arn
  role       = aws_iam_role.capital_hub_ec2_role.name
}

resource "aws_volume_attachment" "capital_hub_ec2_volume_attachment" {
  device_name = "/dev/sdh"
  instance_id = aws_instance.capital_hub_ec2.id
  volume_id   = aws_ebs_volume.capital_hub_ec2_ebs.id
}

resource "aws_ebs_volume" "capital_hub_ec2_ebs" {
  availability_zone = "us-east-1a"
  size             = 8
}

resource "aws_instance" "capital_hub_ec2" {
  ami                  = "ami-0123456789abcdef0" # Replace with the actual AMI ID
  instance_type       = "t2.micro"
  key_name            = aws_key_pair.capital_hub_key_pair.key_name
  subnet_id           = aws_subnet.capital_hub_public_subnet.id
  security_groups     = [aws_security_group.capital_hub_ec2_sg.name]

  iam_instance_profile = aws_iam_instance_profile.capital_hub_ec2_profile.name

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
}

resource "aws_iam_instance_profile" "capital_hub_ec2_profile" {
  name = "capital_hub_ec2_profile"
  role = aws_iam_role.capital_hub_ec2_role.name
}

resource "aws_s3_bucket" "capital_hub_s3" {
  bucket = "capital-hub-s3-bucket-unique-identifier" # Replace with a globally unique bucket name
  acl    = "private"
}

resource "aws_s3_bucket_policy" "capital_hub_s3_policy" {
  bucket = aws_s3_bucket.capital_hub_s3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "s3:GetObject"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.capital_hub_ec2_role.arn
        }
        Resource = "${aws_s3_bucket.capital_hub_s3.arn}/*"
      },
    ]
  })
}

resource "aws_cloudwatch_log_group" "capital_hub_ec2_log_group" {
  name = "/aws/ec2/capital_hub_ec2"
}
