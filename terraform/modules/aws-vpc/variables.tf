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

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "The vpc_cidr value must be a valid CIDR block (e.g., 10.0.0.0/16)."
  }
}

variable "desired_public_subnets" {
  description = "The number of public subnets to create. Must be between 1 and 6."
  type        = number
  default     = 1

  validation {
    condition     = var.desired_public_subnets >= 0 && var.desired_public_subnets <= 125
    error_message = "The number of public subnets must be between 0 and 125."
  }
}

variable "desired_private_subnets" {
  description = "The number of private subnets to create. Must be between 1 and 6."
  type        = number
  default     = 1

  validation {
    condition     = var.desired_private_subnets >= 0 && var.desired_private_subnets <= 125
    error_message = "The number of private subnets must be between 0 and 125."
  }
}

variable "public_subnet_map_public_ip_on_launch" {
  description = "Map all resources with a public IP in the subnet."
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC (required for public DNS names and private DNS resolution)."
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS resolution support in the VPC (required for the VPC's DNS resolver to function)."
  type        = bool
  default     = true
}

variable "tenancy" {
  description = "The tenancy of the instance (default, dedicated, or host)."
  type        = string
  default     = "default"
  validation {
    condition     = contains(["default", "dedicated", "host"], var.tenancy)
    error_message = "Instance tenancy must be 'default', 'dedicated', or 'host'."
  }
}

