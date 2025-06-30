output "web_instance_public_ip" {
  value       = module.ec2.public_ip
  description = "Public IP of the EC2 Web Server"
}

output "rds_endpoint" {
  value       = module.rds.rds_endpoint
  description = "RDS MySQL endpoint"
}
