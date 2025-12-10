output "rds_outputs" {
  description = "All outputs of rds module."
  value       = module.sqlserver.outputs
}

output "alb_outputs" {
  description = "All outputs of load-balncer module."
  value       = module.alb.outputs
}

output "vpc_outputs" {
  description = "All outputs of vpc module."
  value       = module.vpc.outputs
}

output "ec2_outputs" {
  description = "All outputs of ec2 module."
  value       = module.web_server.outputs
}
