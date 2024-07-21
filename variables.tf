variable "create" {
  type        = bool
  description = "Whether the cluster should be created."
  default     = true
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to deploy the cluster into."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs in which the database instances should be created in."
}

variable "security_groups" {
  type        = list(string)
  description = "List of VPC security groups to associate with the cluster."
  default     = []
}

variable "security_group_rules" {
  type = list(object({
    type                     = string,
    from_port                = string,
    to_port                  = string,
    protocol                 = string,
    description              = optional(string),
    prefix_list_ids          = optional(list(string)),
    cidr_blocks              = optional(list(string)),
    ipv6_cidr_blocks         = optional(list(string)),
    self                     = optional(bool),
    source_security_group_id = optional(string)
    }
  ))
  description = "List of security group rules to attach to the cluster."
  default = [{
    type      = "ingress",
    from_port = 5432,
    to_port   = 5432,
    protocol  = "tcp",
    self      = true
  }]
}

variable "cluster_identifier" {
  type        = string
  description = "The cluster identifier. If omitted, Terraform will assign a random, unique identifier."
  default     = "kraken-aurora-cluster"
}

variable "engine" {
  type        = string
  description = "Name of the database engine to be used for the cluster."
  default     = "aurora-postgresql"
  validation {
    condition     = contains(["aurora-mysql", "aurora-postgresql", "mysql", "postgres"], var.engine)
    error_message = "Engine must be 'aurora-mysql', 'aurora-postgresql', 'mysql', or 'postgres'."
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "List of EC2 Availability Zones for the cluster storage where cluster instances can be created. 3 AZs recommended."
  default     = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
}

variable "database_name" {
  type        = string
  description = "Name for the database created on cluster creation."
  default     = "kraken_database"
}

variable "manage_master_user_password" {
  type        = bool
  description = "Whether to allow RDS to manage the master user/password in Secrets Manager. Must be set to null if master_username or master_password are provided."
  default     = true
}

variable "master_username" {
  type        = string
  description = "Username for the master DB user."
  sensitive   = true
  default     = null
}

variable "master_password" {
  type        = string
  description = "Password for the master DB user."
  sensitive   = true
  default     = null
  validation {
    condition     = var.master_password != null ? length(var.master_password) >= 8 : true
    error_message = "Password must contain a minimum of 8 characters."
  }
}

variable "backup_retention_period" {
  type        = number
  description = "Days to retain backups for."
  default     = 30
}

variable "preferred_backup_window" {
  type        = string
  description = "Daily time range during which automated backups are created."
  default     = "00:00-02:00"
}

variable "snapshot_before_deletion" {
  type        = bool
  description = "Whether to perform a final snapshot before deletion."
  default     = true
}

variable "read_instance_class" {
  type        = string
  description = "Instance class for database read instance."
  default     = "db.r6gd.xlarge" # read-optimised instance class for heavy read workloads
}

variable "write_instance_class" {
  type        = string
  description = "Instance class for database write instance."
  default     = "db.r6g.large" # memory-optimised instance class
}

variable "create_dms_source" {
  type        = bool
  description = "Whether to enable the cluster as a source for DMS."
  default     = true
}

variable "parameter_group_family" {
  type        = string
  description = "The family of the cluster parameter group."
  default     = "aurora-postgresql15"
}
