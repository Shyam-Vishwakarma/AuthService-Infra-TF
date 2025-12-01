output "instance_id" {
  description = "ID of the created EC2 instance."
  value       = aws_instance.ec2_instance.id
}

output "security_group_id" {
  description = "ID of the created Security Group."
  value       = aws_security_group.instance_sg.id
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance."
  value       = aws_instance.ec2_instance.private_ip
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.ec2_instance.public_ip
}

output "admin_password" {
  description = "The decrypted Administrator password"
  value = rsadecrypt(
    aws_instance.ec2_instance.password_data,
    tls_private_key.key-pair.private_key_pem
  )
  sensitive = true
}
