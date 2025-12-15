locals {
  name_prefix = "${var.project_name}-${var.environment}-${var.database_name}"
  db_username = "master"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_db_subnet_group" "default" {
  name_prefix = "${local.name_prefix}-subnet-group"
  subnet_ids  = var.subnet_ids

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-subnet-group"
  })
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "[{()}]"
}

resource "aws_secretsmanager_secret" "admin" {
  name                    = "${local.name_prefix}-password"
  description             = "Admin password for the database: ${local.name_prefix}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "admin" {
  secret_id     = aws_secretsmanager_secret.admin.id
  secret_string = random_password.password.result
}

resource "aws_security_group" "rds_sg" {
  name_prefix = "${local.name_prefix}-rds-sg"
  description = "Security group for ${local.name_prefix}."
  vpc_id      = var.vpc_id

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}_sg"
  })
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

resource "aws_db_parameter_group" "this" {
  count       = var.create_db_parameter_group ? 1 : 0
  name_prefix = "${local.name_prefix}-parameter-group"
  family      = var.db_parameter_group_family

  dynamic "parameter" {
    for_each = var.db_parameter_group_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-parameter-group"
  })
}

resource "aws_db_option_group" "this" {
  count                = var.create_db_option_group ? 1 : 0
  name_prefix          = "${local.name_prefix}-option-group"
  engine_name          = data.aws_rds_orderable_db_instance.db.engine
  major_engine_version = var.db_option_group_major_engine_version

  dynamic "option" {
    for_each = var.db_option_group_options
    content {
      option_name = option.value.name
      port        = lookup(option.value, "port", null)

      dynamic "option_settings" {
        for_each = lookup(option.value, "option_settings", [])
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  tags = merge(
    local.tags, {
      Name = "${local.name_prefix}-option-group"
  })
}

resource "aws_db_instance" "main" {
  allocated_storage            = var.allocated_storage
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  backup_retention_period      = var.backup_retention_period
  db_subnet_group_name         = aws_db_subnet_group.default.name
  engine                       = data.aws_rds_orderable_db_instance.db.engine
  engine_version               = data.aws_rds_orderable_db_instance.db.engine_version
  identifier_prefix            = local.name_prefix
  instance_class               = data.aws_rds_orderable_db_instance.db.instance_class
  performance_insights_enabled = var.performance_insights_enabled
  deletion_protection          = var.deletion_protection
  multi_az                     = var.multi_az
  storage_encrypted            = var.storage_encrypted
  username                     = local.db_username
  password                     = aws_secretsmanager_secret_version.admin.secret_string
  publicly_accessible          = var.publicly_accessible
  port                         = var.port
  vpc_security_group_ids       = [aws_security_group.rds_sg.id]
  parameter_group_name         = var.create_db_parameter_group ? aws_db_parameter_group.this[0].name : var.db_parameter_group_name
  option_group_name            = var.create_db_option_group ? aws_db_option_group.this[0].name : var.db_option_group_name
  skip_final_snapshot          = var.skip_final_snapshot
  final_snapshot_identifier    = var.skip_final_snapshot ? null : var.final_snapshot_identifier
  maintenance_window           = var.db_maintainance_window

  blue_green_update {
    enabled = var.enable_blue_green_update
  }

  tags = merge(
    local.tags,
    var.tags, {
      Name = "${local.name_prefix}-database"
  })
}

resource "aws_ssm_parameter" "database_endpoint" {
  name  = "/${var.project_name}/${var.environment}/${var.database_name}/endpoint"
  type  = "String"
  value = aws_db_instance.main.endpoint
}
