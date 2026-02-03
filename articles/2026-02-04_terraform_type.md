---
title: "terraform の細かすぎて伝わらない小ネタ モジュール化の際の variables type"
emoji: "🥚"
type: "tech"
topics: ["terraform", "pagerduty"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- terraform で管理しているリソースの型を検証しないでモジュール化して variables に間違った型定義をすると後で面倒なので注意！
- なんて思って憤っても、ちゃんと調べてみると先人の知恵が詰まってるよ、みたいな話

# 経緯

- HCP terraform のドリフトチェック（Saved Viewでドリフトしているワークスペースの一覧を作ってある）をしていて見つけた差分
- 実リソース側で手作業にて値を変更した形跡を確認
- クラウドリソースなら手作業をさせないようにロール等でコントロールもできるけど、今回は PagerDuty の service リソースの設定だったので、我々管理者系から変更権限を剥奪するのも難しく。。。（正確には難しいってゆうかめんどくさい、だけれどもｗ）
- ともあれ、手作業の結果がドリフトとして検出されているワークスペースをキャッチアップして、常に差分のないように整えるのはIaC運用的には日常

# 実際の差分など

- 対象のリソースの[ドキュメント](https://registry.terraform.io/providers/PagerDuty/pagerduty/latest/docs/resources/service)
- ドリフトの様子はこんな感じ。以前は差分がなかったので、実リソース側で何かしたんだろうなってのはすぐ気がつく（そのためにもドリフトチェックを日課にするのは大事）<br> ![drift](/images/2026-02-04_1.png)
- 名前のとおり PagerDuty の Service リソースのうち、Akamai って名前のサービスの設定が変更されているのがわかるので、PagerDuty 側で変更のログをチェック<br> ![audit](/images/2026-02-04_2.png)
- そういえば先日テストでいじってたような気がする

# 実際のコード（はちょっと控えめ）

```hcl
# モジュールの variables.tf
variable "technical_services" {
  description = "PagerDuty （テクニカル）サービスの情報"

  type = map(object({
    name                    = string
    description             = optional(string)
    auto_resolve_timeout    = optional(number)
    acknowledgement_timeout = optional(number)
    escalation_policy       = string
    // 省略
  }))
}
```

- `auto_resolve_timeout` と `acknowledgement_timeout` を optional で number 型として定義していた
- 実際ドキュメントのサンプルも数字リテラルで書かれている<br> ![alt text](/images/2026-02-04_3.png)
- ここでドリフトの差分を再確認して欲しい。実はこのふたつは number 型ではなく string 型なのだ（ダブルクォートで括られている）
- terraform 的には暗黙の型変換が行われるので、リソースの argument の値自体は型変換が通れば number でも string でも問題ない
- ただし variables で number と定義したら string は渡せない（`Invalid value for input variable`になる）

# 対応

```diff
-  acknowledgement_timeout = each.value.acknowledgement_timeout
+  acknowledgement_timeout = each.value.acknowledgement_timeout == 0 ? "null" : each.value.acknowledgement_timeout
```

- コード的に variables を `optional(number)` から `optional(string)` に変更しても対応できる（はず）
- ただしそれをやるなら、代入前に型チェックをしないと実行時エラーが発生する（数字型に変換できない文字列を渡したらAPI実行時にエラーになる、そしてそのチェック時は "null" を許容する必要があり、煩雑化する）
- なので、number 型を維持したまま、実際には設定されない値として `0` を渡したら文字列 `"null"` をセットすることにした（対応完了）

# どうしてこうなった

- PagerDuty の API ドキュメントの [Create a service](https://developer.pagerduty.com/api-reference/7062f2631b397-create-a-service)

> acknowledgement_timeout
>
> integer
>
> Time in seconds that an incident changes to the Triggered State after being Acknowledged.
> Value is null if the feature is disabled. Value must not be negative.
> Setting this field to 0, null (or unset in POST request) will disable the feature.

- あー、基本数字なんだけど null 渡しすると無効にできるのね（あるあるｗ）
- terraform では `null` は値を設定しないので、null 渡しが判断できないから文字列型として扱って、`"null"` を受け入れられるようにしつつ、暗黙の型変換で数字にしていると。。。
- terraform の PagerDuty Provider のコード [terraform-provider-pagerduty/pagerduty/resource_pagerduty_service.go at v3.30.9 · PagerDuty/terraform-provider-pagerduty](https://github.com/PagerDuty/terraform-provider-pagerduty/blob/v3.30.9/pagerduty/resource_pagerduty_service.go)
- やってるやってる if 文ｗｗｗ
- PagerDuty API は Integer って言ってるけど、Provider 的には前述のとおり、文字列 "null" 渡しのためには文字列型にせざるをえないと。。。

# まとめ

- PagerDuty API で Service を作成する際の acknowledgement_timeout は Integer で null を許容する
- terraform は（というかGoは）number,null,string の型をちゃんとしようとするし null をリソースの引数に設定すると、その引数部分を無視する（雑な説明ｗ）
- そのため Terraform PagerDuty Provider での pagerduty_service の acknowledgement_timeout は String として定義されていて、string "null" を扱えるようになっている
- のだけれども、ドキュメントではあたかも number 型かのように数字リテラルが書いてある
- ~~そのせいで~~ モジュールを作成した時に variables を number として定義したのかなと
- 実際にコードを修正してPRを投げた時からこの記事を書き始めるまでは、最初に書いたように自作モジュールを作成する時に variables の型定義はちゃんと調べないとダメじゃん、と思っていた
- んだけれども、ドキュメント・コード・仕様と理由を確認したら、万事よかったなと
- これまでのコードでは必要なかった（問題なかった）、ケースによって対応が必要なことがわかった、対応方法が複数あるうち一番楽で正しい対応はできた、という感じ
- いやあ terraform はやっぱおもしろいなあ
