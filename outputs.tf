output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.flask_app.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.flask_app.public_ip
}

output "flask_app_url" {
  description = "URL to access the Flask application"
  value       = "http://${aws_instance.flask_app.public_ip}:8000"
}
