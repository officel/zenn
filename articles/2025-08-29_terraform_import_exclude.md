---
title: "terraform の細かすぎて伝わらない小ネタ データソースを使ったインポートと除外のイディオム"
emoji: "👿"
type: "tech"
topics: ["terraform", "import", "data source"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- terraform 運用あるあるの import
- ワークスペース（ワーキングディレクトリ）の移動などで大量に移動させるケース
- import block で for_each が使えるのでまとめて処理
- 除外したいケースにも対応

# こんな感じ

```hcl
data "azuredevops_groups" "all" {}

import {
  for_each = {
    for i in data.azuredevops_groups.all.groups : i.descriptor => i
    if contains(keys(local.groups), i.display_name)
  }

  id = each.key
  to = azuredevops_group.this[each.value.display_name]
}
```

- Azure DevOps のグループ管理
- "s" 系のまとめて引っ張ってくる data source を利用して取得（import に必要な項目を取得。今回は descriptor）
- 全部突っ込むなら if は必要ない
- （だいたい管理外のやつがあるので）locals で対象にしたいリストを持っておいて、なんらかの条件（今回は display_name）で含めるか含めないかを決める
- だけ

# あわせて読みたい

- data source の使い方あたり

@[card](https://zenn.dev/terraform_jp/articles/2024-08-27_terraform_data_azurerm_subscriptions)

- template で import block を生成する小技（サンプルプログラムを参照）

@[card](https://zenn.dev/terraform_jp/articles/2024-05-27_tbf16)
