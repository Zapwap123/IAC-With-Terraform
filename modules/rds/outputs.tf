output "rds_endpoint" {
  value = aws_db_instance.lamp.endpoint
}

output "rds_id" {
  value = aws_db_instance.lamp.id
}
