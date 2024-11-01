---
title: "terraform v1.10.0-beta1 で element() にマイナスが使えなかった話"
emoji: "📦"
type: "tech"
topics: ["terraform", "go", "cty","hcl"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- [Release v1.10.0-beta1 · hashicorp/terraform](https://github.com/hashicorp/terraform/releases/tag/v1.10.0-beta1)
- element function でマイナス値が設定できるようになったようなので、リストの最後の要素が簡単にとれるようになるはずだと思ったら（まだ）ダメだった
- 原因を調査するために GitHub の奥地に向かった我々が見たものとは

# terraform v1.10.0-beta1

@[card](https://x.com/raki/status/1852039989389070665)

- [Release v1.10.0-beta1 · hashicorp/terraform](https://github.com/hashicorp/terraform/releases/tag/v1.10.0-beta1)

> ENHANCEMENTS:
> The element function now accepts negative indices (#35501)

- ということは element() で最後の要素を取得するのが簡単になるはず？
- [element - Functions - Configuration Language | Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/language/functions/element)
- ブログのネタにちょうどいいってゆうか、簡単だからすぐ終わるだろうと思った（が甘かった）

# 期待

```hcl
output "current" {
  # https://developer.hashicorp.com/terraform/language/functions/element
  value = element(["a", "b", "c"], length(["a", "b", "c"]) - 1)
}
```

- 普通はこう。これは element の第2引数にマイナスの値を渡せないせい。
- locals 等で処理するからそんなに困らないはずだけど、美しくはないよね
- [update go-cty@v1.15.0 by jbardin · Pull Request #35501 · hashicorp/terraform](https://github.com/hashicorp/terraform/pull/35501)で
- [allow negative indices for the `element` function · Issue #15582 · hashicorp/terraform](https://github.com/hashicorp/terraform/issues/15582)がcloseしてる
- ということは

```hcl
element(local.test, length(local.test) - 1)
```

じゃなくて

```hcl
element(local.test, -1)
```

って書けるようになったんだ、って思うじゃん。

期待値としてはすごく大きなリストの後ろからx番目、みたいな取り方ができるようになるはずだと（今なら length()-1-x とかでいけるけど）。

# 試してみた

```bash
$ tfenv use v1.9.8
Switching default version to v1.9.8
Default version (when not overridden by .terraform-version or TFENV_TERRAFORM_VERSION) is now: 1.9.8
$ terraform plan

Changes to Outputs:
  + current = "c"

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.
╷
│ Error: Error in function call
│
│   on main.tf line 30, in check "test":
│   30:     condition     = element(local.test, -1) == "C"
│     ├────────────────
│     │ while calling element(list, index)
│     │ local.test is tuple with 3 elements
│
│ Call to function "element" failed: cannot use element function with a negative index.
╵
$
```

そう、まずテストはエラーにしてからやらないとね（AA略

v1.9.8（現行最新バージョン）ではもちろん関数の呼び出しエラー。

```bash
$ tfenv use 1.10.0-beta1
Switching default version to v1.10.0-beta1
Default version (when not overridden by .terraform-version or TFENV_TERRAFORM_VERSION) is now: 1.10.0-beta1
$ terraform plan

Changes to Outputs:
  + current = "c"

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.
╷
│ Error: Error in function call
│
│   on main.tf line 30, in check "test":
│   30:     condition     = element(local.test, -1) == "C"
│     ├────────────────
│     │ while calling element(list, index)
│     │ local.test is tuple with 3 elements
│
│ Call to function "element" failed: panic in function implementation: runtime error: index out of range [-1]
│ goroutine 46 [running]:
│ runtime/debug.Stack()
│       runtime/debug/stack.go:26 +0x5e
│ github.com/zclconf/go-cty/cty/function.errorForPanic(...)
│       github.com/zclconf/go-cty@v1.15.0/cty/function/error.go:44
│ github.com/zclconf/go-cty/cty/function.Function.returnTypeForValues.func1()
│       github.com/zclconf/go-cty@v1.15.0/cty/function/function.go:226 +0x7b
│ panic({0x35268e0?, 0xc000c210e0?})
│       runtime/panic.go:785 +0x132
│ github.com/zclconf/go-cty/cty/function/stdlib.init.func12({0xc000acc480, 0xc000013ac8?, 0x3e197d8?})
│       github.com/zclconf/go-cty@v1.15.0/cty/function/stdlib/collection.go:173 +0x25f
│ github.com/zclconf/go-cty/cty/function.Function.returnTypeForValues({0xc0006d4688?}, {0xc000acc480, 0x2, 0x0?})
│       github.com/zclconf/go-cty@v1.15.0/cty/function/function.go:230 +0x778
│ github.com/zclconf/go-cty/cty/function.Function.Call({0x3e197d8?}, {0xc000acc480, 0x2, 0x2})
│       github.com/zclconf/go-cty@v1.15.0/cty/function/function.go:250 +0x7a
│ github.com/hashicorp/hcl/v2/hclsyntax.(*FunctionCallExpr).Value(0xc000792870, 0xc000a9d878)
│       github.com/hashicorp/hcl/v2@v2.22.1-0.20240924195505-78fe99307e88/hclsyntax/expression.go:528 +0x1acf
│ github.com/hashicorp/hcl/v2/hclsyntax.(*BinaryOpExpr).Value(0xc0003483f0, 0xc000a9d878)
│       github.com/hashicorp/hcl/v2@v2.22.1-0.20240924195505-78fe99307e88/hclsyntax/expression_ops.go:147 +0x122
│ github.com/hashicorp/terraform/internal/terraform.evalCheckRule({{0x3e21d88?, 0xc0008e5c20?}, 0xc0009aa060?, 0xc0006c9548?}, 0xc00082c420, {0x3e41878?, 0xc0009a6300?}, {{{{0x0, 0x0}}, {0x0, ...}}, ...}, ...)
│       github.com/hashicorp/terraform/internal/terraform/eval_conditions.go:120 +0xea
│ github.com/hashicorp/terraform/internal/terraform.evalCheckRules(0x5, {0xc0007b9380, 0x5, 0x3dda2e0?}, {0x3e41878, 0xc0009a6300}, {0x3e21d88, 0xc0008e5c20}, {{{{0x0, 0x0}}, ...}, ...}, ...)
│       github.com/hashicorp/terraform/internal/terraform/eval_conditions.go:53 +0x269
│ github.com/hashicorp/terraform/internal/terraform.(*nodeCheckAssert).Execute(0xc0006fa340, {0x3e41878, 0xc0009a6300}, 0x50?)
│       github.com/hashicorp/terraform/internal/terraform/node_check.go:169 +0x145
│ github.com/hashicorp/terraform/internal/terraform.(*ContextGraphWalker).Execute(0xc0007646e0, {0x3e41878, 0xc0009a6300}, {0x7f965fca0220, 0xc0006fa340})
│       github.com/hashicorp/terraform/internal/terraform/graph_walk_context.go:161 +0xb5
│ github.com/hashicorp/terraform/internal/terraform.(*Graph).walk.func1({0x3314920, 0xc0006fa340})
│       github.com/hashicorp/terraform/internal/terraform/graph.go:143 +0x7c3
│ github.com/hashicorp/terraform/internal/dag.(*Walker).walkVertex(0xc00051f320, {0x3314920, 0xc0006fa340}, 0xc0006fa3c0)
│       github.com/hashicorp/terraform/internal/dag/walk.go:384 +0x2d1
│ created by github.com/hashicorp/terraform/internal/dag.(*Walker).Update in goroutine 71
│       github.com/hashicorp/terraform/internal/dag/walk.go:307 +0xfb3
│ .
╵
```

おうふ。

できるんじゃないのかよー。。。

# 調べてみたこと

- 最初はよくわからなかったので `TF_LOG=DEBUG terraform plan` でログを出してみたんだけど役に立たなかった
- なぜなら Go の panic が出ているとおり、そこで落ちてるから。途中経過には問題がなかった
- `#35501` の中を見ると、`zclconf/go-cty` のバージョンアップをしているだけっぽいのでそっちをあたってみた
- [go-cty/cty/function/stdlib/collection.go at v1.15.0 · zclconf/go-cty](https://github.com/zclconf/go-cty/blob/v1.15.0/cty/function/stdlib/collection.go#L1459)
- [cty package - github.com/zclconf/go-cty/cty - Go Packages](https://pkg.go.dev/github.com/zclconf/go-cty@v1.15.0/cty#Value)
- なんか最近タグだけ打ってリリース作ってない？
- が、とりあえず対象の go-cty@1.15.0 で negative indices が使えるのは[間違いないようだ](https://github.com/zclconf/go-cty/compare/v1.14.4...v1.15.0)
- 実際のところ前述のログにもちゃんと go-cty@1.15.0 が使われているので、go-cty がバグっているか
- terraform の internal/ 下のコードがダメなのかと思って探してみた
- ぶっちゃけ一晩溶けたｗ

:::message alert
ここに広告が入ります（入りません（じゃあ続きはCMの後でってことで。。。
:::

# わかったこと

- たぶん原因は `hashicorp/hcl/v2@v2.22.1`
- なぜなら [hcl/go.mod at v2.22.0 · hashicorp/hcl](https://github.com/hashicorp/hcl/blob/v2.22.0/go.mod#L13) はまだ `go-cty v1.13.0` だったから
- [hcl/eval_context.go at main · hashicorp/hcl](https://github.com/hashicorp/hcl/blob/main/eval_context.go#L13) で cty の（v1.15とは）type が違うんだもの
- スタックトレースにはそういうとこまでは出力されない（これはGoのお作法ってゆうか、importまみれの弊害なんじゃないかとか古いタイプのおじさんは思っちゃうけど）から時間かかってしまった
- たぶん、Terraform v1.10.0-alpha の頃から乗ってるし、ぎりぎりのところで hcl もバージョンあげてから正式にリリースされるんじゃないかな
- ぶっちゃけ #35501 の変更内容にテストが入ってないのがね。。。
- 今までできなかったところをできるようにしたんならその分のテストは欲しいところ

# まとめ

- Terraform v1.10.0-beta1 で element function にネガティブインデックス、つまりマイナスの値が使えそう、だと思ったけどまだダメだったみたい
- hcl 側には go-cty をアップデートする issue も PR もないようだけど大丈夫かしら
- `#15582` を close したんだから `-1` が使えるようになったはず、のところから間違ってたらどうしようかな（英語でのニュアンスが汲み取れていない的な
- 10月は Go の勉強をしてたから結構読めるようになったんじゃないかと思ってるんだけど、どうかなぁ

テスト用のコードはここに

@[code](https://github.com/officel/zenn/tree/main/terraform/v1.10.0-beta1_element/)

おまけ。

@[card](https://x.com/terraform_jp/status/1852017547283140823)
