output "database_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "instance_security_group_id" {
  description = "The ID of the security group assigned to instance."
  value       = aws_security_group.rds_sg.id
}
