resource "aws_lb" "this" {
  dynamic "access_logs" {
    for_each = var.access_logs != null ? [var.access_logs] : []

    content {
      bucket  = access_logs.value.bucket
      enabled = access_logs.value.enabled
      prefix  = access_logs.value.prefix
    }
  }

  client_keep_alive = var.client_keep_alive

  dynamic "connection_logs" {
    for_each = var.connection_logs != null ? [var.connection_logs] : []

    content {
      bucket  = connection_logs.value.bucket
      enabled = connection_logs.value.enabled
      prefix  = connection_logs.value.prefix
    }
  }

  drop_invalid_header_fields       = var.drop_invalid_header_fields
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = var.enable_http2
  enable_zonal_shift               = var.enable_zonal_shift
  idle_timeout                     = var.idle_timeout
  internal                         = var.internal
  ip_address_type                  = var.ip_address_type


  load_balancer_type = var.load_balancer_type

  dynamic "minimum_load_balancer_capacity" {
    for_each = var.minimum_load_balancer_capacity != null ? [var.minimum_load_balancer_capacity] : []

    content {
      capacity_units = minimum_load_balancer_capacity.value.capacity_units
    }
  }

  name                 = var.name
  name_prefix          = var.name_prefix
  preserve_host_header = var.preserve_host_header
  security_groups      = var.create_security_group ? concat([aws_security_group.this[0].id], var.security_groups) : var.security_groups

  tags = local.tags
}

