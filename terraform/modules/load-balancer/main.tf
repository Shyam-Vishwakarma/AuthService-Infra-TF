locals {
  name_prefix = var.name != null ? var.name : "${var.project_name}-${var.environment}-lb"

  tags = merge(
    {
      Name        = local.name_prefix
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )
}

resource "aws_security_group" "lb_sg" {
  name        = "${local.name_prefix}-sg"
  description = "Security group for ${local.name_prefix}"
  vpc_id      = var.vpc_id

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "lb_ingress" {
  for_each          = var.security_group_ingress_rules
  security_group_id = aws_security_group.lb_sg.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  description       = each.value.description
  cidr_ipv4         = each.value.cidr_ipv4
}

resource "aws_vpc_security_group_egress_rule" "lb_egress" {
  for_each          = var.security_group_egress_rules
  security_group_id = aws_security_group.lb_sg.id
  from_port         = lookup(each.value, "from_port", null)
  to_port           = lookup(each.value, "to_port", null)
  ip_protocol       = each.value.protocol
  description       = each.value.description
  cidr_ipv4         = lookup(each.value, "cidr_ipv4", null)
}

resource "aws_lb" "this" {
  name               = var.name
  name_prefix        = var.name_prefix
  load_balancer_type = var.load_balancer_type
  internal           = var.internal

  subnets         = var.subnets
  security_groups = [aws_security_group.lb_sg.id]

  enable_deletion_protection = var.enable_deletion_protection
  enable_zonal_shift         = var.enable_zonal_shift
  idle_timeout               = var.idle_timeout
  drop_invalid_header_fields = var.drop_invalid_header_fields
  client_keep_alive          = var.client_keep_alive


  dynamic "access_logs" {
    for_each = var.access_logs != null ? [var.access_logs] : []

    content {
      bucket  = access_logs.value.bucket
      enabled = access_logs.value.enabled
      prefix  = lookup(access_logs.value, "prefix", null)
    }
  }

  dynamic "connection_logs" {
    for_each = var.connection_logs != null ? [var.connection_logs] : []

    content {
      bucket  = connection_logs.value.bucket
      enabled = connection_logs.value.enabled
      prefix  = lookup(connection_logs.value, "prefix", null)
    }
  }

  tags = local.tags
}

resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name        = lookup(each.value, "name", null)
  port        = lookup(each.value, "port", null)
  protocol    = lookup(each.value, "protocol", null)
  vpc_id      = var.vpc_id
  target_type = lookup(each.value, "target_type", "instance")

  dynamic "health_check" {
    for_each = lookup(each.value, "health_check", null) != null ? [each.value.health_check] : []

    content {
      enabled             = lookup(health_check.value, "enabled", true)
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", 3)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", 3)
      timeout             = lookup(health_check.value, "timeout", 5)
      interval            = lookup(health_check.value, "interval", 30)
      path                = lookup(health_check.value, "path", null)
      port                = lookup(health_check.value, "port", "traffic-port")
      protocol            = lookup(health_check.value, "protocol", null)
      matcher             = lookup(health_check.value, "matcher", null)
    }
  }

  tags = merge(
    local.tags,
    lookup(each.value, "tags", {}),
    {
      Name = lookup(each.value, "name", "${local.name_prefix}-tg-${each.key}")
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = var.target_group_attachments

  target_group_arn = aws_lb_target_group.this[each.value.target_group_key].arn
  target_id        = each.value.target_id
  port             = each.value.port
}


resource "aws_lb_listener" "this" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol

  dynamic "default_action" {
    for_each = lookup(each.value, "default_actions", [])

    content {
      type             = default_action.value.type
      target_group_arn = lookup(default_action.value, "target_group_key", null) != null ? aws_lb_target_group.this[default_action.value.target_group_key].arn : lookup(default_action.value, "target_group_arn", null)
      order            = lookup(default_action.value, "order", null)

      dynamic "forward" {
        for_each = lookup(default_action.value, "forward", null) != null ? [default_action.value.forward] : []

        content {
          dynamic "target_group" {
            for_each = lookup(forward.value, "target_groups", [])

            content {
              arn    = aws_lb_target_group.this[target_group.value.target_group_key].arn
              weight = lookup(target_group.value, "weight", 1)
            }
          }

        }
      }

      dynamic "redirect" {
        for_each = lookup(default_action.value, "redirect", null) != null ? [default_action.value.redirect] : []

        content {
          status_code = redirect.value.status_code
          port        = lookup(redirect.value, "port", null)
          protocol    = lookup(redirect.value, "protocol", null)
        }
      }

      dynamic "fixed_response" {
        for_each = lookup(default_action.value, "fixed_response", null) != null ? [default_action.value.fixed_response] : []

        content {
          content_type = fixed_response.value.content_type
          message_body = lookup(fixed_response.value, "message_body", null)
          status_code  = lookup(fixed_response.value, "status_code", null)
        }
      }
    }
  }

  tags = merge(
    local.tags,
    lookup(each.value, "tags", {}),
    {
      Name = "${local.name_prefix}-listener-${each.key}"
    }
  )
}

resource "aws_lb_listener_rule" "this" {
  for_each = var.listener_rules

  listener_arn = aws_lb_listener.this[each.value.listener_key].arn
  priority     = lookup(each.value, "priority", null)

  dynamic "action" {
    for_each = lookup(each.value, "actions", [])

    content {
      type             = action.value.type
      target_group_arn = lookup(action.value, "target_group_key", null) != null ? aws_lb_target_group.this[action.value.target_group_key].arn : lookup(action.value, "target_group_arn", null)
      order            = lookup(action.value, "order", null)

      dynamic "forward" {
        for_each = lookup(action.value, "forward", null) != null ? [action.value.forward] : []

        content {
          dynamic "target_group" {
            for_each = lookup(forward.value, "target_groups", [])

            content {
              arn    = aws_lb_target_group.this[target_group.value.target_group_key].arn
              weight = lookup(target_group.value, "weight", 1)
            }
          }
        }
      }

      dynamic "redirect" {
        for_each = lookup(action.value, "redirect", null) != null ? [action.value.redirect] : []

        content {
          status_code = redirect.value.status_code
          port        = lookup(redirect.value, "port", null)
          protocol    = lookup(redirect.value, "protocol", null)
        }
      }

      dynamic "fixed_response" {
        for_each = lookup(action.value, "fixed_response", null) != null ? [action.value.fixed_response] : []

        content {
          content_type = fixed_response.value.content_type
          message_body = lookup(fixed_response.value, "message_body", null)
          status_code  = lookup(fixed_response.value, "status_code", null)
        }
      }
    }
  }

  dynamic "condition" {
    for_each = lookup(each.value, "conditions", [])

    content {
      dynamic "host_header" {
        for_each = lookup(condition.value, "host_header", null) != null ? [condition.value.host_header] : []

        content {
          values = host_header.value.values
        }
      }

      dynamic "path_pattern" {
        for_each = lookup(condition.value, "path_pattern", null) != null ? [condition.value.path_pattern] : []

        content {
          values = path_pattern.value.values
        }
      }

      dynamic "http_header" {
        for_each = lookup(condition.value, "http_header", null) != null ? [condition.value.http_header] : []

        content {
          http_header_name = http_header.value.http_header_name
          values           = http_header.value.values
        }
      }

      dynamic "http_request_method" {
        for_each = lookup(condition.value, "http_request_method", null) != null ? [condition.value.http_request_method] : []

        content {
          values = http_request_method.value.values
        }
      }

      dynamic "source_ip" {
        for_each = lookup(condition.value, "source_ip", null) != null ? [condition.value.source_ip] : []

        content {
          values = source_ip.value.values
        }
      }
    }
  }

  tags = merge(
    local.tags,
    lookup(each.value, "tags", {}),
    {
      Name = "${local.name_prefix}-rule-${each.key}"
    }
  )
}
