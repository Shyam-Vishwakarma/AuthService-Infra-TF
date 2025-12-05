variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Name of the load balancer. If not provided, will be generated from project_name and environment"
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "Creates a unique name beginning with the specified prefix. Conflicts with name"
  type        = string
  default     = null
}

variable "load_balancer_type" {
  description = "Type of load balancer to create. Possible values are application, gateway, or network"
  type        = string
  default     = "application"

  validation {
    condition     = contains(["application", "network", "gateway"], var.load_balancer_type)
    error_message = "Load balancer type must be application, network, or gateway."
  }
}

variable "internal" {
  description = "If true, the load balancer will be internal"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "A list of subnet IDs to attach to the load balancer"
  type        = list(string)
  default     = []
}

variable "enable_deletion_protection" {
  description = "Allow load balancer deletion or not."
  type        = bool
  default     = false
}


variable "enable_zonal_shift" {
  description = "Whether zonal shift is enabled"
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  type        = number
  default     = 60
}

variable "drop_invalid_header_fields" {
  description = "Whether HTTP headers with header fields that are not valid are removed."
  type        = bool
  default     = false
}

variable "client_keep_alive" {
  description = "Client keep alive value in seconds."
  type        = number
  default     = 3600
}

variable "access_logs" {
  description = "Access logs configuration for the load balancer"
  type = object({
    bucket  = string
    enabled = bool
    prefix  = optional(string)
  })
  default = null
}

variable "connection_logs" {
  description = "Connection logs configuration for the load balancer (only for NLB)"
  type = object({
    bucket  = string
    enabled = bool
    prefix  = optional(string)
  })
  default = null
}

variable "vpc_id" {
  description = "VPC ID where the load balancer will be deployed"
  type        = string
}

variable "security_groups" {
  description = "List of security group IDs to assign to the load balancer"
  type        = list(string)
  default     = []
}

variable "security_group_ingress_rules" {
  description = "Map of ingress rules to create for the load balancer security group"
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
    cidr_ipv4   = string
  }))
  default = {
    http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}

variable "security_group_egress_rules" {
  description = "Map of egress rules to create for the load balancer security group"
  type = map(object({
    from_port   = optional(number)
    to_port     = optional(number)
    protocol    = string
    description = string
    cidr_ipv4   = optional(string)
  }))
  default = {
    all = {
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}

variable "target_groups" {
  description = "Map of target group configurations"
  type = map(object({
    name        = string
    port        = number
    protocol    = string
    target_type = string

    health_check = optional(object({
      enabled             = optional(bool, true)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      timeout             = optional(number, 6)
      interval            = optional(number, 30)
      path                = optional(string)
      port                = optional(string, "traffic-port")
      protocol            = optional(string)
      matcher             = optional(string)
    }))

    tags = optional(map(string), {})
  }))
  default = {}
}

variable "target_group_attachments" {
  description = "Map of target group attachment configurations"
  type = map(object({
    target_group_key = string
    target_id        = string
    port             = number
  }))
  default = {}
}

variable "listeners" {
  description = "Map of listener configurations"
  type = map(object({
    port     = number
    protocol = string

    default_actions = list(object({
      type             = string
      target_group_key = optional(string)
      target_group_arn = optional(string)

      forward = optional(object({
        target_groups = list(object({
          target_group_key = string
          weight           = optional(number, 1)
        }))
      }))

      redirect = optional(object({
        status_code = string
        host        = optional(string)
        path        = optional(string)
        port        = optional(string)
        protocol    = optional(string)
        query       = optional(string)
      }))

      fixed_response = optional(object({
        content_type = string
        message_body = optional(string)
        status_code  = optional(string)
      }))
    }))

    tags = optional(map(string), {})
  }))
  default = {}
}

variable "listener_rules" {
  description = "Map of listener rule configurations"
  type = map(object({
    listener_key = string
    priority     = optional(number)

    actions = list(object({
      type             = string
      target_group_key = optional(string)
      target_group_arn = optional(string)
      order            = optional(number)

      forward = optional(object({
        target_groups = list(object({
          target_group_key = string
          weight           = optional(number, 1)
        }))
      }))

      redirect = optional(object({
        status_code = string
        host        = optional(string)
        path        = optional(string)
        port        = optional(string)
        protocol    = optional(string)
        query       = optional(string)
      }))

      fixed_response = optional(object({
        content_type = string
        message_body = optional(string)
        status_code  = optional(string)
      }))
    }))

    conditions = list(object({
      host_header = optional(object({
        values = list(string)
      }))

      path_pattern = optional(object({
        values = list(string)
      }))

      http_header = optional(object({
        http_header_name = string
        values           = list(string)
      }))

      http_request_method = optional(object({
        values = list(string)
      }))

      query_string = optional(list(object({
        key   = optional(string)
        value = string
      })))

      source_ip = optional(object({
        values = list(string)
      }))
    }))

    tags = optional(map(string), {})
  }))
  default = {}
}
