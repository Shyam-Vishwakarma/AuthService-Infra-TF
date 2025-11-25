locals {
  name_prefix = "${var.project_name}_${var.environment}"
}

data "aws_rds_orderable_db_instance" "db" {
  engine                     = var.engine
  engine_latest_version      = var.create_latest_version
  storage_type               = var.storage_type
  preferred_instance_classes = [var.instance_class]
}

resource "aws_db_subnet_group" "default" {
  name       = "${local.name_prefix}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${local.name_prefix}-subnet-group"
  }
}

resource "random_password" "password" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "admin" {
  name                    = "${local.name_prefix}_admin"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "admin" {
  secret_id     = aws_secretsmanager_secret.admin.id
  secret_string = random_password.password.result
}


resource "aws_security_group" "rds_sg" {
  name        = "${local.name_prefix}_rds_sg"
  description = "Security group for ${local.name_prefix}."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name_prefix}_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rules" {
  count             = length(var.referenced_security_group_ids)
  security_group_id = aws_security_group.rds_sg.id
  description       = "Rule to reference security group: ${var.referenced_security_group_ids[count.index]}."

  from_port   = var.port
  to_port     = var.port
  ip_protocol = "tcp"

  referenced_security_group_id = var.referenced_security_group_ids[count.index]
}


resource "aws_db_instance" "main" {
  allocated_storage            = var.allocated_storage
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  backup_retention_period      = var.backup_retention_period
  db_subnet_group_name         = aws_db_subnet_group.default.name
  engine                       = data.aws_rds_orderable_db_instance.db.engine
  engine_version               = data.aws_rds_orderable_db_instance.db.engine_version
  identifier                   = "${var.project_name}-${var.environment}-db"
  instance_class               = data.aws_rds_orderable_db_instance.db.instance_class
  performance_insights_enabled = var.performance_insights_enabled
  deletion_protection          = var.deletion_protection
  multi_az                     = var.multi_az
  storage_encrypted            = var.storage_encrypted
  username                     = "${local.name_prefix}_db_user"
  password                     = aws_secretsmanager_secret_version.admin.secret_string
  publicly_accessible          = var.publicly_accessible
  port                         = var.port
  vpc_security_group_ids       = [aws_security_group.rds_sg.id]
  skip_final_snapshot          = true
}
