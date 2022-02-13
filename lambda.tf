module "lambda_sg" {
  source      = "./security_group"
  name        = "shimizu-lambda-sg"
  description = "SecurityGroup for Lambda"
  vpc_id      = module.vpc.vpc_id
  port        = 0
  cidr_blocks = [var.local_ip] # これ以外の IP からでも curl で発火させれてしまうのはなぜ？
}

# 以下のような権限を付与している野良ブログもあるが、これは AWSLambdaVPCAccessExecutionRole に含まれるので自分で付け足す必要はない
# ec2:CreateNetworkInterface, ec2:DescribeNetworkInterfaces, ec2:DeleteNetworkInterface
# ref. [Execution role and user permissions](https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc.html)
