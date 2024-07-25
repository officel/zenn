---
title: "terraform で細かすぎて伝わらない小ネタ urlencode()"
emoji: "🤏"
type: "tech"
topics: ["terraform", "urlencode"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- terraform で NewRelic や DataDog 等の Synthetics テストを書く時に渡すURL
- エンコードしないとダメなところがあった（それはそう
- 同僚氏がワンライナーでしゅっと対応した（業務的には問題なし）
- URLによってはワンライナーではうまくいかないケースがあったので、ちょっと試してみた

# ことのはじまり

- 同僚氏が NewRelic の Synthetics チェックを Terraform で書いた
- 対象のURLがたくさんあったので、モジュールにしてURLを渡すようにしていた
- パスに日本語を含んでいるURLがあって、applyしたらエラーになってしまった
- モジュール側でワンライナーを書いて対応して事なきを得た
- 対象のURLはある程度の法則があって、それに対応するワンライナーだったが、法則から外れたURLが今後増えたら耐えられないなと思った

# ワンライナー

```hcl
    # 前後は省略
    url = join("://", [for i in split("://", var.uri) : join("/", [for j in split("/", i) : urlencode(j)])])
```

- ぱっと見は問題ないように見える
- ドメインの後ろにポートがあるケース
- query_string があるケース
- の2点で、`:` と `?` を無駄にエンコードしてしまう

というわけでちょっと見てみようと思った

# ざっくりテストコード

```hcl
variable "uri" {
  description = "readable uri string"
  type        = string

  # プロトコルと末尾スラッシュ
  # default = "http://www.example.com"
  # default = "http://www.example.com/"
  # default = "https://www.example.com"
  # default = "https://www.example.com/"
  # ポートの有無
  # default = "https://www.example.com:443"
  # default = "https://www.example.com:443/"
  # path があるとかないとか
  # default = "https://www.example.com/path1"
  # default = "https://www.example.com/path1/"
  # default = "https://www.example.com/ぱす1/"
  # default = "https://www.example.com/ぱす1/ぱす2"
  # default = "https://www.example.com/ぱす1/ぱす2/"
  # query_string があるとかないとか
  # default = "https://www.example.com/ぱす1/ぱす2/index"
  # default = "https://www.example.com/ぱす1/ぱす2/index?"
  default = "https://www.example.com/ぱす1/ぱす2/?test="
  # default = "https://www.example.com/ぱす1/ぱす2/?test=aaa"
  # default = "https://www.example.com/ぱす1/ぱす2/?あいう=かきく"
  # default = "https://www.example.com/ぱす1/ぱす2/?あいう=かきく&さしす=たちつ"
  # 結局のところ文字列をどこで使いたいかによるので、利用先に合わせて処理する必要がある
}

// URI を encode する
locals {
  uri_slash_split = split("/", var.uri)
  // http, https or others
  uri_protocol = local.uri_slash_split[0]
  // ドメイン部分。あるなら :8080 等のポートも含んだまま
  uri_domain = local.uri_slash_split[2]
  // ドメインの後ろに / がいるかどうか
  uri_domain_slash = (length(local.uri_slash_split) > 3 || endswith(var.uri, "/")) ? "/" : ""

  // ドメインより後ろ（パス部分とquery_string部分）
  uri_path_all = length(local.uri_slash_split) > 3 ? join("/", slice(local.uri_slash_split, 3, length(local.uri_slash_split))) : ""
  // query_string で分割
  uri_path_split = split("?", local.uri_path_all)
  // query_string より前（プログラム名も含めたパス部分）
  uri_path = split("/", local.uri_path_split[0])
  // slash を除いて urlencode してパス文字列として１つに戻す
  uri_path_encode = join("/", [for j in local.uri_path : urlencode(j)])
  // query_string の ? がいたかどうか
  uri_qs_mark = (length(local.uri_path_split) > 1 || endswith(var.uri, "?")) ? "?" : ""

  // 最初に出現する ? 以降は query_string（文字列としての ? があるケースがあるので ? で join して戻す）
  uri_qs_all = length(local.uri_path_split) > 1 ? join("?", slice(local.uri_path_split, 1, length(local.uri_path_split))) : ""
  // query_string を分割（&で項目に分かれている）
  uri_qs_split = split("&", local.uri_qs_all)
  uri_qs = join("&",
    [for j in local.uri_qs_split :
      # 変数名はともかく値は urlencode したほうがいい気もするけど、
      # それをここでバラして処理して誰がうれしいっけ？ってなって頓挫
      j
    ]
  )

  encode = format(
    "%s//%s%s%s%s%s",
    local.uri_protocol,
    local.uri_domain,
    local.uri_domain_slash,
    local.uri_path_encode,
    local.uri_qs_mark,
    local.uri_qs
  )
}

output "uri" {
  value = [
    // 入力値
    var.uri,
    // local でわかりやすく処理
    local.encode,

    // 元のワンライナー（ポートが含まれていたり、query_string があると余計にエンコードしてしまう）
    join("://", [for i in split("://", var.uri) : join("/", [for j in split("/", i) : urlencode(j)])])
  ]
}

```

めんどくさｗｗｗ

# terraform では

- [urlparse function to get url parts · Issue #23893 · hashicorp/terraform](https://github.com/hashicorp/terraform/issues/23893)
- 検索するといくつか似たような話はある

# 頓挫

- そもそも目的に合わせてエンコードしないと食う側も困る（qsをエンコードしたほうがいいかとか、そもそもリダイレクトURI的なqsだったらどうかとか）
- とりあえず必要十分なところまでは検討したので qs をバラしてエンコードするところはそのままにしておいた

# まとめではないけれど

- provider functions も生えたことだしこの手のことをごにょごにょするの書くのも楽しいかもしれない
- 末尾スラッシュを残す残さないをもうちょいうまく書けないかしら
- query_string もちゃんとしたぜってコードをお待ちしていますｗ
