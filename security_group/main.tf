variable "name" {
  type = string
}
variable "description" {
  type    = string
  default = ""
}
variable "vpc_id" {
  type = string
}
variable "port" {
  type = number
}
variable "cidr_blocks" {
  type = list(string)
}

resource "aws_security_group" "default" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "id" {
  value = aws_security_group.default.id
}
