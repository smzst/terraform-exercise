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
