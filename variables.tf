variable "region" {
  default     = "ap-northeast-1"
  description = "AWS region"
}

variable "local_ip" {
  description = "IP of local machine"
}

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
}
