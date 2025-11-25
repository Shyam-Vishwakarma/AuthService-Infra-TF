output "db-username" {
  value = aws_db_instance.main.username
}

output "db-password" {
  value     = aws_db_instance.main.password
  sensitive = true
}

output "db-domain" {
  value = aws_db_instance.main.domain
}

output "db-endpoint" {
  value = aws_db_instance.main.endpoint
}

output "instance_security_group_id" {
  description = "The ID of the security group assigned to instance."
  value       = aws_security_group.rds_sg.id
}
