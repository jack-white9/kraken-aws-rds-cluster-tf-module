resource "aws_db_subnet_group" "this" {
  count = var.create ? 1 : 0

  name        = "${var.cluster_identifier}-subnet-group"
  description = "For Aurora cluster ${var.cluster_identifier}"
  subnet_ids  = var.subnet_ids
}

resource "aws_rds_cluster" "this" {
  count = var.create ? 1 : 0

  vpc_security_group_ids  = var.vpc_security_group_ids
  db_subnet_group_name    = aws_db_subnet_group.this[0].name
  cluster_identifier      = var.cluster_identifier
  engine                  = var.engine
  availability_zones      = var.availability_zones
  database_name           = var.database_name
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window

  skip_final_snapshot       = var.snapshot_before_deletion
  final_snapshot_identifier = var.snapshot_before_deletion ? "${var.cluster_identifier}-final-snapshot" : null
}
