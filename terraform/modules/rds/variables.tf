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

variable "engine" {
  description = "The database engine to be used."
  type        = string
  default     = "sqlserver-ex"

  validation {
    condition     = contains(["aurora", "mysql", "oracle-ee", "oracle-se", "postgres", "sqlserver-ee", "sqlserver-ex", "sqlserver-se", "sqlserver-web"], lower(var.engine))
    error_message = "The 'engine' must be one of: 'aurora', 'mysql', 'oracle-ee','oracle-se','postgres','sqlserver-ee','sqlserver-ex','sqlserver-se','sqlserver-web'."
  }
}


variable "storage_type" {
  description = "The storage type of the DB to be created."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "gp2", "io1", "aurora"], lower(var.storage_type))
    error_message = "The 'storage type' must be one of: 'standard', 'gp2', 'io1', 'aurora'."
  }
}

variable "create_latest_version" {
  description = "Whether db instance is latest."
  type        = bool
  default     = true
}

variable "instance_class" {
  description = "The instance class of the DB to be created."
  type        = string
  default     = "db.t3.micro"

  validation {
    condition     = contains(["db.t3.micro", "db.t3.small", "db.t3.medium", "db.t3.large"], lower(var.instance_class))
    error_message = "The 'storage type' must be one of: 'db.t3.micro', 'db.t3.small', 'db.t3.medium', 'db.t3.large'."
  }
}


variable "subnet_ids" {
  description = "Subnet ID in which DB will be created."
  type        = list(string)
}

variable "allocated_storage" {
  description = "The amount of storage (in GB) to be initially allocated for the database instance."
  type        = number
  default     = 20
  validation {
    condition     = var.allocated_storage >= 20 && var.allocated_storage <= 6144
    error_message = "The allocated_storage must be between 20 and 6144 GiB."
  }
}

variable "auto_minor_version_upgrade" {
  description = "Indicates whether minor version upgrades will be applied automatically to the DB instance during the maintenance window."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "The days to retain backups for. Must be 0 or a value between 1 and 35."
  type        = number
  default     = 0
  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "The backup_retention_period must be between 0 and 35 days."
  }
}

variable "multi_az" {
  description = "Specifies if the DB instance is a Multi-AZ deployment."
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted."
  type        = bool
  default     = true
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled."
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Bool to control if the DB instance is publicly accessible."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Set to true to enable deletion protection."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "The VPC ID for rds security group."
  type        = string
}

variable "port" {
  description = "The port on which DB accepts connections."
  type        = number
  validation {
    condition     = var.port > 1023 && var.port < 49152
    error_message = "The port should be between 1023 and 49152."
  }
}

variable "referenced_security_group_ids" {
  description = "The ids of the security groups which resources can connect with the DB."
  type        = list(string)
}

variable "create_before_destroy" {
  description = "Whether to create the new resource before destroying the old one."
  type        = bool
  default     = false
}

variable "db_parameter_group_name" {
  description = "Name of the DB parameter group to use."
  type        = string
  default     = null
}

variable "db_option_group_name" {
  description = "Name of the DB option group to use."
  type        = string
  default     = null
}

variable "enable_blue_green_update" {
  description = "Whether to enable blue/green updates for the RDS instance."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot or not."
  type        = bool
  default     = false
}

variable "final_snapshot_identifier" {
  description = "Identifier for the final snapshot."
  type        = string
  default     = null
}

variable "create_db_parameter_group" {
  description = "Whether to set parameter_group_name on the RDS instance."
  type        = bool
  default     = false
}

variable "create_db_option_group" {
  description = "Whether to set option_group_name on the RDS instance."
  type        = bool
  default     = false
}

variable "db_parameter_group_family" {
  description = "The DB parameter group family"
  type        = string
  default     = ""
}

variable "db_parameter_group_parameters" {
  description = "List of parameter objects for the DB parameter group."
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string)
  }))
  default = []
}

variable "db_option_group_engine_name" {
  description = "Engine name for the option group (e.g. 'sqlserver-ee', 'mysql'). When empty no option group will be created."
  type        = string
  default     = ""
}

variable "db_option_group_major_engine_version" {
  description = "Major engine version for the option group (e.g. '15', '8.0'). Required when creating option group."
  type        = string
  default     = ""
}

variable "db_option_group_options" {
  description = "List of options to apply to the option group."
  type = list(object({
    name            = string
    port            = optional(number)
    option_settings = optional(list(object({ name = string, value = string })))
  }))
  default = []
}
