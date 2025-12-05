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
    tcp = {
      enabled     = var.allow_tcp
      port        = 80
      protocol    = "tcp"
      description = "Allow TCP inbound traffic on port 80."
    },
    winrm = {
      enabled     = var.allow_winrm
      port        = 5985
      protocol    = "tcp"
      description = "Allow WinRM Access"
    }
  }

  enabled_rules = {
    for name, rule in local.all_rules : name => rule
    if rule.enabled == true
  }

  name_prefix = "${var.project_name}-${var.environment}"
}

resource "tls_private_key" "key-pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key-pair" {
  key_name   = "${local.name_prefix}-key-pair"
  public_key = tls_private_key.key-pair.public_key_openssh
}

resource "aws_secretsmanager_secret" "private_key" {
  name                    = "${local.name_prefix}-private-key"
  description             = "Private key for ${local.name_prefix} EC2 instance"
  recovery_window_in_days = var.secret_recovery_window_days

  tags = {
    Name        = "${local.name_prefix}-private-key"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_secretsmanager_secret_version" "private_key" {
  secret_id = aws_secretsmanager_secret.private_key.id
  secret_string = jsonencode({
    private_key_pem     = tls_private_key.key-pair.private_key_pem
    private_key_openssh = tls_private_key.key-pair.private_key_openssh
    public_key_openssh  = tls_private_key.key-pair.public_key_openssh
    key_pair_name       = aws_key_pair.key-pair.key_name
  })
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
  name        = "${local.name_prefix}-sg"
  description = "Security group for ${local.name_prefix} instance"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${local.name_prefix}-sg"
    Environment = var.environment
    Project     = var.project_name
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
  tenancy                     = var.instance_tenancy

  root_block_device {
    volume_size           = var.root_block_device_size
    delete_on_termination = var.delete_on_termination
    encrypted             = var.encrypted
  }

  cpu_options {
    core_count       = var.cpu_core_count
    threads_per_core = var.cpu_threads_per_core
  }

  get_password_data = var.get_password_data

  user_data = var.run_startup_sript ? file(var.user_data_script_path) : null

  tags = {
    Name        = local.name_prefix
    Environment = var.environment
    Project     = var.project_name
  }
}
