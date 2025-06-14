---
title: "Taskfile.yml のスタイルガイドに沿ったテンプレート"
emoji: "💂"
type: "tech" # tech or idea
topics: ["taskfile", "task", "go-task", "taskfiledev"]
published: true
---

# tl;dr

- [Style guide | Task](https://taskfile.dev/styleguide/)
- スタイルガイドを元にしたテンプレートでも作っておこうかなって

# スタイルガイドの要約

- 主要セクションは推奨される順序にする
- インデントはスペース 2 つ
- メインセクションは空行で区切る
- タスクを空行で区切る
- 変数名には大文字だけ
- 変数のテンプレートに空白を使わない
- タスク名にはケバブケースを使う
- タスクの名前空間と名前はコロンで区切る
- 複数行のコマンドの代わりに外部スクリプトを使う

個人的には最後のやつ以外はそのままでいいかなって。

複数行のコマンドをひとまとめにするために Task を使いたいので、外部スクリプト化して呼び出し、では Task の魅力が半減しちゃうんじゃないかって。

異論は認める。好きにして。

# 個人的に追加のガイド

- 先頭におまじないと置いておくと言語サーバが使える IDE（VS Code 等）で幸せになれる
- `default` task は不用意なタスク実行を避けて、タスクのリスト表示にする
- `util` 名前空間に共通処理を書いて include で共有するとよい（ベストなやり方が見つかっていないので今のところ同じファイルに書いている）
- よく使うものは `desc` をなしにしてリストから消去
- 同じように `silent: true` で出力を抑制しておくと見やすい
- `alias` の命名規則を作っておくと便利
- `examples` か `test` 名前空間にテンプレートを書いておくとコピーしやすい
- テンプレートに書いたように `examples` タスクで名前空間のタスクを一斉に処理すると楽

# スタイルガイドに沿ったテンプレート

```yaml:Taskfile.yml
# yaml-language-server: $schema=https://taskfile.dev/schema.json
# https://taskfile.dev/

version: '3'

# includes:

# optional configurations (output, silent, method, run, etc.)

# vars:
## use UPPERCASE

# env:

tasks:
  default:
    cmd: task --list --sort alphanumeric
    silent: true

  util:list:
    # desc: view all tasks
    summary: |
      全タスクの出力
    aliases:
      - ul
      - ls
    cmd: task --list-all --sort alphanumeric
    silent: true

  util:summary:
    # desc: view summary of all tasks
    summary: |
      全タスクのサマリー出力
    aliases:
      - us
      - la
    cmd: task --list-all --sort alphanumeric -j | jq -cr ".tasks[].name" | xargs -i sh -c 'task --summary {}; echo "\n---\n"'
    silent: true

  examples:
    aliases:
      - e
    cmds:
      - task: examples:prompt-001

  examples:prompt-001:
    prompt: "continue?"
    cmds:
      - echo {{.TASK}}
```

# まとめ

- 本家のスタイルガイドに従ったテンプレートを作成した
- 独自のプラクティスを追加している
- アドカレが近いけどそこまで引っ張るネタでもないので公開

@[card](https://qiita.com/advent-calendar/2024/go-task)
