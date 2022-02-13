output "ec2_public_ip" {
  value     = aws_instance.example.public_ip
  sensitive = true
}

output "rds_endpoint" {
  value     = aws_db_instance.example.endpoint
  sensitive = true
}

output "public_subnet_ids" {
  description = "Lambda の設定で使いたいから"
  value       = module.vpc.public_subnets
}

output "lambda_sg_ids" {
  description = "Lambda の設定で使いたいから"
  value       = [module.lambda_sg.id]
}
