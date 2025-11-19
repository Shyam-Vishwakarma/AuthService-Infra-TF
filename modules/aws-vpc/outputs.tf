output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "A list of IDs for the public subnets."
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "A list of IDs for the private subnets."
  value       = [for s in aws_subnet.private : s.id]
}

output "igw_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.igw.id
}

output "aws_route_table" {
  description = "The ID of the public route table."
  value       = aws_route_table.public.id
}
