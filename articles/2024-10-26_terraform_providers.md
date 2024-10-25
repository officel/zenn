---
title: "terraform の細かすぎて伝わらない小ネタ terraform providers"
emoji: "🖥"
type: "tech"
topics: ["terraform","providers"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- terraform の使ったことのないサブコマンドを使ってみる遊び
- 今回は `providers`
- 普段使う理由はあまりないかな

# providers サブコマンド

```bash
$ terraform providers -h

Usage: terraform [global options] providers [options] [DIR]

  Prints out a tree of modules in the referenced configuration annotated with
  their provider requirements.

  This provides an overview of all of the provider requirements across all
  referenced modules, as an aid to understanding why particular provider
  plugins are needed and why particular versions are selected.

Options:

  -test-directory=path  Set the Terraform test directory, defaults to "tests".


Subcommands:
    lock      Write out dependency locks for the configured providers
    mirror    Save local copies of all required provider plugins
    schema    Show schemas for the providers used in the configuration
```

# 実際の例

```bash
$ terraform providers

Providers required by configuration:
.
├── provider[registry.terraform.io/hashicorp/aws]
├── provider[registry.terraform.io/hashicorp/template]
├── provider[terraform.io/builtin/terraform]
├── module.alb
│   └── provider[registry.terraform.io/hashicorp/aws] >= 5.33.0
├── module.alb_sg
│   └── provider[registry.terraform.io/hashicorp/aws] >= 3.29.0
├── module.ec2
│   └── provider[registry.terraform.io/hashicorp/aws] >= 3.24.0
└── module.sg
    └── provider[registry.terraform.io/hashicorp/aws] >= 3.29.0

Providers required by state:

    provider[terraform.io/builtin/terraform]

    provider[registry.terraform.io/hashicorp/aws]

    provider[registry.terraform.io/hashicorp/template]
```

なるほど。

```bash
terraform providers schema -json
```

- プロバイダーのスキーマが json で出力できる
- 大きいので注意
- ドキュメントとの差があるかも
- うまく使えばドキュメントページを見なくても中身がわかるかも（VS Code 等で補完してれば出力されるものと同じもの）

```bash
$ terraform providers schema -json | yq -p json -o yaml
format_version: "1.0"
provider_schemas:
  registry.terraform.io/hashicorp/random:
    provider:
      version: 0
      block:
        description_kind: plain
    resource_schemas:
      random_id:
        version: 0
        block:
          attributes:
            b64_std:
              type: string
              description: The generated id presented in base64 without additional transformations.
              description_kind: plain
              computed: true
            b64_url:
              type: string
              description: 'The generated id presented in base64, using the URL-friendly character set: case-sensitive letters, digits and the characters `_` and `-`.'
              description_kind: plain
              computed: true
（省略）
```

- 構造とか考えかたとか勉強になる
- jq で引っこ抜くより yaml でファイルにリダイレクトしてみたほうが手っ取り早いかも（個人の感想）

# まとめ

- 普段何気なく使ってるけど、こういう情報があーなってこーなってを知るいい機会
- 常に最新化しないで使っているケースではこの辺りの情報が参考になるかもしれない（なるとは言ってない）
- `terraform -h` の他のサブコマンドでも遊んでみよう
