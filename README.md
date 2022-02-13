# terraform-exercise

## メモ書き
* Terraform の .gitignore ファイルはここ
    * https://github.com/github/gitignore/blob/main/Terraform.gitignore
* PostgreSQL のバージョンは、RDS だけでなく RDS Proxy の方も考慮する必要がある
    * 取り組み時点で最新のバージョンは 14.1 だったが、RDS Proxy は 12.5 以降のマイナーバージョンとのことで、おそらく両者を揃えておく必要がある
    * https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/rds-proxy.html
* `aws_db_parameter_group` はデフォルトではなく自前のものにするのがよい
    * 後からパラメータ設定の変更をしたくなったとき、デフォルトのものは変更ができない。変更する場合は付け替えが必要になるが、付け替えると DB の再起動が必要になる。そのため最初から自前で定義しておくのがよい
    * https://htnosm.hatenablog.com/entry/2015/08/02/210000
* 0.13 から Provider の書き方が変わった
    * 0.12 以前はこんな
    ```tf
    provider "aws" {
      version = "~> 3.0"
      region = "us-east-1"
    }
    ```
    * https://registry.terraform.io/providers/hashicorp/aws/latest/docs
* リソース命名規則。よさそう
    * https://dev.classmethod.jp/articles/aws-name-rule/
* 「rds tutorial terraform」ってググったらこういうのが出てきた。入門に持ってこいじゃん！！！
    * https://learn.hashicorp.com/tutorials/terraform/aws-rds?in=terraform/aws
* Security Group の `from_port`, `to_port` は、port の範囲のことを言っている
* RDS のインバウンドルールを 5432 のみとし、アクセス元の EC2 のアウトバウンドルールを TCP の 5433 としたらアクセスできなくなった
    * RDS しか接続しないのであれば TCP 5432 に絞ることができる。そこまでやらなくていいから -1 の 0 ってしてるんだろう
    ```tf
    resource "aws_security_group_rule" "egress" {
      type              = "egress"
      from_port         = 5432
      to_port           = 5432
      protocol          = "tcp"
      cidr_blocks       = ["0.0.0.0/0"]
      security_group_id = aws_security_group.example.id
    }
    ```
* ローカルから EC2 に SSH 接続する際に Permission Denied になったら（暗号鍵の指定は `-i` オプションで）
    * case1. ユーザー名が違う。ec2-user@x.x.x.x のようにユーザー名を指定してアクセスする

### 疑問点
* Lambda の sg の CIDR をローカル端末のものにしていても異なるアドレスからアクセスできてしまう
* EC2 のアウトバウンドルールを、5433 の TCP だと繋がらないけど、-1 にすると繋がるのはなぜ？
