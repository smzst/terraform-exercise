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

module "allow_ssh_sg" {
  source      = "./security_group"
  name        = "shimizu-example-allow-ssh"
  description = "Allow inbound SSH traffic"
  vpc_id      = module.vpc.vpc_id
  port        = 22
  cidr_blocks = [
    var.local_ip,   # https://checkip.amazonaws.com/ でローカル端末の IP アドレスがわかる
    "3.112.23.0/29" # EC2 クライアントコンソールからアクセスするとき。AWS の IP アドレス範囲。
  ]
}

module "allow_http_sg" {
  source      = "./security_group"
  name        = "shimizu-example-allow-http"
  description = "Allow inbound HTTP traffic"
  vpc_id      = module.vpc.vpc_id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}

/*
  ec2
*/

# 野良ブログでは EIP で IP アドレス固定してたりするけど、動的なのは振られるので必須ではない
resource "aws_instance" "example" {
  ami                    = "ami-08a8688fb7eacb171"
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.allow_ssh_sg.id, module.allow_http_sg.id]
  key_name               = aws_key_pair.example.id
}
resource "aws_key_pair" "example" {
  key_name   = "example"
  public_key = file("./example.pub") # key pair なしで EC2 インスタンス立てると接続できないらしい
}
