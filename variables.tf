variable "create" {
  type        = bool
  description = "Whether the cluster should be created."
  default     = true
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs in which the database instances should be created in."
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "List of VPC security groups to associate with the cluster."
}

variable "cluster_identifier" {
  type        = string
  description = "The cluster identifier. If omitted, Terraform will assign a random, unique identifier."
  default     = null
}

variable "engine" {
  type        = string
  description = "Name of the database engine to be used for the cluster."
  validation {
    condition     = contains(["aurora-mysql", "aurora-postgresql", "mysql", "postgres"], var.engine)
    error_message = "Engine must be 'aurora-mysql', 'aurora-postgresql', 'mysql', or 'postgres'."
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "List of EC2 Availability Zones for the cluster storage where cluster instances can be created. 3 AZs recommended."
}

variable "database_name" {
  type        = string
  description = "Name for the database created on cluster creation."
}

variable "master_username" {
  type        = string
  description = "Username for the master DB user."
  sensitive   = true
}

variable "master_password" {
  type        = string
  description = "Password for the master DB user."
  sensitive   = true
  validation {
    condition     = length(var.master_password) >= 8
    error_message = "Password must contain a minimum of 8 characters."
  }
}

variable "backup_retention_period" {
  type        = number
  description = "Days to retain backups for."
  default     = 1
}

variable "preferred_backup_window" {
  type        = string
  description = "Daily time range during which automated backups are created."
  default     = "00:00-02:00"
}

variable "snapshot_before_deletion" {
  type        = bool
  description = "Wheter to perform a final snapshot before deletion."
  default     = true
}
