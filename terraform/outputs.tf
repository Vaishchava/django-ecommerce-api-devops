output "instance_id" {
  description = "Terraform-managed EC2 instance ID"
  value       = aws_instance.app.id
}

output "public_ip" {
  description = "Public IP address of the application server"
  value       = aws_instance.app.public_ip
}

output "security_group_id" {
  description = "Application security group ID"
  value       = aws_security_group.app.id
}
