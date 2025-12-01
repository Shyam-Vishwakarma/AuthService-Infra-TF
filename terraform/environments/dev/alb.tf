locals {
  server_target_group_key = "web"
}

module "alb" {
  source = "../../modules/load-balancer"

  project_name = var.project_name
  environment  = var.environment
  load_balancer_type = "application"
  internal           = false
  subnets            = module.aws_vpc.public_subnet_ids
  vpc_id             = module.aws_vpc.vpc_id
  create_security_group = true

  security_group_ingress_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP traffic from anywhere"
      cidr_ipv4   = var.access_cidr_block
    }
  }

  target_groups = {
    web = {
      name             = "${var.project_name}-${var.environment}-web-tg"
      port             = 80
      protocol         = "HTTP"
      target_type      = "instance"
      protocol_version = "HTTP1"

      health_check = {
        enabled             = true
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        matcher             = "200"
      }

      tags = {
        Name = "${var.project_name}-${var.environment}-web-tg"
      }
    }
  }

  target_group_attachments = {
    web_server = {
      target_group_key = local.server_target_group_key
      target_id        = module.web_server.instance_id
      port             = 80
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      default_actions = [
        {
          type             = "forward"
          target_group_key = local.server_target_group_key
        }
      ]

      tags = {
        Name = "${var.project_name}-${var.environment}-http-listener"
      }
    }

  }

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
  enable_http2                     = true
  idle_timeout                     = 60
  drop_invalid_header_fields       = true

  tags = {
    Type = "Application Load Balancer"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_from_alb" {
  security_group_id            = module.web_server.security_group_id
  referenced_security_group_id = module.alb.security_group_id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  description                  = "Allow HTTP traffic from ALB"
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.lb_dns_name
}

output "alb_endpoint" {
  description = "Full endpoint URL for the Application Load Balancer"
  value       = module.alb.lb_endpoint
}
