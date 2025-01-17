---
title: "terraform test -junit-xml を試してみる"
emoji: "📝"
type: "tech"
topics: ["terraform", "test"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- terraform v1.6.0 から test サブコマンドが使える
- terraform v1.9.0-alpha の test サブコマンドに `-junit-xml` が追加された
- 中身を確認してみた

# terraform test

terraform v1.6.0 から [Test サブコマンド](https://developer.hashicorp.com/terraform/language/tests) を使って単体テストみたいなことができるようになったのは記憶に新しいところ。
先日 v1.9.0-alpha がビルドされて `-junit-xml` オプションによって、junit 形式の結果が出力できるようになったそうなので、ブログ記事にちょうどいいからやってみました。

# terraform/v1.9.0-a/test

この記事の [リポジトリ](https://github.com/officel/zenn) にコードは置いてあります。

:::message
後で手直しするの面倒なので terraform block は置いていません。実行時は terraform のバージョンが 1.9.0-alpha 以上であることを確認してください。
:::

まずはテストに使う変数を用意しましょう。見てのとおり validation で `@` の有無だけを確認しています。これは test の本筋とは関係ありません。

```hcl:variable.tf
variable "email" {
  description = "Your e-mail address."
  type        = string

  validation {
    error_message = "Correct email address is required."
    condition     = can(regex("@", var.email))
  }
}
```

次が test のファイル。拡張子は `tftest.hcl` (か`tftest.json`) です。入力された変数の値が、`gmail.com` で終わっていることを確認してみます。

```hcl:variable.tftest.hcl
run "allow_only_gmail_com" {

  command = plan

  assert {
    condition     = endswith(var.email, "gmail.com")
    error_message = "Only available domain is gmail.com."
  }

}
```

さくっと plan して動作確認。`@` を入れないと怒られます。

```bash
test $ terraform plan
var.email
  Your e-mail address.

  Enter a value: test


Planning failed. Terraform encountered an error while generating this plan.

╷
│ Error: Invalid value for variable
│
│   on variable.tf line 1:
│    1: variable "email" {
│     ├────────────────
│     │ var.email is "test"
│
│ Correct email address is required.
│
│ This was checked by the validation rule at variable.tf:5,3-13.
╵
```

`@` を入れれば通ります。

```bash
test $ terraform plan
var.email
  Your e-mail address.

  Enter a value: test@


No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```

plan が通るのを確認したのでさくっと test してみましょう。

```bash
test $ terraform test
variable.tftest.hcl... in progress
  run "allow_only_gmail_com"... fail
╷
│ Error: No value for required variable
│
│   on variable.tf line 1:
│    1: variable "email" {
│
│ The module under test for run block "allow_only_gmail_com" has a required variable "email" with no set value. Use a -var or -var-file command line argument or add this variable into a "variables" block within the test file or run block.
╵
variable.tftest.hcl... tearing down
variable.tftest.hcl... fail

Failure! 0 passed, 1 failed.
```

test の時はインタラクティブに入力できないので variable に値入れろって怒られますね。

```bash
test $ terraform test -var=email=
variable.tftest.hcl... in progress
  run "allow_only_gmail_com"... fail
╷
│ Error: Invalid value for variable
│
│   on variable.tf line 1:
│    1: variable "email" {
│     ├────────────────
│     │ var.email is ""
│
│ Correct email address is required.
│
│ This was checked by the validation rule at variable.tf:5,3-13.
╵
variable.tftest.hcl... tearing down
variable.tftest.hcl... fail

Failure! 0 passed, 1 failed.
```

空だと validate で怒られます。

```bash
test $ terraform test -var=email=test@
variable.tftest.hcl... in progress
  run "allow_only_gmail_com"... fail
╷
│ Error: Test assertion failed
│
│   on variable.tftest.hcl line 6, in run "allow_only_gmail_com":
│    6:     condition     = endswith(var.email, "gmail.com")
│     ├────────────────
│     │ var.email is "test@"
│
│ Only available domain is gmail.com.
╵
variable.tftest.hcl... tearing down
variable.tftest.hcl... fail

Failure! 0 passed, 1 failed.
```

`@` を渡すと validate は通って、テストでエラーになりますね。

```bash
test $ terraform test -var=email=test@ -junit-xml=result.xml
╷
│ Warning: JUnit XML output is experimental
│
│ The -junit-xml option is currently experimental and therefore subject to breaking changes or removal, even in patch releases.
╵
variable.tftest.hcl... in progress
  run "allow_only_gmail_com"... fail
╷
│ Error: Test assertion failed
│
│   on variable.tftest.hcl line 6, in run "allow_only_gmail_com":
│    6:     condition     = endswith(var.email, "gmail.com")
│     ├────────────────
│     │ var.email is "test@"
│
│ Only available domain is gmail.com.
╵
variable.tftest.hcl... tearing down
variable.tftest.hcl... fail

Failure! 0 passed, 1 failed.

test $ cat result.xml
<?xml version="1.0" encoding="UTF-8"?><testsuites>
  <testsuite name="variable.tftest.hcl" tests="1" skipped="0" failures="1" errors="0">
    <testcase name="allow_only_gmail_com" classname="variable.tftest.hcl" time="0.001085105">
      <failure message="Test run failed"></failure>
      <system-err><![CDATA[
Error: Test assertion failed

  on variable.tftest.hcl line 6:
  (source code not available)

Only available domain is gmail.com.
]]></system-err>
    </testcase>
  </testsuite>
</testsuites>
```

`-junit-xml=result.xml` としてテスト結果を junit 形式で出力してみました。なるほど。

```bash
test $ terraform test -var=email=test@gmail.com -junit-xml=result.xml
╷
│ Warning: JUnit XML output is experimental
│
│ The -junit-xml option is currently experimental and therefore subject to breaking changes or removal, even in patch releases.
╵
variable.tftest.hcl... in progress
  run "allow_only_gmail_com"... pass
variable.tftest.hcl... tearing down
variable.tftest.hcl... pass

Success! 1 passed, 0 failed.

test $ cat result.xml
<?xml version="1.0" encoding="UTF-8"?><testsuites>
  <testsuite name="variable.tftest.hcl" tests="1" skipped="0" failures="0" errors="0">
    <testcase name="allow_only_gmail_com" classname="variable.tftest.hcl" time="0.001441305"></testcase>
  </testsuite>
</testsuites>
```

最後に正常終了する形で実行してみました。よさげですね。

# まとめ

- terraform test コマンドで junit なテスト結果を出力できるようになった（CIに食わせるとちょっとうれしい）
- 正常時は気にならないけどエラー時はテストファイル名と対象の行番号、エラーメッセージが出力される（将来的にはエラー部分のソースも出力されるようになるのかな）

# 感想的な

- 一般的（？）な terraform 運用で test をしっかり書くユースケースは相変わらずわからない
- モジュールはまたちょっと違う観点でテストを書くと思うので、junit レポートが出せるとはかどるのかもしれない
- terraform-jp のパブリケーションに記事がないとさみしいのでがんばって書いたｗ
