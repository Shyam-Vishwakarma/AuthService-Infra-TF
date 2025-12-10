locals {
  server_target_group_key = "web"
  http_port               = 80
  http_protocol           = "HTTP"
  https_port              = 443
  https_protocol          = "HTTPS"
  forward_action          = "forward"
}

module "alb" {
  source = "../../modules/alb"

  project_name = var.project_name
  environment  = var.environment
  subnets      = module.vpc.outputs.public_subnet_ids
  vpc_id       = module.vpc.outputs.vpc_id

  target_groups = {
    web = {
      name     = local.server_target_group_key
      port     = local.http_port
      protocol = local.http_protocol

      health_check_path    = "/"
      health_check_matcher = "200"
    }
  }

  target_group_attachments = {
    web_server = {
      target_group_key         = local.server_target_group_key
      target_id                = module.web_server.outputs.instance_id
      target_security_group_id = module.web_server.outputs.security_group_id
    }
  }

  listeners = {
    http = {
      port     = local.http_port
      protocol = local.http_protocol

      default_action_type = local.forward_action
      target_group_key    = local.server_target_group_key
    }

    https = {
      port            = local.https_port
      protocol        = local.https_protocol
      certificate_arn = data.aws_acm_certificate.issued.arn

      default_action_type = local.forward_action
      target_group_key    = local.server_target_group_key
    }
  }

  enable_deletion_protection = false
}
