variable "bucket_name" {
  description = "Name of the bucket to be created."
  type        = string
}

variable "project_name" {
  description = "Name of the project."
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


variable "versioning_status" {
  description = "The status for versioning configuration of the bucket (e.g., Enabled, Suspended or Disabled)."
  type        = string
  default     = "Enabled"

  validation {
    condition     = contains(["Enabled", "Suspended", "Disabled"], var.versioning_status)
    error_message = "The 'versioning_status' variable must be one of: 'Enabled', 'Suspended', 'Disabled'."
  }
}

variable "tags" {
  description = "Tags to be assigned to the bucket."
  type        = map(string)
  default     = {}
}
