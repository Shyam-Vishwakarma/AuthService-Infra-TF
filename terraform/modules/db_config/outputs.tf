output "db_parameter_group_name" {
  description = "Name of the DB parameter group created."
  value       = length(aws_db_parameter_group.this) > 0 ? aws_db_parameter_group.this[0].name : null
}

output "db_option_group_name" {
  description = "Name of the DB option group created."
  value       = length(aws_db_option_group.this) > 0 ? aws_db_option_group.this[0].name : null
}
