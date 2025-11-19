locals {
  all_rules = {
    ssh = {
      enabled     = var.allow_ssh
      port        = 22
      protocol    = "tcp"
      description = "Allow SSH Access"
    }
    rdp = {
      enabled     = var.allow_rdp
      port        = 3389
      protocol    = "tcp"
      description = "Allow RDP Access"
    }
  }

  enabled_rules = {
    for name, rule in local.all_rules : name => rule
    if rule.enabled == true
  }
}

resource "tls_private_key" "key-pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key-pair" {
  key_name   = "${var.instance_name}-key-pair"
  public_key = tls_private_key.key-pair.public_key_openssh
}

data "aws_ami" "latest_ami" {
  most_recent = true
  owners      = [var.ami_owner_filter]

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_security_group" "instance_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group for ${var.instance_name} instance"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.instance_name}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rules" {
  for_each = local.enabled_rules

  security_group_id = aws_security_group.instance_sg.id

  from_port   = each.value.port
  to_port     = each.value.port
  ip_protocol = each.value.protocol
  description = each.value.description

  cidr_ipv4 = var.access_cidr_block
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.latest_ami.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  key_name                    = aws_key_pair.key-pair.key_name
  associate_public_ip_address = var.associate_public_ip
  tenancy                     = "default"

  root_block_device {
    volume_size           = var.root_block_device_size
    delete_on_termination = var.delete_on_termination
    encrypted             = var.encrypted
  }

  cpu_options {
    core_count       = var.cpu_core_count
    threads_per_core = var.cpu_threads_per_core
  }

  get_password_data = true


  tags = {
    Name = var.instance_name
  }
}
