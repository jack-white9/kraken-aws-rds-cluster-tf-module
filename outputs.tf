output "security_group_id" {
  value       = aws_security_group.this[0].id
  description = "The ID of the security group attached to the RDS cluster."
}

output "endpoint" {
  value       = aws_rds_cluster.this[0].endpoint
  description = "The DNS address of the cluster."
}

output "reader_endpoint" {
  value       = aws_rds_cluster_instance.read[0].endpoint
  description = "The DNS address of the read replica."
}
