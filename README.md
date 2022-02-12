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
