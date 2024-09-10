---
title: "New Relic を Terraform で使い始めたので"
emoji: "🥚"
type: "tech"
topics: ["terraform", "newrelic"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- 仕事で New Relic をまじめに使い始めた
- Terraform で管理されている部分とされてない部分がある
- 区別しつつ Terraform で管理できるように準備

# 最初の雛形

- 仕事では HCP Terraform 上で管理している
- 既存の管理状態とバッティングするのも嫌なのでローカルでこっそり作業中
- とりあえず雛形

```env:.env
# 環境変数渡しできる
NEW_RELIC_ACCOUNT_ID=123456789
NEW_RELIC_API_KEY=NRAK-GXXXXXXXXXXX
NEW_RELIC_REGION=us
```

```hcl:provider.tf
terraform {
  required_version = "~> 1.0"
  required_providers {
    newrelic = {
      source = "newrelic/newrelic"
    }
  }
}

provider "newrelic" {}
```

```hcl:auth.tf
data "newrelic_authentication_domain" "azuread" {
  name = "AzureAD"
}

data "newrelic_group" "test" {
  authentication_domain_id = data.newrelic_authentication_domain.azuread.id
  name                     = "test"
}
```

- 何も出力しないけど、plan 見るだけで id が拾えているので処理できているのを確認した

# ディレクトリ構造

- 以前 [terraform のディレクトリ構造のプラクティス](https://zenn.dev/terraform_jp/articles/2024-08-12_terraform_directories) という記事を書いた
- それでいくと大雑把には `terraform-newrelic/terraform/newrelic/` みたいなディレクトリが望ましい
- newrelic 下は [今更ながら New Relic に入門しまして](https://zenn.dev/raki/articles/2024-09-10_new_relic_cli) という記事に書いた `account` で分割したいところ（IDではなく名前がわかりやすいけど書き換えが容易なのが難点）
- newrelic の設定まわりを `newrelic` か `global` か `common` か `settings` かのどれかにするのが良さげ（冗長だけど個人的にはサービス名と同じなのがいいと思っている）
- `account` 下のディレクトリをどうするか検討中

  - リソースの種類で分ける（Synthetic, Browser, Alerts など）
  - 環境で分ける（開発環境、テスト環境、本番環境など）
  - 組み合わせる
  - アカウント毎に使っている部分の差が大きくて悩ましい
  - （All Accounts の All Entities が 15,000 以上あるのでちゃんと考えないといけない？実際の管理対象はそこまででもないはず）

# ぶっちゃけ

- 既存の管理済みとはディレクトリを分けているので、アカウント毎に全リソース（エンティティ）を元にごっそりデータ取り出して import と resource ブロックを生成すればいいかなと思っている（terraformerよ。。。）
- 管理できるものとできないものの区別がまだついてない
- data source にも不足がある（のがわかっている）
- そもそも New Relic の Terraform 管理ってそんなに嬉しいかなぁ（本末転倒である）
- ロジック込みで扱いやすいテンプレートエンジンにいいのないかしら。。。

# まとめ

- New Relic も数こなして慣れないといけない
- terraformer では手数が足りないので取り込みは自作する予定
- 今わかる範囲でも管理対象にタグ付けして整理したいので同時進行
