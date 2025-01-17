---
title: "terraform で細かすぎて伝わらない小ネタ regexall"
emoji: "*️⃣"
type: "tech"
topics: ["terraform", "正規表現"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- terraform で長い文字列を分割したい
- DNS Record で DKIM 用のテキストを分割する時とか

@[card](https://developer.hashicorp.com/terraform/language/functions/regexall)
@[card](https://developer.hashicorp.com/terraform/language/functions/compact)

# code

```hcl:main.tf
locals {
  # 長い文字列
  long_text = "123456789a123456789b123456789c123456789d123456789e123456789f123456789g123456789h123456789i123456789j123456789k123456789l123456789m123456789n123456789o123456789p"

  # 指定の長さの文字列の配列を作る（わかりやすく 10 にしてある。好きな長さに切ってよい）
  out = compact(regexall(".{1,10}", local.long_text))
}

output "long_text" {
  value = local.out
}

locals {
  # マルチバイトの長い文字列（50字にしたかっただけなので1音足りないとかなしね）
  long_text_m = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもや📝ゆ📝よらりるれろわ📝を📝ん"

  # 指定の長さの文字列の配列を作る（１文字ずつ数えることに注意）
  out_m = compact(regexall(".{1,5}", local.long_text_m))
}

output "long_text_m" {
  value = local.out_m
}
```

# output

```bash
$ terraform output
long_text = tolist([
  "123456789a",
  "123456789b",
  "123456789c",
  "123456789d",
  "123456789e",
  "123456789f",
  "123456789g",
  "123456789h",
  "123456789i",
  "123456789j",
  "123456789k",
  "123456789l",
  "123456789m",
  "123456789n",
  "123456789o",
  "123456789p",
])
long_text_m = tolist([
  "あいうえお",
  "かきくけこ",
  "さしすせそ",
  "たちつてと",
  "なにぬねの",
  "はひふへほ",
  "まみむめも",
  "や📝ゆ📝よ",
  "らりるれろ",
  "わ📝を📝ん",
])
```

# 小ネタ

@[card](https://github.com/brightbock/dns-dkim-tf/pull/3/files)

- ちょっと（？）前に見かけて残念だなって手直しPR送った時に使った
- そんなに出番はないんだけど、ブログ記事のネタとして掘り起こした
