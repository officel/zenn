---
title: "GitHub Actions と pre-commit-config を SHA pinning"
emoji: "📌"
type: "tech" # tech or idea
topics: ["github", "githubactions", "pre-commit", "taskfile.dev"]
published: true
---

# tl;dr

- 先週 Trivy がニ度目のサプライチェーン攻撃を受けた（詳細はぐぐってね）
- ぎりぎりでフェイクバージョンのインストールおよび実行は避けられた
- GitHub Actions Workflows の各 action のバージョンと .pre-commit-config.yaml の各 rev のバージョンをハッシュで固定する機運
- というわけで対応した

# はじめに

- GitHub Actions のバージョン指定に手抜きをしていた自覚のある人はこの機会に HASH でピン留めしておくのが安全
- pre-commit（Goで書かれている） から Rust 実装である prek への乗り換えを推奨

@[card](https://zenn.dev/raki/articles/2025-10-19_prek_alternative_pre-commit)

- .pre-commit-config.yaml の rev も HASH でピン留めしておくのが安全（かも）
- ひとつずつバージョンアップの PR が出ると運用が大変と思っている（た）人（そう、わたしです）は Dependabot にがんばってもらう
- つい[先日対応された](https://github.blog/changelog/2026-03-10-dependabot-now-supports-pre-commit-hooks/)のでいい機会です
- [koki 先生の記事](https://zenn.dev/kou_pg_0131/articles/gha-should-be-pinned)に目を通しておくとよいでしょう

# 準備

- [prek](https://github.com/j178/prek) は前述の記事のとおり好きな方法でインストールしておきましょう（aquaが楽です）
- [pinact](https://github.com/suzuki-shunsuke/pinact) をインストールしておきましょう（aquaが楽ですｗ）
- [Taskfile](https://taskfile.dev/) があると便利です（インストールはaquaが楽ですｗｗ）

# やること

- コマンド的には次のとおり

```bash
# pre-commit（既存）のアンインストール
pre-commit uninstall

# prek のインストール
prek install

# .pre-commit-config.yaml のアップデートとハッシュで指定
prek autoupdate --freeze

# (おまけ) 最新化した上で全実行
prek run -a

# pinact で GitHub Actions ワークフローのアクションの各バージョンをハッシュで指定
pinact run -u
```

- pre-commit ワークフロー（`.github/workflows/pre-commit.yml`）でも prek を使用する
- 下記ファイルを置けばOK（Pythonのバージョンは必要にあわせてどうぞ）

```yaml:.github/workflows/pre-commit.yml
name: pre-commit

on:
  workflow_dispatch:
  pull_request:

jobs:
  pre-commit:
    permissions:
      contents: read
      pull-requests: read
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - uses: actions/setup-python@a309ff8b426b58ec0e2a45f0f869d46889d02405 # v6.2.0
        with:
          python-version: "3.12"
      - uses: j178/prek-action@79f765515bd648eb4d6bb1b17277b7cb22cb6468 # v2.0.0
```

- Dependabot で pre-commit の更新を自動化する（`.github/dependabot.yml`）
- 下記ファイルを置けばOK（intervalとgroupsは運用にあわせてどうぞ）

```yaml:.github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    groups:
      dependencies:
        patterns:
          - "*"
  - package-ecosystem: "pre-commit"
    directory: "/"
    schedule:
      interval: "weekly"
    groups:
      dependencies:
        patterns:
          - "*"
```

- 前述の koki 先生の記事にもあったとおり、GitHub のリポジトリの設定で `Require actions to be pinned to a full-length commit SHA` をチェックしておくといいでしょう
- 以下は蛇足ですけど設定しておくといいでしょう

  - Allow auto-merge を有効にする
  - Automatically delete head branches を有効にする
  - （使っているなら）ブランチプロテクションのルールで `Require status checks to pass before merging` を pre-commit 付きで有効にする
  - （今後はこっち）ブランチルールセットで保護対象のブランチのルールで `Require status checks to pass` の `Do not require status checks on creation` を pre-commit 付きで有効にする

# ちまちまやるのだるっ

- ちまちま手持ちのリポジトリで個別に確認、処理するのだるい
- [グローバルなタスク](https://github.com/officel/dotfiles/pull/52) を用意して楽をした

```yaml:~/Taskfile.yaml
# yaml-language-server: $schema=https://taskfile.dev/schema.json
version: "3"

# home ディレクトリに配置してグローバルな作業を行う
# リポジトリに既に taskfile が存在する場合は `t -g` で呼べる

# vars:

tasks:
  default:
    cmds:
      - echo "This is {{.TASKFILE}} at v{{.TASK_VERSION}}"
      - task --list --sort alphanumeric -t {{.TASKFILE}}
    silent: true

  repos:use_prek:
    desc: "prek への切替実行"
    summary: |
      - pre-commit を prek へ切り替える。
      - 何度実行しても問題ない。
      - WF の名前は pre-commit に統一する（grep でチェック）
    aliases:
      - up
    cmds:
      - pre-commit uninstall
      - prek install
      - prek autoupdate --freeze
      - pinact run -u
      - git grep -i -p "prek" || echo "No 'prek' found in the repository."
      - grep "groups" .github/dependabot.yml || echo "No 'groups' found in .github/dependabot.yml."
    dir: "{{.USER_WORKING_DIR}}"
```

- このファイルをホームディレクトリに置いておけば、taskfile.yml を置いていないどこからでも呼べるし、-g オプションですでにタスクのあるリポジトリでも問題なく使えます
- `alias t="task"` しておけば、`t -g up` とするだけでOK

# 結果

- 普段からなるべく使わなくなったリポジトリは掃除しているつもりなんだけど、現在生きている個人管理の30リポジトリについて適応済
- pre-commit 自体が不要になったので削除できる（した）（prekと比較運用するつもりで両方使っていた）
- ぶっちゃけ慣れないとハッシュ指定は若干見にくい（コメントでリリースバージョンが書かれているのでPRで差分見る感じではそんなに問題ない）
- ついでに細々としたリポジトリの掃除もできてよかった
- 週明けからは職場のリポジトリも同じようにピン留め、かなぁ。。。
- 対象リポジトリ数が多いと大変だけど、安全には変えられないのでがんばりましょう
