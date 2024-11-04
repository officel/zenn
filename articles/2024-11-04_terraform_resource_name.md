---
title: "terraform の細かすぎて伝わらない小ネタ リソースの命名規則"
emoji: "📛"
type: "tech"
topics: ["terraform", "naming"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- リソースの名前 `resource "{provider}_{resource_name}" "リソースの名前"` について（これがわかりやすいよね？）
- 実リソースの名前とは別の話（`name` プロパティや `Name` タグとは別）
- `this`,`default`,`current` 等にも意味があるよ、という話

# ちょっと前に

- [terraform での「this」の使用法: r/Terraform](https://www.reddit.com/r/Terraform/comments/zmrpwj/usage_of_this_in_terraform/)
- 定期的に発火する話題であり、実際↑の作成日もずいぶん前
- 小ネタとしてちょっと書いておくか的な（何か見た

# リソースの名前について

- 公式な（HCLの言語仕様的な意味での）名称はブロックラベル
- ブロックタイプの引数に過ぎない　[参考](https://developer.hashicorp.com/terraform/language#about-the-terraform-language)
- [Resources](https://developer.hashicorp.com/terraform/language/resources/syntax#resource-syntax)的には resource (local) name なので、リソースの名前、でいいでしょう

## 主な命名規則のページ

- 公式 [Style Guide - Configuration Language | Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/language/style#resource-naming)
- ベストプラクティス [Naming conventions | Terraform Best Practices](https://www.terraform-best-practices.com/naming)
- [Terraform を使用するためのベスト プラクティス | Google Cloud](https://cloud.google.com/docs/terraform/best-practices-for-terraform?hl=ja#naming-convention)
- [tflint-ruleset-terraform/docs/rules/terraform_naming_convention.md](https://github.com/terraform-linters/tflint-ruleset-terraform/blob/main/docs/rules/terraform_naming_convention.md)
- 古くて間違っているけどよく参照されてしまう [terraform-style-guide](https://github.com/jonbrouse/terraform-style-guide/blob/master/README.md#resource-naming)

## 基本のプラクティス

- 英数字小文字のみにする（大文字や普通に日本語が使えるが、使うなということ）
- すべてアンダーバーにする（ハイフンが使えるが、使うなということ）
- `{provider}_{resource_name}（リソースタイプ）` をリソースの名前に持ち込まない（`resource "aws_vpc" "vpc" {}`のようにするなということ）
- [ディレクトリを適切に分割](https://zenn.dev/terraform_jp/articles/2024-08-12_terraform_directories)していること
- つまり同一系統のリソースを複数作成するようなディレクトリ構造になっていないこと
- （同一系統のリソースを複数作成するなら個別の名付けが必要になる）
- 要はディレクトリを1つのモジュールのように扱うという感じ
- 個別の名前をつけることを否定はしない（必要なところだけにしとけよって思うだけ）
- 公式モジュールをしばらく眺めましょう（ネットミームでいうところの半年ROMれということ）

# よくある固定的な名称の使い分けについて

## this

- そのディレクトリで単一のリソースなら `this` にしておくことで（逆から）読み下しができる（`this (is) aws_vpc resource`ということ）
- 再利用性の高いコードにできる
- 迷ったら、ダメになるまで `this` にしておけば問題ない（極論）

## self

- `this` か `self` か、みたいな話が初期の頃にあった気がする
- `this` に軍配があがった（はず）
- `owners` プロパティなどのリテラルに `self` を入れるケースがあるので検索時に邪魔になる
- 強いポジションがなければ使わない

## main

- `self` 同様に初期の頃のモジュールで使われていた？
- 命名の意味合いとして不自然なことになりがち
- 同じディレクトリに `main` が複数あるのおかしい
- `this` や `default` などと混在させた時に本当に `main` か
- 強いポジションがなければ使わない

## default

- フラグでリソースを出し分けるようなケースで別々にリソースを書く場合の片方
- 管理の過程でデフォルトとして扱いたいと思った場合（`this`より適切だと思った場合）
- クラウド側リソースのデフォルトを使用する場合（AWS のデフォルトリソースは結構ある）
- AWSに限って言えば、デフォルトのリソースはリソースタイプに `default` が含まれているので、リソースの名前を `default` にはしない
- しないほうがいいと思うんだけど[aws_default_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc)とかね（悩ましいけどあくまで例だからね

## current

- 現在の状態等を表現したい場合
- 主に data source で使う
- [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)
- [aws_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)
- サンプルと異なる表現をしたい強いポジションがなければ `current` を使うのが望ましい

## available

- 有効無効の選択が必要な場合
- [aws_availability_zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones)
- オプトインされているものを抽出するなら[aws_regions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/regions)の例は `current` よりも適切かもしれない

## example

- 例示をする場合に使う
- 例は例だとわかっているので、できれば使わないほうが望ましい
- 実働するコードに使うべきではない

## test

- テスト的なコード
- `example` の代替
- やはり検索に難があるので、使わないほうが望ましい

# 適切な名付け

- 複数の同種のリソース群を別々に扱う場合には固有の名前をつける
- 実リソースにつける名前と同じにする
- 通常考えられる次のようなケース

  - aws subnet を複数管理（public/privateなど）
  - セキュリティグループを同時に複数管理（社内向け／社外向けなど）
  - IAM Role のような似て非なるものを複数管理（roleにつける名前と同じにする）

- そうなっていないほうが望ましいが次のようなケース

  - 一度に複数の EC2 インスタンスを管理（bastion,Web,Jenkinsを同時に作るとか）
  - 一度に複数の S3 Bucket を管理（s3 bucketの管理を甘く見てるとよくある）
  - Route53などのレコードを複数管理

# よくある悩みと工夫について

## 適切な名付けが思い浮かばない

- Tier で名前をつけられない（web,db などはよく例に上がるが、普通にそれぞれたくさん作る）
- 中途半端に命名規則から外れるなら、実リソースにつける名前と同じ名前にしておくとよい
- ナンバリングやリソース名から外れた Tier 名をつけると後々面倒になるので注意

## 複数同時に管理していて、実リソースの命名にはハイフンを使用している

- 同じようなグループの異なるリソースが多数ある
- xxx-yyy-zzz というリソースの場合

```hcl
// ◯ できる限り this にしておきたい
resource "type" "this" {
    name = "xxx-yyy-zzz"
}

// △ 検索時に name 等で直撃できるならアンダーバーにする（ルールを守る。が、変更時に難がある）
resource "type" "xxx_yyy_zzz" {
    name = "xxx-yyy-zzz"
}

// △ 検索時に name 等で直撃できなくてもアンダーバーにする（ルールを守る）
resource "type" "xxx_yyy_zzz" {
    // xxx-yyy-zzz のようにコメントを入れておくことで検索を容易にする
    name = var.name
}

// ✕ 検索時に name 等で直撃できない場合にコメントも書きたくない（稀によくある逸脱）
resource "type" "xxx-yyy-zzz" {
    // 命名規則からも外れるし、再利用性も下がるが、検索には有効
    // 実際のところ、同じ type のリソースをたくさん作ることはよくあるので対象のコードがどこか検索しやすくするのは重要
    name = var.name
}
```

## 名前を変えたい

- `moved block` で一発なので気にしない

```hcl
moved {
  from = aws_instance.example
  to   = aws_instance.this
}
```

# 最後に

- 命名は永遠のテーマなので万人に絶対の正解はない
- が、やらないほうがいいこと、はある
- 構造にもよるが、基本的にリソースの名前を変更するのは容易なので試してみるのもよい
- いずれにせよたくさん書いてみて自分たちの納得できるやりやすい形を探すのが大事
- 命名をリファクタリングして読みやすくしたり、ディレクトリ構成を変更して管理しやすくするのは大事な仕事
