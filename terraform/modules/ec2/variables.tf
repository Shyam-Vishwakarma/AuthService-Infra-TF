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


variable "instance_type" {
  description = "The type of EC2 instance to launch (e.g., t2.micro)."
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "The Subnet ID to launch the EC2 instance in."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID for the security group."
  type        = string
}

variable "access_cidr_blocks" {
  description = "CIDRs to be given access for ingress rules. map of strins. e.g. {alias : cidr}."
  type        = map(string)
  default = {
    "public" : "0.0.0.0/0"
  }
}

variable "allow_rdp" {
  description = "Set to true to allow RDP access from the specified CIDR block."
  type        = bool
  default     = false
}

variable "allow_http" {
  description = "Set to true to allow TCP access from the specified CIDR block."
  type        = bool
  default     = false
}

variable "secret_recovery_window_days" {
  description = "Set secret recovery windows days for ec2 key pair."
  type        = number
  default     = 0
}

variable "ami" {
  description = "AMI Id for the instance to be launched."
  type        = string
}

variable "associate_public_ip" {
  description = "Whether to assign a public IP address to the instance."
  type        = bool
  default     = false
}

variable "root_block_device" {
  description = "Configuration for EC2 storage."
  type = object({
    volume_size           = optional(number, 30)
    encrypted             = optional(bool, true)
    delete_on_termination = optional(bool, false)
  })
}

variable "cpu_options" {
  description = "Configuration for CPU."
  type = object({
    core_count       = optional(number, 2)
    threads_per_core = optional(number, 2)
  })
}

variable "allow_winrm" {
  description = "Allow winrm access."
  type        = bool
  default     = false
}

variable "instance_tenancy" {
  description = "The tenancy of the instance."
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "dedicated", "host"], lower(var.instance_tenancy))
    error_message = "Tenancy must be in 'default', 'dedicated', 'host'"
  }
}

variable "get_password_data" {
  description = "Get password data."
  type        = bool
  default     = true
}

variable "run_startup_sript" {
  description = "Whether to run script using user_data."
  type        = bool
  default     = false
}

variable "user_data_script_path" {
  description = "The path to the user data script file"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to be assigned to the instance."
  type        = map(string)
  default     = {}
}

variable "instance_name" {
  description = "Name of the instance."
  type        = string
}
