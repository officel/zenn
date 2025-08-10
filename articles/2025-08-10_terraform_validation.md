---
title: "terraform の細かすぎて伝わらない小ネタ 入力値の validation と組み合わせ"
emoji: "✔️"
type: "tech"
topics: ["terraform", "validation"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- モジュールで少し面倒な入力条件があったので読みやすいバリデーションを書いた
- XOR な condition は読むのがくっそ面倒なので、可能な限り読みやすくしてみた（つもり）
- 条件を少し変えることで他の楽な方法もあるなって。。。（今回対象外）

# 仕様

- 自作モジュールの仕様追加
- 配列でデータを渡していたが、仕様追加で別の文字列を渡して既存と同様のことをする
- 既存（`list_of_string`）と新規（`one_string`）のどちらかしか使用しない（できない）ようにする
- 使わないほうは指定しないようにさせたいし、間違えて両方指定するのも止めたい

# こんな感じ

```hcl:modules/example/variables.tf
variable "list_of_string" {
  type        = list(string)
  default     = null
  description = "awesome string array."

  validation {
    # list_of_string は null または空ではないリストであること
    # 空のリストはエラー ≒ nullを渡すか、呼び出しに使わないこと
    condition     = var.list_of_string == null || length(var.list_of_string) > 0
    error_message = "list_of_string must be null or a non-empty list."
  }
}

variable "one_string" {
  type        = string
  default     = null
  description = "awesome string."

  validation {
    # one_string は null または空ではない文字列であること
    # 空文字列("")はエラー ≒ nullを渡すか、呼び出しに使わないこと
    condition     = var.one_string == null || var.one_string != ""
    error_message = "one_string must be null or a non-empty string."
  }

  validation {
    # list_of_string か one_string のどちらかだけが必ず有効な値を持っていること
    condition = (
      (var.list_of_string == null && var.one_string != null) ||
      (var.list_of_string != null && var.one_string == null)
    )
    error_message = "Either list_of_string or one_string must be set, but not both."
  }
}

# テスト用のおまけ
output "var" {
  value = jsonencode({
    list_of_string = var.list_of_string,
    one_string     = var.one_string,
  })
}
```

- 丸コピーしてディレクトリに単一のファイルとして置いてテストできるのでやってみて
- 値自体のバリデーションは省略

# テスト

- test を使うと手間がかかってめんどいのでシェルでぶん回した
- `terraform.tfvars` を使うのもいいよ

```bash
# OK なケース（どちらか片方だけが正しく指定される）
terraform plan -var list_of_string=[1]
terraform plan -var one_string="a"

# NG なケース
## 両方とも null
terraform plan
## 空の配列（nullと変わらぬ）
terraform plan -var list_of_string=[]
## 空の文字列
terraform plan -var one_string=""
## 両方に値を入れてしまう
terraform plan -var list_of_string=["1"] -var one_string="a"
```

# 所感

- validation を 1 つだけ書いて全部埋めるのは無理がある
- 必要な validation を分割して書いて、あとでまとめると楽かも
- 自分たちだけで使う分には細かいバリデーションを書く必要はないと思ってる
- 今回のモジュールは PFE として別に利用者がいる想定なので書いてみた
- 爪とぎがてらたまにはこういう頭の体操的なことをするの大事だなって
- そもそも既存（`list_of_string`）があれば優先して使用する、だけの仕様ならバリデーションしないで既存コード側で避けてもよかった
- まぁ **TMTOWTDI** （There's More Than One Way To Do It）ってことだね

# まとめ

- terraform の input validation について書いた
- テクニックに走りすぎると可読性が犠牲になるので、丁寧にシンプルにするのがいいと思う
- 仕様を整理して、どうなっていて欲しいか、そのためにどう書けばいいか、を考える
- 取りえる値から必要なテストケースを洗いつつ、ムダを省く（今回で言えば配列の長さは気にしてないし、null 渡しも省略している）
- なんか書いたらブログ記事にするとニ度おいしいｗ
