terraform {
  required_version = "1.1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.74.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

/*
  vpc
*/

# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
# NAT gateway を有効にする場合、デフォルトで NAT gateway に新しい EIP を割り当ててくれる（すでにある場合は指定することもできる）
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.12.0"

  name                 = "shimizu-example"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  private_subnets      = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "example" {
  name       = "shimizu-example"
  subnet_ids = module.vpc.private_subnets
}

# インパウンドまたはアウトバウンドで 2 つ以上のルールがある場合は aws_security_group にルールをぶら下げる方が security group がむやみに増えなくていいなと思った
resource "aws_security_group" "example" {
  name   = "shimizu-example"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.example.id
}

resource "aws_security_group_rule" "allow_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  cidr_blocks = [
    var.local_ip,   # https://checkip.amazonaws.com/ でローカル端末の IP アドレスがわかる
    "3.112.23.0/29" # EC2 クライアントコンソールからアクセスするとき。AWS の IP アドレス範囲。
  ]
  security_group_id = aws_security_group.example.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.example.id
}

module "rds_sg" {
  source      = "./security_group"
  name        = "shimizu-example-rds"
  description = "Allow PostgreSQL DB traffic"
  vpc_id      = module.vpc.vpc_id
  port        = 5432
  cidr_blocks = [module.vpc.vpc_cidr_block] # VPC 内でのインバウンドトラフィックにしておく
}

/*
  ec2
*/

# 野良ブログでは EIP で IP アドレス固定してたりするけど、動的なのは振られるので必須ではない
resource "aws_instance" "example" {
  ami                    = "ami-08a8688fb7eacb171"
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.example.id]
  key_name               = aws_key_pair.example.id
}
resource "aws_key_pair" "example" {
  key_name   = "example"
  public_key = file("./example.pub") # key pair なしで EC2 インスタンス立てると接続できないらしい
}

/*
  rds
*/
resource "aws_db_instance" "example" {
  identifier             = "shimizu-example"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "12.9" // RDS Proxy が v12 までなので
  username               = "shimizu"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.example.name
  vpc_security_group_ids = [module.rds_sg.id]
  parameter_group_name   = aws_db_parameter_group.example.name
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false // 練習だから消えても困らない
}

resource "aws_db_parameter_group" "example" {
  name   = "shimizu-example"
  family = "postgres12"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}
