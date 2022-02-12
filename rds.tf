/*
  RDS instance
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

/*
  SecurityGroup for RDS
*/

module "rds_sg" {
  source      = "./security_group"
  name        = "shimizu-example-rds"
  description = "Allow PostgreSQL DB traffic"
  vpc_id      = module.vpc.vpc_id
  port        = 5432
  cidr_blocks = [module.vpc.vpc_cidr_block] # VPC 内でのインバウンドトラフィックにしておく
}
