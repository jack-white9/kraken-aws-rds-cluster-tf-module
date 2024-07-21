output "security_group_id" {
  value = aws_security_group.this[0].id
}

output "endpoint" {
  value = aws_rds_cluster.this[0].endpoint
}

output "reader_endpoint" {
  value = aws_rds_cluster.this[0].reader_endpoint
}
