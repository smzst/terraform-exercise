output "ec2_public_ip" {
  value     = aws_instance.example.public_ip
  sensitive = true
}

output "rds_endpoint" {
  value     = aws_db_instance.example.endpoint
  sensitive = true
}
