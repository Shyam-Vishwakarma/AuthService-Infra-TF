output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.this.dns_name
}

output "lb_endpoint" {
  description = "Full endpoint URL for the load balancer"
  value       = "${var.load_balancer_type == "application" ? "http" : ""}://${aws_lb.this.dns_name}"
}

output "security_group_id" {
  description = "The ID of the security group created for the load balancer"
  value       = var.create_security_group ? aws_security_group.lb_sg[0].id : null
}
