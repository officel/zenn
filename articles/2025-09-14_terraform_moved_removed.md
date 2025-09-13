---
title: "terraform の細かすぎて伝わらない小ネタ module と moved と removed"
emoji: "⬛"
type: "tech"
topics: ["terraform", "module", "moved", "removed"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- ワークスペースを分割する
- 移動先では import
- 移動元では removed 必要に応じて moved
- 再整理しておく

# あらすじ

- 歴史のあるワークスペースには大量のリソースが集まる（ディレクトリ構成の課題）
- ワークスペース中のリソース数が多いと、その分 API の発行数が増える（時間や通信などのコスト増）
- 適切に分割していく必要がある（最初から見積もってディレクトリを分けておくべきである）
- 長く運用しているとそういう機会も多いので気にせず書いていたのがまとめておくことにした

# コマンドは（なるべく）避ける

- `terraform mv` や `terraform rm` など CLI で投げられるからといってやっていいかどうかは別問題
- IaC とは何か、を考えたらこれらのコマンドで処理するのはできるだけ避けること
- だいぶ前はコマンドしかなかったので仕方がないけど、今は block で書けるのでコードベースに記録を残すのが優先される
- HCP Terraform ならワークスペース設定の execution mode を local にしないことでだいたいおｋ（コマンドが通らなくなる）

# import

- 先日 [terraform の細かすぎて伝わらない小ネタ データソースを使ったインポートと除外のイディオム](https://zenn.dev/terraform_jp/articles/2025-08-29_terraform_import_exclude) という記事を書いた
- ちまちま import block を書くのは面倒なのでざっとコードで表現できるようにしておくと楽だよって話

# moved と removed

- ワークスペースから単純なリソースを削除するだけなら removed block だけでいいけど、map になってるリソースアドレスなどは直接消せないケースがある
- `module.foo["bar"].baz.qux[0]` みたいにちょっと複雑（に見える）アドレスの場合は直接 removed に書けない
- そのため moved してから removed することになる

```hcl
moved {
  from = module.foo["bar"].awesome_resource.baz["qux"]
  to   = module.foo.module.bar.awesome_resource.bazqux
}
removed {
  from = module.foo.module.bar.awesome_resource.bazqux
  lifecycle { destroy = false }
}
```

- ここで大事なのは、moved の from のリソースアドレスだけが実行時に正である必要がある"だけ"ということ
- moved の to と removed の from は同じ値になっていれば存在する必要がない（どうせ消すわけだし）

:::message
通常の removed の場合は、removed の from が正しい値である必要がある
:::

# まとめとか教訓

- ワークスペースの管理リソース数は適切な数にする
- 複雑なリソースアドレスは管理が大変なので注意する（~~ムダに複雑な variables など自己満足に過ぎないコードはゴミ~~）
- git（というかコード管理）を通じて処理されるのが IaC には必要なので、サブコマンドでローカル処理は撲滅するべし
- エラーや問題に遭遇したら解決方法を整理しておく
