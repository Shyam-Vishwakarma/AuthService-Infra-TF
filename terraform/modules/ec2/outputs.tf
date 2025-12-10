output "outputs" {
  value = {
    instance_id        = aws_instance.ec2.id
    security_group_id  = aws_security_group.instance_sg.id
    instance_public_ip = aws_instance.ec2.public_ip

  }
}
