variable "aws_region" {
  description = "AWS region for deployment."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "The vpc_cidr value must be a valid CIDR block."
  }
}

variable "instance_type" {
  description = "Type of instance to be created"
  type        = string
  default     = "t3.micro"
}

variable "ami_owner_filter" {
  description = "Owner ID for the AMI search."
  type        = string
  default     = "amazon"
}

variable "ami_name_filter" {
  description = "Name pattern for the AMI search."
  type        = string
  default     = "Windows_Server-2025-English-Full-Base-**"
}

variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, test, prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], lower(var.environment))
    error_message = "The 'environment' variable must be one of: 'dev', 'test', 'staging', or 'prod'."
  }
}

variable "desired_public_subnets" {
  description = "The number of public subnets to create. Must be between 1 and 6."
  type        = number
  default     = 1

  validation {
    condition     = var.desired_public_subnets >= 0 && var.desired_public_subnets <= 6
    error_message = "The number of public subnets must be between 0 and 6."
  }
}

variable "desired_private_subnets" {
  description = "The number of private subnets to create. Must be between 1 and 6."
  type        = number
  default     = 1

  validation {
    condition     = var.desired_private_subnets >= 0 && var.desired_private_subnets <= 6
    error_message = "The number of private subnets must be between 0 and 6."
  }
}

variable "associate_public_ip" {
  description = "Whether to assign a public IP address to the instance."
  type        = bool
  default     = false
}

variable "rds_port" {
  description = "The port on which DB accepts connections."
  type        = number
  validation {
    condition     = var.rds_port > 1023 && var.rds_port < 49152
    error_message = "The port should be between 1023 and 49152."
  }
}

variable "access_cidr_block" {
  description = "CIDR block to which app is accessible to."
  type = string
  default = "0.0.0.0/0"
}
