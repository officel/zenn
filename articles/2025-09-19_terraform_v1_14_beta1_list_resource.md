---
title: "terraform v1.14.0 で追加予定の list resource を試してみた"
emoji: "✅"
type: "tech"
topics: ["terraform", "list-resource"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- [Release v1.14.0-beta1 · hashicorp/terraform](https://github.com/hashicorp/terraform/releases/tag/v1.14.0-beta1)
- [Release v4.45.0 · hashicorp/terraform-provider-azurerm](https://github.com/hashicorp/terraform-provider-azurerm/releases/tag/v4.45.0)
- List Resource とな
- terraform-jp で [koki さん](https://zenn.dev/kou_pg_0131) が良さそうって言うので試してみた
- [locals block reference for `.tfquery.hcl` files | Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/cli/v1.14.x/commands/query)
- [Import existing resources in bulk | Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/language/v1.14.x/import/bulk)

# コードと実行

- 毎度おなじみの基本 (`terraform.tf`)
- サブスクリプション ID の渡し方等はお好きに

```hcl:terraform.tf
terraform {
  required_version = ">= 1.4"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.45.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "#自分とこの値をどうぞ"
  features {}
}
```

- list resource (`list.tfquery.hcl`)
- ファイル名は `*.tfquery.hcl`
- `terraform query` のときしか読み込まれないみたい？
- `*.tf` に `list` block を書くとエラーになるので注意

```hcl:list.tfquery.hcl
list "azurerm_storage_account" "this" {
  provider = azurerm
  config {
    resource_group_name = "#自分とこの値をどうぞ"
  }
}
```

# 実行

```bash
# いつもの初期化
terraform init --upgrade
terraform fmt
terraform validate
terraform plan

# 今日ココ。対象のリソース数にもよると思うけど時間かかる
terraform query
# json で欲しいなら
terraform query -json

# resource と import block を生成する（今回の目玉）
terraform query -generate-config-out=storage_accounts.tf
# 確認
terraform plan
```

# 所感

- generate-config-out したファイルに list resource で対象になったリソースの resource block と import block が出力される
- ドキュメントが微妙にミスっててコピペで実行すると残念（`-generate-config=` じゃない）
- 出力された内容一発で import できたら最高なんだけど、今のところ大量のエラーが出てしまうので要調整
- 出力された resource block はテンプレート的に整っているが、スタイルガイドにはしたがっていないため要調整（block objects 間の空白行とか、provider が先頭に来るけど id や name はソートされているとか、なくてもええやろな値が含まれているとか）
- terraform としては query コマンドを追加して、バルクインポートをサポートする姿勢を見せた
- 実際には各 provider がかなり手を加えてサポートしないとダメそう（PR のコード量よ！）
- 今までは手で作ったり data source 等から自動で生成したりして、import に対する面倒さがあったけど、query コマンドによって import の手順が整っていくのかもしれない
- HCP Terraform で実行する時はどうするんだろう？クラウドの権限を握ってる人はどうとでもできるけど、HCPt 上での実行を強制される人（ローカル実行を許可しないワークスペース）では処理できないかも？
