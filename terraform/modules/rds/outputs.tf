output "outputs" {
  value = {
    security_group_id = aws_security_group.rds_sg.id
    database_endpoint = aws_db_instance.main.endpoint
  }
}
