resource "aws_db_subnet_group" "this" {
  count = var.create ? 1 : 0

  name        = "${var.cluster_identifier}-subnet-group"
  description = "For Aurora cluster ${var.cluster_identifier}"
  subnet_ids  = var.subnet_ids
}

resource "aws_security_group" "this" {
  count = var.create ? 1 : 0

  name        = "${var.cluster_identifier}-sg"
  vpc_id      = var.vpc_id
  description = "Control ingress/egress traffic for cluster ${var.cluster_identifier}"
}

resource "aws_security_group_rule" "this" {
  for_each = { for k, v in var.security_group_rules : k => v if var.create }

  security_group_id = aws_security_group.this[0].id

  # required rule values
  type      = each.value.type
  from_port = each.value.from_port
  to_port   = each.value.to_port
  protocol  = each.value.protocol

  # optional rule values
  description              = try(each.value.description, null)
  prefix_list_ids          = try(each.value.prefix_list_ids, null)
  cidr_blocks              = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks         = try(each.value.ipv6_cidr_blocks, null)
  self                     = try(each.value.self, null)
  source_security_group_id = try(each.value.source_security_group_id, null)
}

resource "aws_rds_cluster" "this" {
  count = var.create ? 1 : 0

  vpc_security_group_ids      = concat([aws_security_group.this[0].id], var.security_groups)
  db_subnet_group_name        = aws_db_subnet_group.this[0].name
  cluster_identifier          = var.cluster_identifier
  engine                      = var.engine
  availability_zones          = var.availability_zones
  database_name               = var.database_name
  manage_master_user_password = var.manage_master_user_password
  master_username             = var.manage_master_user_password == null ? var.master_username : null
  master_password             = var.manage_master_user_password == null ? var.master_password : null
  backup_retention_period     = var.backup_retention_period
  preferred_backup_window     = var.preferred_backup_window

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this[0].id

  skip_final_snapshot       = !var.snapshot_before_deletion
  final_snapshot_identifier = var.snapshot_before_deletion ? "${var.cluster_identifier}-final-snapshot" : null
}

resource "aws_rds_cluster_instance" "write" {
  count = var.create ? 1 : 0

  identifier         = "${aws_rds_cluster.this[0].id}-write"
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class     = var.write_instance_class
  engine             = aws_rds_cluster.this[0].engine
  engine_version     = aws_rds_cluster.this[0].engine_version
}

resource "aws_rds_cluster_instance" "read" {
  count = var.create ? 1 : 0
  # dependency forces write instance to be deployed first
  depends_on = [aws_rds_cluster_instance.write]

  identifier         = "${aws_rds_cluster.this[0].id}-read"
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class     = var.read_instance_class
  engine             = aws_rds_cluster.this[0].engine
  engine_version     = aws_rds_cluster.this[0].engine_version
}

# The following config enables the cluster to be used as a AWS DMS source
data "aws_secretsmanager_secret_version" "aws_rds_cluster_credentials" {
  count = var.create && var.manage_master_user_password != null ? 1 : 0

  secret_id = try(aws_rds_cluster.this[0].master_user_secret[0].secret_arn, null)
}

locals {
  managed_username = try(jsondecode(data.aws_secretsmanager_secret_version.aws_rds_cluster_credentials[0].secret_string)["username"], null)
  managed_password = try(jsondecode(data.aws_secretsmanager_secret_version.aws_rds_cluster_credentials[0].secret_string)["password"], null)
}

resource "aws_rds_cluster_parameter_group" "this" {
  count = var.create && var.create_dms_source ? 1 : 0

  name        = "${var.cluster_identifier}-pg"
  family      = var.parameter_group_family
  description = "Enables logical replication for ${var.cluster_identifier}"

  parameter {
    name         = "rds.logical_replication"
    value        = 1
    apply_method = "pending-reboot" # logical replication parameter requires cluster reboot
  }
}

resource "aws_dms_endpoint" "source" {
  count = var.create && var.create_dms_source ? 1 : 0

  endpoint_id   = "${var.cluster_identifier}-source-endpoint"
  endpoint_type = "source"
  engine_name   = aws_rds_cluster.this[0].engine
  username      = var.manage_master_user_password != null ? local.managed_username : var.master_username
  password      = var.manage_master_user_password != null ? local.managed_password : var.master_password
  server_name   = aws_rds_cluster.this[0].reader_endpoint
  port          = aws_rds_cluster.this[0].port
  database_name = aws_rds_cluster.this[0].database_name
}
