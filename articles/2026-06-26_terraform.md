---
title: "tflint と terraform-docs のバッティングを回避"
emoji: "🐣"
type: "tech"
topics: ["terraform", "tflint", "terraform-docs", "pre-commit-terraform", "pre-commit"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- tflint v0.63.0 には tflint-ruleset-terraform v0.15.0 が同梱されている
- `terraform_comment_syntax` が強化されたってゆうか、`#` が **強制** されるようになった
- コード的には問題ないんだけど、terraform-docs で `header-from: main.tf` みたいな形で食ってる時にエラーになって困っていた
- 重い腰を上げて解決した時の記録ってワケ

# 時系列

- 2026-06-02 tflint-ruleset-terraform [v0.15.0](https://github.com/terraform-linters/tflint-ruleset-terraform/releases/tag/v0.15.0) リリース
- 2026-06-03 tflint [v0.63.0](https://github.com/terraform-linters/tflint/releases/tag/v0.63.0) リリース（上記を内包）
- 2026-06-03 これらを設定した pre-commit（正確には perk）の pre-commit-terraform による実行で、`terraform_comment_syntax` のエラーを確認
- さすがにすぐ修正されるだろうと放置
- 2026-06-04 tflint v0.63.1 がリリース（上記のエラーにはとくに言及なし）
- 以降今日まで更新なし
- 2026-06-20 回避策の検証終了
- 2026-06-26 やっと記事を書いてるってワケ

# 事象

- terraform-docs で `header-from` や `footer-from` などを使って、HCL（.tf）ファイルを読み込んでいる場合でのみ問題になる
- tflint を v0.63.0 にするとドキュメント用のブロックコメント `/* */` をエラーとして扱う
- 一言で言えば tflint(tflint-ruleset-terraform) が terraform-docs の仕様を気にしないでブロックコメントを強制的に行コメントにする変更を加えたのが問題
- （個人的には全員 [絶許](https://github.com/terraform-linters/tflint-ruleset-terraform/pull/298) であるｗ ）
- HCLファイルの読み込みを設定していない場合は問題ない
  - たぶん多くの場合でそうなのかなって
  - あとバージョンアップをしてないか（まぁ必要なければそんなにちょいちょいバージョンアップしないよね。しろよ）

# 回避策

- [header-from | terraform-docs](https://terraform-docs.io/user-guide/configuration/header-from/) の例にあるように、ドキュメント埋め込みの場合はマルチラインコメント（`/* */`）が必要
- それ以外の部分はシングルコメント `#` を使用するように指摘されるべき
- つまり対象の読み込み HCL ファイルのドキュメントコメント部分だけ tflint で無視したい

- 🙆‍♂️ うまくいった回避策はこう

```hcl:main.tf
/** tflint-ignore: terraform_comment_syntax
 * # Main title
 * 以下省略
 */

# 正直なところ微妙な見た目であるｗｗｗ
```

- 🙅 `terraform_comment_syntax` ルールを ignore することで回避はできる。が、できるだけ有効のままにしておくことを薦める
- terraform の公式ドキュメントでもコメントは `#` が推奨されているし、それはそれで正しいと思うため

```hcl:.tflint.hcl
plugin "terraform" {
  enabled = true
  version = "0.15.0"
}

rule "terraform_comment_syntax" {
  enabled = false
  # これで回避できるけど、するなということ
}
```

- 🙅‍♀️ うまくいかなかった例1

```hcl:main.tf
# # Main title
# 以下省略

# ブロックコメントをやめるとドキュメントに出力されない（ブロックコメントが必要って書いてあるしね）
```

- 🙅‍♀️ うまくいかなかった例2

```hcl:main.tf
/**
 * tflint-ignore: terraform_comment_syntax
 * # Main title
 * 以下省略
 */

# tflint は ignore できないしドキュメントにこのままでちゃうし（ただの出力行とみなされる）
```

- 🙅‍♀️ うまくいかなかった例3

```hcl:main.tf
# tflint-ignore: terraform_comment_syntax
/**
 * # Main title
 * 以下省略
 */

# tflint は ignore できたが、ドキュメントに出力されない（ファイルの先頭にブロックコメントが出現しないと処理されない？）
```

# その他の回避策

## terraform-docs のための HCL ファイルの読み込みをやめる

- `header-from` 等で main.tf 等を読み込ませなければいい
- そうはいっても過去資産。。。
- プライベートな terraform module がたくさんあって、全部この形式やねん
- AWS 系公式モジュール類は設定ファイル自体を置かなくなったしね（コードだけで出力する）

## 読み込みファイルを HCL ではないものにする

- HCL ファイルではなく `.adoc`, `.md`, `.txt` ファイルを使用する
- HCL ファイル以外のブロックコメントは tflint の対象外なのでうまくいく
- 設定ファイルと既存のコードを修正する必要があるし、コードとドキュメントを切り離すことになる
- 最初からドキュメントファイルに書けば済む

# まとめ

- terraform-docs にてコード中のドキュメントコメントを読み込む設定にしているケースの tflint error への対応策を書いた

```shell
Warning: [Fixable] Comments should begin with # (terraform_comment_syntax)
```

こんな感じのエラーの時

```hcl:main.tf
/** tflint-ignore: terraform_comment_syntax
 * # Main title
 * 以下省略
 */
```

こんな感じで回避することができた、という話

- 各ツールがそれぞれの主義主張で設定を変更することに対して、思うところはあっても文句は筋違いである
- （内心では激おこぷんぷん丸であるが詮ないことである）
- 1ユーザーとしてはがんばって回避策を探すしかないのである
- とりあえず回避できてよかった
