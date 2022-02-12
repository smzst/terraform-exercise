/*
  EC2 instance
*/

# 野良ブログでは EIP で IP アドレス固定してたりするけど、動的なのは振られるので必須ではない
resource "aws_instance" "example" {
  ami                    = "ami-08a8688fb7eacb171"
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.example.id]
  key_name               = aws_key_pair.example.id

  user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y postgresql.x86_64
EOF
}

resource "aws_key_pair" "example" {
  key_name   = "example"
  public_key = file("./example.pub") # key pair なしで EC2 インスタンス立てると接続できないらしい
}

/*
  SecurityGroup for EC2 instance
*/

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
