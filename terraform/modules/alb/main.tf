locals {
  name_prefix = var.name != null ? var.name : "${var.project_name}-${var.environment}-lb"

  tags = merge(
    {
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags
  )

  load_balancer_type = "application"
  target_type        = "instance"
}


resource "aws_security_group" "lb_sg" {
  name_prefix = "${local.name_prefix}-sg"
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
  name_prefix        = var.name_prefix
  load_balancer_type = local.load_balancer_type
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

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-alb"
    }
  )
}


resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name        = "${local.name_prefix}-${each.value.name}"
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = var.vpc_id
  target_type = local.target_type

  health_check {
    enabled  = true
    port     = each.value.port
    path     = each.value.health_check_path
    protocol = each.value.protocol
    matcher  = each.value.health_check_matcher
  }

  tags = merge(
    local.tags,
    each.value.tags,
    {
      Name = "${local.name_prefix}-${each.value.name}"
    }
  )
}


resource "aws_lb_target_group_attachment" "this" {
  for_each = var.target_group_attachments

  target_id        = each.value.target_id
  target_group_arn = aws_lb_target_group.this[each.value.target_group_key].arn
  port             = aws_lb_target_group.this[each.value.target_group_key].port
}


resource "aws_vpc_security_group_ingress_rule" "alb_to_target" {
  for_each = var.target_group_attachments

  security_group_id            = each.value.target_security_group_id
  referenced_security_group_id = aws_security_group.lb_sg.id
  from_port                    = aws_lb_target_group.this[each.value.target_group_key].port
  to_port                      = aws_lb_target_group.this[each.value.target_group_key].port
  ip_protocol                  = "tcp"
  description                  = "Ingress from ALB: ${aws_lb.this.id}"

  tags = merge(
    local.tags, {
      TargetGroup = aws_lb_target_group.this[each.value.target_group_key].arn
  })
}


resource "aws_lb_listener" "this" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol
  certificate_arn   = each.value.certificate_arn

  default_action {
    type             = each.value.default_action_type
    target_group_arn = aws_lb_target_group.this[each.value.target_group_key].arn
  }

  tags = merge(
    local.tags,
    each.value.tags,
    {
      Name = "${local.name_prefix}-listener-${each.key}"
    }
  )
}
