---
title: "GitHub のリポジトリを掃除しよう"
emoji: "👻"
type: "tech" # tech or idea
topics: ["gh", "github"]
published: true
---

# tl;dr

- 振り返りの一環でスキルの再チェック
- GitHub の掃除をしながら GitHub CLI gh を使いこなす

# リポジトリを掃除する

## 主な目的や効能

- 要らないものを捨てる（archive or delete）
- 整ってないものを整える
- 見逃していたものを見つける
- ちょっとしたスキルアップ（gh コマンドの使い方や最新化）

# 手順

## 省略: gh コマンドのインストールやログイン

- gh コマンドは GitHub CLI のこと
- インストールはバージョンマネージャー経由にすると楽

```bash
gh auth login

# active user の確認
gh auth status

# ユーザー切り替え（個人のアカウントとは別に EMU などを利用している時に便利）
gh auth switch
```

## gh コマンドでリポジトリ一覧を取得する

```bash
gh repo list
```

- `Showing 30 of 137 repositories in` のように出たら全部リストできていない

## リポジトリ一覧を最大 1000 件まで取得する

```bash
gh repo list --limit 1000
```

- `UPDATED` が年単位のものはアーカイブを検討する
- `archived` になっているものは削除を検討する

:::message
削除すると復元できないので、本当に不要なものだけ削除する。
アーカイブも邪魔だけど、フィルターで非表示にできるので、迷ったらアーカイブにする。
気が向いたらアーカイブ済の掃除は別途やる。
:::

## 余談：アーカイブとフォークのフィルター

```bash
gh repo list --archived
gh repo list --fork
# archived ではないのは --no-archived だが、fork ではないのは --source
gh repo list --no-archived --source
```

:::message
fork がないってことは概ね OSS 貢献的な活動をしていないということ（のはず。ちゃんと削除していれば別）
あとは言わなくてもわかるな？
:::

## 気を取り直して現在有効なリポジトリを一覧

```bash
gh repo list --no-archived --source --limit 1000

# 毎回打つのは面倒なので alias にして楽をする
gh alias list
gh alias set 'repo mine' 'repo list --no-archived --source --limit 1000'
gh repo mine
```

:::message
repo set-default でもいいんだけど、あとで外すのが面倒になったり混乱したりするので alias のほうが無難に思える
:::

## 各リポジトリの掃除を検討する

- `DESCRIPTION` には説明を追加する
- `private` と `public` のバランスを考える
- `UPDATED` が古いものはメンテナンスを検討する

```bash
# リポジトリを指定してブラウザで開く
gh browse --repo officel/zenn

# アーカイブする
gh repo archive my/old-repo
```

## Topics を活用する（今日の本題）

- リポジトリに Topics を設定しておくと、あとで探しやすくなる。整理するのにも使える
- ChatGPT に聞いたら間違いばっかりで、仕方がないのでシェルを書いた

```bash:test.sh
#! /bin/env bash

# Repositories owner (user or organization). Empty means current user.
SHOPT_OWNER=""

# Repository visibility: none or --visibility="PUBLIC|PRIVATE|INTERNAL"
SHOPT_VISIBILITY=""
# SHOPT_VISIBILITY="--visibility=public"
# SHOPT_VISIBILITY="--visibility=private"
# SHOPT_VISIBILITY="--visibility=internal"

# Filter by topic name. required.
FILTER_TOPIC="terraform"

gh repo list $SHOPT_OWNER $SHOPT_VISIBILITY -L 1000 --json name,visibility,repositoryTopics \
| jq -r '.[]
  | select(
      ((.repositoryTopics // []) | any(.name == "'$FILTER_TOPIC'"))
    )
  | .'
```

- いったん満足した
- jq 部分の改行方法や、環境変数の組み込み方などを再整理できた
- で、調べている最中に、topics を指定してリストできることに気がついた

```bash
gh repo mine --topic terraform
```

:::message
定期的に保有スキルの洗い直しは大事だなって再確認した。
AI とは適切な距離を保って、使えるところとそうでないところ、指示出しの仕方などを学び続ける必要があるなって思った。
:::

## まとめ

- GitHub のリポジトリの定期的な掃除をしよう
- gh コマンドを使うと楽
- 掃除のついでにドキュメントを確認したりブログ書いたりスキルアップしたりしよう

@[card](https://cli.github.com/manual/)
