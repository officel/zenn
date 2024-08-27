---
title: "terraform で細かすぎて伝わらない小ネタ data source azurerm_subscriptions"
emoji: "🔎"
type: "tech"
topics: ["terraform","azure"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- 最近お仕事で Azure を触っている（AWSがメインだったのでAzureなんもわからん）
- Azure CLI(az) と Terraform と同時進行で勉強中
- Terraform の data source の使い方がいまいちなコードを見かけたので手直し

# "s" のついたデータソース

@[card](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription)
@[card](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscriptions)

- 単一のデータソース

  - 実リソースから単一のリソースデータを取得する（description）
  - 対象のリソースが見つからない場合エラーになる（エラーにならないやつあるのかしら？）

- 複数のデータソース

  - 複数のリソースデータがリスト形式で返る（list/search。違うやつ見たことないけどリスト以外で返るやつあるのかしら？）
  - 対象のデータが見つからなくても（データソース自体はエラーにならないものが多い。空のリストが返るはず）

- 全部処理する場合には問題ないが、1つだけ使うなら単一のデータソースを使うのが望ましい

# 小技

- 配列に入っていると目的のデータが何番目にあるのかわからない
- （そして"s"を使って単一のデータを引っ張って`[0]`でアクセスしているコードを見かけた）
- どうせまとめて取得するなら参照しやすくする

```HCL:main.tf
data "azurerm_subscriptions" "available" {}

output "available_subscriptions" {
  value = data.azurerm_subscriptions.available.subscriptions
}

locals {
  subscriptions = { for i in data.azurerm_subscriptions.available.subscriptions : i.display_name => i }
}

output "my" {
  # mysubscription をサブスクリプションの displayName にすることができる
  # try() はエラーにならないようにしただけのおまけ
  value = try(local.subscriptions.mysubscription, null)
}
```

# まとめ？

- データソースを使用して既存リソースを参照する際には、単一で使う場合と複数で使う場合をわけて使うデータソースを選ぶ
- 単一データソースをたくさん書くとAPIコールの数が増えるので注意する
- 複数データソースの結果を参照しやすいmapに変えるコードを提示したが、そもそもこれを必要とする作りにしないほうがいい
- 個人的にこれで実リソースのレポートを作成するために書いた
- map に変換しておけばkeyでソートさせることができる
