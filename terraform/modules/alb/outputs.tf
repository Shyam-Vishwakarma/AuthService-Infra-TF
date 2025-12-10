output "outputs" {
  value = {
    lb_dns_name       = aws_lb.this.dns_name
    security_group_id = aws_security_group.lb_sg.id
  }
}
