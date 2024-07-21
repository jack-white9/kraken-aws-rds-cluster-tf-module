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

  vpc_security_group_ids  = concat([aws_security_group.this[0].id], var.security_groups)
  db_subnet_group_name    = aws_db_subnet_group.this[0].name
  cluster_identifier      = var.cluster_identifier
  engine                  = var.engine
  availability_zones      = var.availability_zones
  database_name           = var.database_name
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window

  skip_final_snapshot       = !var.snapshot_before_deletion
  final_snapshot_identifier = var.snapshot_before_deletion ? "${var.cluster_identifier}-final-snapshot" : null
}

resource "aws_rds_cluster_instance" "write" {
  count = var.create ? 1 : 0

  identifier         = "${var.cluster_identifier}-write"
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class     = var.write_instance_class
  engine             = aws_rds_cluster.this[0].engine
  engine_version     = aws_rds_cluster.this[0].engine_version
}

resource "aws_rds_cluster_instance" "read" {
  count = var.create ? 1 : 0
  # dependency forces write instance to be deployed first
  depends_on = [aws_rds_cluster_instance.write]

  identifier         = "${var.cluster_identifier}-read"
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class     = var.read_instance_class
  engine             = aws_rds_cluster.this[0].engine
  engine_version     = aws_rds_cluster.this[0].engine_version
}
