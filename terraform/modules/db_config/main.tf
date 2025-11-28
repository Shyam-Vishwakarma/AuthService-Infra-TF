resource "aws_db_parameter_group" "this" {
  count  = var.create_db_parameter_group ? 1 : 0
  name   = "${var.name_prefix}-db-parameter-group"
  family = var.db_parameter_group_family

  dynamic "parameter" {
    for_each = var.db_parameter_group_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  tags = {
    Name = "${var.name_prefix}-db-parameter-group"
  }
}

resource "aws_db_option_group" "this" {
  count                = var.create_db_option_group ? 1 : 0
  name                 = "${var.name_prefix}-db-option-group"
  engine_name          = var.db_option_group_engine_name
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

  tags = {
    Name = "${var.name_prefix}-db-option-group"
  }
}
