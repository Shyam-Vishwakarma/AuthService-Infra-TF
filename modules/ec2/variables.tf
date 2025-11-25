variable "instance_name" {
  description = "Name to assign to the EC2 instance."
  type        = string
  default     = "new instance"
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

variable "access_cidr_block" {
  description = "The CIDR block from which access is allowed to the instance."
  type        = string
  default     = "0.0.0.0/0"
}

variable "allow_ssh" {
  description = "Set to true to allow SSH access from the specified CIDR block."
  type        = bool
  default     = false
}

variable "allow_rdp" {
  description = "Set to true to allow RDP access from the specified CIDR block."
  type        = bool
  default     = false
}

variable "allow_tcp" {
  description = "Set to true to allow TCP access from the specified CIDR block."
  type        = bool
  default     = false
}

variable "ami_owner_filter" {
  description = "Owner ID for the AMI search."
  type        = string
}

variable "ami_name_filter" {
  description = "Name pattern for the AMI search."
  type        = string
}

variable "associate_public_ip" {
  description = "Whether to assign a public IP address to the instance."
  type        = bool
  default     = false
}

variable "root_block_device_size" {
  description = "The size of the root EBS volume in GiBs."
  type        = number
  default     = 8
}

variable "delete_on_termination" {
  description = "Whether the root EBS volume should be deleted when instance is terminated."
  type        = bool
  default     = true
}

variable "encrypted" {
  description = "Whether the root EBS volume should be encrypted."
  type        = bool
  default     = true
}

variable "cpu_core_count" {
  description = "The number of CPU cores to launch the instance with."
  type        = number
  default     = 2
}

variable "cpu_threads_per_core" {
  description = "The number of threads per core."
  type        = number
  default     = 2
}
