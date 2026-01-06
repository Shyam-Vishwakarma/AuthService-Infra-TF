output "outputs" {
  value = {
    vpc_id             = aws_vpc.main.id
    public_subnet_ids  = [for s in aws_subnet.public : s.id]
    private_subnet_ids = [for s in aws_subnet.private : s.id]
  }
}
