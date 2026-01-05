locals {
  all_rules = {
    rdp = {
      enabled     = var.allow_rdp
      port        = 3389
      protocol    = "tcp"
      description = "Allow RDP Access"
    }
    http = {
      enabled     = var.allow_http
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

  cidr_rules = [
    for rule_name, rule in local.all_rules :
    { for cidr_name, cidr in var.access_cidr_blocks : "${rule_name}-${cidr_name}" => {
      port        = rule.port
      protocol    = rule.protocol
      description = rule.description
      cidr        = cidr
    } if rule.enabled == true }
  ]

  ingress_rules = merge(local.cidr_rules...)
  name_prefix   = "${var.project_name}-${var.environment}"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "tls_private_key" "key-pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key-pair" {
  key_name_prefix = "${local.name_prefix}-key-pair"
  public_key      = tls_private_key.key-pair.public_key_openssh
}

resource "aws_secretsmanager_secret" "private_key" {
  name_prefix             = "${local.name_prefix}-private-key"
  description             = "Private key for ${local.name_prefix} EC2 instance"
  recovery_window_in_days = var.secret_recovery_window_days

  tags = merge(
    local.tags,
    {
      Name        = "${local.name_prefix}-private-key"
      Environment = var.environment
      Project     = var.project_name
  })
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

resource "aws_security_group" "instance_sg" {
  name_prefix = "${local.name_prefix}-sg"
  description = "Security group for ${local.name_prefix} instance"
  vpc_id      = var.vpc_id

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rules" {
  for_each = local.ingress_rules

  security_group_id = aws_security_group.instance_sg.id

  from_port   = each.value.port
  to_port     = each.value.port
  ip_protocol = each.value.protocol
  description = each.value.description
  cidr_ipv4   = each.value.cidr


}

resource "aws_vpc_security_group_egress_rule" "egress_rules" {
  security_group_id = aws_security_group.instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "ec2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  key_name                    = aws_key_pair.key-pair.key_name
  associate_public_ip_address = var.associate_public_ip
  tenancy                     = var.instance_tenancy

  root_block_device {
    volume_size           = var.root_block_device.volume_size
    delete_on_termination = var.root_block_device.delete_on_termination
    encrypted             = var.root_block_device.encrypted
  }

  cpu_options {
    core_count       = var.cpu_options.core_count
    threads_per_core = var.cpu_options.threads_per_core
  }

  iam_instance_profile = var.iam_instance_profile
  get_password_data    = var.get_password_data

  user_data = var.run_startup_sript ? file(var.user_data_script_path) : null

  tags = merge(
    var.tags,
    local.tags,
    {
      Name = "${local.name_prefix}-ec2"
    }
  )
}

resource "aws_ssm_parameter" "instance_public_ip" {
  name  = "/${var.project_name}/${var.environment}/${var.instance_name}/ip"
  type  = "String"
  value = aws_instance.ec2.public_ip
}

resource "aws_ssm_parameter" "instance_admin_password" {
  name = "/${var.project_name}/${var.environment}/${var.instance_name}/password"
  type = "SecureString"
  value = rsadecrypt(
    aws_instance.ec2.password_data,
    tls_private_key.key-pair.private_key_pem
  )
}
