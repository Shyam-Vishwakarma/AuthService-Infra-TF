variable "name_prefix" {
  description = "Prefix for naming resources."
  type        = string
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
