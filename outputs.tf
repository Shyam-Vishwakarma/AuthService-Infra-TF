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

output "instance_password" {
  description = "Admin password"
  value       = module.web_server.admin_password
  sensitive   = true
}
