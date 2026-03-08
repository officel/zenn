---
title: "これから始める terraform-docs"
emoji: "📖"
type: "tech"
topics: ["terraform", "terraform-docs", "prek", "taskfiledev"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- これから terraform-docs を始める人向け
- まだ検証中の部分の相談

# terraform-docs

@[card](https://terraform-docs.io/)

- terraform の構成ファイル（\*.tf）からドキュメントを生成するツール
- 主に README.md を生成させる
- IaC の一環としても Platform Engineering の一環としてもドキュメント化は大事
- ドキュメント書いてないやついるぅ？　いねぇよなぁ（イメージ略）

# 経緯

- インフラ寄り SRE だったこともあって、自分たち向けにドキュメントを残せばよかったので使っていなかった
- 現職は PFE 寄りになって、開発者向けにドキュメントを用意する必要がある
- 現職のリポジトリは、以前は動作していたが GitHub への移行で自動化が漏れてだいぶ破れ鍋化した
- 構成と使い方を確認して自動更新を復旧したい

# 説明を省略すること

- インストールはお好みでどうぞ。[aqua](https://aquaproj.github.io/) が便利です
- main.tf のコメントを使用して README.md を生成します
- つまり markdown 以外の形式については省略します
- なるべく共通化することを目指しているので細かい調整も省略します
- recursive は処理しません

# 使用方法

```bash
# alias しておくとタイプ数が少なくて済む tfd まで打って tab で補完すればもっと楽
alias tfdocs='terraform-docs'

# バージョンの確認
tfdocs -v

# ヘルプ
tfdocs -h

# .tf ファイルのあるディレクトリで
tfdocs md .
```

# 設定ファイルの調整

- `.terraform-docs.yml` をリポジトリルートに置く
- [Configuration | terraform-docs](https://terraform-docs.io/user-guide/configuration/#options) からコピーして変更して利用している（コメントのついている行が変更点）

```yaml
formatter: "markdown" # markdown 固定

version: ""

header-from: main.tf
footer-from: ""

recursive:
  enabled: false
  path: modules
  include-main: true

sections:
  hide: []
  show: []

content: ""

output:
  file: "README.md" # README.md に固定
  mode: inject
  # markdown lint 向けに /n を追加して空行を入れている
  template: |-
    <!-- BEGIN_TF_DOCS -->\n
    {{ .Content }}\n
    <!-- END_TF_DOCS -->

output-values:
  enabled: false
  from: ""

sort:
  enabled: true
  by: required # 好みかもしれないけど必須項目が先にあるほうが見やすい

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: true # 必要ないセクションは非表示
  html: true
  indent: 2
  lockfile: false # .terraform.lock.hcl をリポジトリに含めない運用をしているので false
  read-comments: true
  required: true
  sensitive: true
  type: true
```

- `formatter` は `markdown` にしているが `markdown table` との差がわかっていない
- `version` はできれば常に最新を使いましょう程度で、必要ないなら指定しない
- `output.file` は指定すると標準出力が面倒（オプションで逆に外す必要がある）だけど利用回数をとった
- `output.template` は markdown lint でコンテンツやヘッダーの周りに空白行を必須にする設定をしているので改行処理をしている
- `sort.by` は必須項目優先で `required` にしている（昔は `required` が主流だった気がするけど、最近の公式モジュールはゼロコンフィグを目指してるのか required な input を無くしていってるよね）
- `settings.hide-empty` は `no xxx` になるセクションを出力しないように `true` に設定
- `settings.lockfile` は `.terraform.lock.hcl` によってバージョンを出力するが、常に最新のバージョンで更新できるようにリポジトリに含めていないので `false` に設定している。含めているなら `true` にしておくとよい

# 実行

```bash
tfdocs -c .terraform-docs.yml .
```

- 設定ファイルのパスを調整しないとダメ
- リポジトリのトップに置いても自動では読み込まない？
- `terraform-docs` だけで設定ファイルを自動で読み込んで処理して欲しいんだけど。。。

# pre-commit hook

- [pre-commit を使ってみよう #Git - Qiita](https://qiita.com/raki/items/5374a91dca4a3039094b) を昔書いた
- 先日 [prek を使ってみる ADR - alternative pre-commit -](https://zenn.dev/raki/articles/2025-10-19_prek_alternative_pre-commit) を書いた
- どちらも `.pre-commit-config.yaml` を読み込んで実行するので好きな方をどうぞ

```yaml
- repo: https://github.com/antonbabenko/pre-commit-terraform
  rev: v1.103.0
  hooks:
    - id: terraform_docs
      args:
        - "--args=--config=.config/.terraform-docs.yml"
# リポジトリルートに置いても自動で読み込まないのでリポジトリルートの .config/ 下に置いている
```

# 自動化（GitHub Action）

- pre-commit でも prek でもそのままワークフローに持っていくと楽
- [こんな感じ](https://github.com/officel/zenn/blob/main/.github/workflows/pre-commit.yml)
- このリポジトリでは terraform は扱ってないけども（プライベートかインターナルにしか置いてない）

# おまけのタスク

- 以前、[モダンなタスクランナーを求めて task (taskfile.dev) を使うまでの軌跡](https://zenn.dev/raki/articles/2024-05-30_task_runner) を書いた
- この go-task （サイトは taskfile.dev だしコマンドは task だし）を使うとこんなタスクで楽できる
- 前述のとおり設定ファイルが期待した動きをしないので、`-c` を指定するのが面倒なので書いた
- `task d` でリポジトリのどのディレクトリでも `terraform-docs` が実行できる
- 正直なところ何か勘違いをしているのかもしれないと思っているけど、今のところこれで動いてるからいいかなと

```yaml
tasks:
  docs:
    desc: Run terraform-docs
    aliases:
      - d
      - docs
    vars:
      CONFIG_FILE: ".config/.terraform-docs.yml"
      CONFIG_FILE_PATH: "{{relPath .USER_WORKING_DIR .TASKFILE_DIR}}/{{.CONFIG_FILE}}"
    cmds:
      - terraform-docs -c {{.CONFIG_FILE_PATH}} .
    dir: "{{.USER_WORKING_DIR}}"
    silent: false
```

# さらにおまけの prettier 対策

- VS Code 等で prettier を使用していると、terraform-docs の出力したマークダウンはテーブル等含めて結構ごにょる

```md:README.md
<!-- prettier-ignore-start -->
<!-- BEGIN_TF_DOCS -->

<!-- END_TF_DOCS -->
<!-- prettier-ignore-end -->
```

- こんな感じにしておけば、勝手に整形されなくなるのでどうぞ
