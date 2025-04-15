provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "xyz_vpc" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "xyz_public_subnet" {
  vpc_id                  = aws_vpc.xyz_vpc.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
}

resource "aws_subnet" "xyz_private_subnet" {
  vpc_id            = aws_vpc.xyz_vpc.id
  cidr_block        = var.private_subnet_cidr_block
  availability_zone = var.availability_zone
}

resource "aws_internet_gateway" "xyz_internet_gateway" {
  vpc_id = aws_vpc.xyz_vpc.id
}

resource "aws_route_table" "xyz_route_table" {
  vpc_id = aws_vpc.xyz_vpc.id
}

resource "aws_route" "xyz_route" {
  route_table_id         = aws_route_table.xyz_route_table.id
  destination_cidr_block = var.default_route_cidr_block
  gateway_id             = aws_internet_gateway.xyz_internet_gateway.id
}

resource "aws_route_table_association" "xyz_route_table_association" {
  subnet_id      = aws_subnet.xyz_public_subnet.id
  route_table_id = aws_route_table.xyz_route_table.id
}

resource "aws_security_group" "xyz_security_group" {
  vpc_id = aws_vpc.xyz_vpc.id
  name   = var.security_group_name

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.http_cidr_block]
  }
}

resource "aws_iam_role" "xyz_iam_role" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}

resource "aws_iam_policy" "xyz_iam_policy" {
  name   = var.iam_policy_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "*"
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "xyz_iam_attachment" {
  role       = aws_iam_role.xyz_iam_role.name
  policy_arn = aws_iam_policy.xyz_iam_policy.arn
}

resource "aws_key_pair" "xyz_key_pair" {
  key_name   = var.key_pair_name
  public_key = var.public_key
}

resource "aws_instance" "xyz_ec2_instance" {
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.xyz_public_subnet.id
  key_name                    = aws_key_pair.xyz_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.xyz_security_group.id]
  iam_instance_profile        = aws_iam_role.xyz_iam_role.name

  tags = {
    Name = var.ec2_instance_name
  }
}

resource "aws_ebs_volume" "xyz_ebs_volume" {
  availability_zone = aws_subnet.xyz_public_subnet.availability_zone
  size              = var.ebs_volume_size
  tags = {
    Name = var.ebs_volume_name
  }
}

resource "aws_volume_attachment" "xyz_volume_attachment" {
  device_name = var.ebs_device_name
  volume_id   = aws_ebs_volume.xyz_ebs_volume.id
  instance_id = aws_instance.xyz_ec2_instance.id
}

resource "aws_cloudwatch_log_group" "xyz_cloudwatch_log_group" {
  name = var.cloudwatch_log_group_name
}

resource "aws_cloudwatch_metric_alarm" "xyz_cpu_alarm" {
  alarm_name          = var.cpu_alarm_name
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = var.cpu_alarm_threshold
  comparison_operator = "GreaterThanThreshold"
  alarm_description   = "Alarm when CPU exceeds ${var.cpu_alarm_threshold}%"

  dimensions = {
    InstanceId = aws_instance.xyz_ec2_instance.id
  }

  alarm_actions = [aws_cloudwatch_log_group.xyz_cloudwatch_log_group.arn]
}