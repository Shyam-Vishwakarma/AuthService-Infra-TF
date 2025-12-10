data "aws_acm_certificate" "issued" {
  tags = {
    Name = "auth-service-dev-ssl"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2025-English-Full-Base-**"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
