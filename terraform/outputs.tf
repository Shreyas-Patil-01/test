output "vpc_id" {
  value = aws_vpc.xyz_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.xyz_public_subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.xyz_private_subnet.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.xyz_internet_gateway.id
}

output "security_group_id" {
  value = aws_security_group.xyz_security_group.id
}

output "iam_role_id" {
  value = aws_iam_role.xyz_iam_role.id
}

output "iam_policy_id" {
  value = aws_iam_policy.xyz_iam_policy.id
}
}

output "ec2_instance_id" {
  value = aws_instance.xyz_ec2_instance.id
}

output "ebs_volume_id" {
  value = aws_ebs_volume.xyz_ebs_volume.id
}

output "cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.xyz_cloudwatch_log_group.arn
}

output "cpu_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.xyz_cpu_alarm.arn
}