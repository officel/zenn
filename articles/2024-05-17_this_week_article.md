---
title: "記事を書く習慣をつけるために github actions にがんばってもらう"
emoji: "📝"
type: "tech"
topics: ["github","githubactions", "issue"]
published: true
---

# tl;dr

- github actions に毎週 issue を立ててもらう
- 記事を書いたら issue を閉じる
- Happy!! 🎉

# 記事を書くことについて

- [自己紹介](https://zenn.dev/raki/articles/2024-05-11_raki_self) で継続を目標においた
- 面倒くさくなったり忘れたりサボったりして継続できないのはよくない
- issue ドリブンで強制すればできる（元々issueを処理するのは習慣付いている）
- 面倒なことは github にやってもらう

# github actions と issue

- [officel/zenn: zenn.dev repo](https://github.com/officel/zenn) この記事の公開リポジトリ
- [fix: #6 scheduled workflow for writing by officel · Pull Request #16 · officel/zenn](https://github.com/officel/zenn/pull/16)

```yaml
name: 今週も記事を書こう！

on:
  schedule:
    - cron: "0 15 * * SUN"
  workflow_dispatch:

jobs:
  twa:
    permissions:
      issues: write
      contents: read
    runs-on: ubuntu-latest
    timeout-minutes: 1
    steps:
      - name: Date
        id: current
        env:
          TZ: 'Asia/Tokyo'
        shell: bash
        run: |
          echo "date=$(date +%m/%d)" >> "$GITHUB_OUTPUT"
      - name: Blog
        run: |
          new_issue_url=$(gh issue create \
            --title "$TITLE" \
            --assignee "$ASSIGNEES" \
            --label "$LABELS" \
            --body "$BODY")
          echo "${new_issue_url}"
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GH_REPO: ${{ github.repository }}
          TITLE: "${{ steps.current.outputs.date }} blog"
          ASSIGNEES: "officel"
          LABELS: "zenn.blog"
          BODY: |
            - 個人としての記事を書く
            - この issue はネタのメモに使ってよい
            - 記事を書いたら issue number を入れて PR を出す
            - 自動で閉じても閉じなくてもよい、ことにする
      - name: Terraform-jp
        run: |
          new_issue_url=$(gh issue create \
            --title "$TITLE" \
            --assignee "$ASSIGNEES" \
            --label "$LABELS" \
            --body "$BODY")
          echo "${new_issue_url}"
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GH_REPO: ${{ github.repository }}
          TITLE: "${{ steps.current.outputs.date }} terraform-jp"
          ASSIGNEES: "officel"
          LABELS: "zenn.terraform-jp"
          BODY: |
            - terraform-jp のパブリケーションとして記事を書く
            - この issue はネタのメモに使ってよい
            - 記事を書いたら issue number を入れて PR を出す
            - 自動で閉じても閉じなくてもよい、ことにする
```

- こんな感じで issue にあがる

![image](https://github.com/officel/zenn/assets/110354/273aaabe-14b8-4a59-8ec0-99cfe4ab5a85)

- 自分用の記事と terraform-jp のパブリケーション用と２つ issue を作る
- どちらも自分にアサイン
- github project へはプロジェクトのワークフローで自動追加

# 懸念とか悩みとか

- プライベートリポジトリの時はこのワークフローで問題なかったんだけど、パブリックリポジトリでも問題ないのか？
- 問題があるならどう直すか。どう設定するか
- 記事にするネタがなかったらどうするか
- コミットタイトルを `fix: #xx` にするか `blog(xxx): slug` にするか

# とりあえず

継続して記事を書く準備自体はできたので、当面はこれでやってみる予定。
来週からは週イチ（✕２）更新を目標に地道にがんばります。
