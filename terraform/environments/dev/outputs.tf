output "aws_vpc" {
  description = "The ID of the AWS VPC"
  value       = module.aws_vpc.vpc_id
}

output "instance_public_ip" {
  description = "Public IP of the web server"
  value       = module.web_server.instance_public_ip
}

output "instance_private_ip" {
  description = "Private IP of the web server"
  value       = module.web_server.instance_private_ip
}

output "private_subnet_ids" {
  description = "A list of IDs for the private subnets."
  value       = [for s in module.aws_vpc.private_subnet_ids : s]
}

output "database_endpoint" {
  value = module.sqlserver.database_endpoint
}
