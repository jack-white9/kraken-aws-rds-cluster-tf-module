resource "aws_rds_cluster" "this" {
  count = var.create ? 1 : 0

  vpc_security_group_ids  = var.vpc_security_group_ids
  cluster_identifier      = var.cluster_identifier
  engine                  = var.engine
  availability_zones      = var.availability_zones
  database_name           = var.database_name
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
}
