---
title: "これから始める tflint"
emoji: "🐣"
type: "tech"
topics: ["terraform", "tflint", "terraform-linters"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- これから tflint を始める人向け
- 導入時の決め事について

# tflint

@[card](https://github.com/terraform-linters/tflint)

- terraform の構成ファイルのプラクティスにしたがって lint してくれるツール
- こだわりどころによって揉める原因になる
- IaC の一環として、PR 時にチェックするようにしたい
- lint してねぇやついるぅ？いねぇよなぁ（イメージ略）

# 経緯

- 基本的に構成ファイルを作成する時点でテンプレートを用いるため、それなりのコードを書く自信がある
- もちろんそうではない人もいる
- 前職ではそれほど必要じゃなかったし重要視していなかったので使っていなかった
- 現職では元のコードを書いた人がいて tflint が実施されていたが、設定が肌にあわないのでできるだけ手直しすることにした
- こういう理由でこうします、を明示的にしたかった

# 説明を省略すること

- インストールはお好みでどうぞ。[aqua](https://aquaproj.github.io/) が便利です
- 成功時（エラー等がない時）は何も出力されないようにします

# 使用方法

```bash
# tflint は alias を作らない（pre-commitで処理するし明示的に処理する機会はそんなにない）

# バージョンの確認
tflint -v

# ヘルプ
tflint -h

# .tf ファイルのあるディレクトリで
tflint
```

# 設定ファイルの調整

```hcl
# .tflint.hcl
config {
  format = "compact"
}

plugin "terraform" {
  enabled = true
  version = "0.13.0"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
  # preset  = "recommended"  # default all
}

plugin "azurerm" {
  enabled = true
  version = "0.29.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}
```

- `config` block は出力を見やすくしたいので compact にしている（お好みで）
- `plugin "terraform"` block は組み込みなので source や version を指定しなくても使えますが、明示的にしておきたいので指定
- `preset` は常に `all` を使用する（`recommended` でお茶を濁さない）
- その他の plugin （ここでは `azurerm`）は使用状況に応じて設定する
- 処理自体はデフォルト設定ということ

# 実行

```bash
tflint -c .tflint.hcl
```

- preset や plugin で enabled = false にするなどがない限り `-c` はなくても大丈夫

# よくありそうな検討事項

- エラーに対処する方法はいくつかある

  - 🙆‍♂️ おとなしくファイルを作るかコードを修正するか ignore する
  - 🙍‍♂️ 該当ディレクトリに別の設定を置いてよける
  - 🙅‍♂️ コマンドライン引数でルールを無効にする

- 安易に個別に避けたりせず、すべての環境で統一した設定にしたがうのがよい

:::message
`# tflint-ignore:` で ignore できる
:::

## terraform_standard_module_structure

- preset を all にしたままにすると、input variables や outputs がないルートディレクトリでもファイルがないよエラーを出してくる
- 自作モジュールなどは問題ない（ファイルがあるのが正）が、ルートモジュールではそもそも input や output がない場合もある
- 個人的にはコメントを書いた中身のないファイルでもあったほうがよいと考えている

:::message alert
これを無効に設定しているのは tflint を使用する意味が半減してしまう。
ルートモジュールでは outputs.tf は必要ないケースが多いかもしれないが、lint しない弊害を考慮して検討して欲しい。
:::

- ちなみに [Standard Module Structure | Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/language/modules/develop/structure) には次のように書かれている

> main.tf, variables.tf, outputs.tf. These are the recommended filenames for a minimal module, even if they're empty. main.tf should be the primary entrypoint.
> （main.tf、ariables.tf、outputs.tf はたとえ空であっても最小限のモジュールに推奨されるファイル名です。 main.tf は主要なエントリポイントである必要があります。）

## required_version

- `terraform` block に `required_version` を書いていないとエラーがでる
- 2025 年 11 月現在なら `>= 1.13.0` にしてしまうのがよい（これで問題がでるようならそのディレクトリの見直しをしたほうがよい）

:::message alert
ここで `pessimistic constraint operator`（`~>`）を使用すると後々面倒で手間がかかるので注意する。
ましてや固定バージョンの使用は陳腐化と後での対処に手間がかかるので避ける。バージョンを固定しろって意見とは仲良くできぬ。
:::

## terraform_typed_variables

- input variable の type を書いてないとエラーがでる
- [terraform アンチパターン variable](https://zenn.dev/terraform_jp/articles/2025-10-03_terraform_variables) という記事を書いた
- そもそも variables を使う必要があるかを検討する
- variable を使うなら description や type くらい書いておくべき

# pre-commit hook と task

- [これから始める terraform-docs](https://zenn.dev/terraform_jp/articles/2025-10-23_terraform-docs) で terraform-docs 用の hook と pre-commit について書いたので説明は省略
- pre-commit hook

```yaml
- repo: https://github.com/antonbabenko/pre-commit-terraform
  rev: v1.103.0
  hooks:
    - id: terraform_tflint
      args:
        - --args=--config=__GIT_WORKING_DIR__/.tflint.hcl
```

- task

```yaml
tasks:
  lint:
    desc: Run tflint
    aliases:
      - l
      - lint
    vars:
      CONFIG_FILE: ".tflint.hcl"
      CONFIG_FILE_PATH: "{{relPath .USER_WORKING_DIR .TASKFILE_DIR}}/{{.CONFIG_FILE}}"
    cmds:
      - tflint -c {{.CONFIG_FILE_PATH}}
    dir: "{{.USER_WORKING_DIR}}"
    silent: false
```

# 追加のプラグイン（ルールセット）

- [tflint-ruleset · GitHub Topics](https://github.com/topics/tflint-ruleset)
- 必要に応じてルールセットを追加する
- ちなみに [Repository search results](https://github.com/search?q=tflint-ruleset&type=repositories) のほうがいいかも
- たとえば [Azure/tflint-ruleset-azurerm-ext](https://github.com/Azure/tflint-ruleset-azurerm-ext) は Topics には乗ってない

# 主観

- 書いておいてあれだけど tflint と Sentinel や OPA とかぶる部分についてどう考えるか整理できていない
- 動くこと、丁寧であること、親切であること、統一されていること、などの優先順位や実務における時間的猶予、修正に対するアウトカムの考え方なども一概にこう、とは言い難い
- やってないよりやってあるほうが前に進みやすい（だろう）と思っている
