---
title: "terraform の細かすぎて伝わらない小ネタ GHAR Ubuntu 24.04 には Terraform が入ってない"
emoji: "⁉"
type: "tech"
topics: ["terraform","github"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- [GitHub のブログ](https://github.blog/changelog/2024-09-25-actions-new-images-and-ubuntu-latest-changes/) で発表されているように `ubuntu-latest` が 22.04 から 24.04 に入れ替えが始まっている
- [runner-images/images/ubuntu/Ubuntu2204-Readme.md](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2204-Readme.md) と
- [runner-images/images/ubuntu/Ubuntu2404-Readme.md](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md) を比べると Terraform がなくなっている
- setup-terraform action を使っていれば何も問題ないけどね

# 素晴らしい

@[card](https://github.com/cloudposse/atmos/pull/718)

- 昼過ぎに見かけた
- [aqua CLI Version Manager 入門](https://zenn.dev/shunsuke_suzuki/books/aqua-handbook) の人
- なるほど？と思って調べてみたというワケ

# setup-terraform

- [hashicorp/setup-terraform: Sets up Terraform CLI in your GitHub Actions workflow.](https://github.com/hashicorp/setup-terraform)
- いわずとしれた HashiCorp の terraform 用ワークフロー
- [github actions(w/z composite) + setup-terraform in 2023 #Terraform - Qiita](https://qiita.com/raki/items/9a020c02759fede05157) 記事を書いたりもしてた
- HCP Terraform がビジネス用なので、あまり積極的に改善されたりはしていないけど、必要十分ではある
- Go だしワークフローあるしランナーからは抜いてもいいかって判断なのかな。。。（Ansibleは引き続き入ってるのにね）

# 意外と

- 意外と CI こけてる issue がリンクされてるっぽいとこみるとあるあるって思っちゃうね
- [Ubuntu 24.04 is now available · Issue #9848 · actions/runner-images](https://github.com/actions/runner-images/issues/9848)
- [Ubuntu-latest workflows will use Ubuntu-24.04 image · Issue #10636 · actions/runner-images](https://github.com/actions/runner-images/issues/10636)
- [OpenTofu はインストール時間も短いしインストールしねぇ](https://github.com/actions/runner-images/issues/9507#issuecomment-1996998465)ってことらしい
- [Terraform が 24.04 から削除された経緯](https://github.com/actions/runner-images/issues/10764#issuecomment-2406251518) はどこに書いてあるんよ。。。（英語苦手）
- ライセンスのアレで削除されたのかしら。。。

# まぁとりあえず面倒だからいっか（まとめ）

- GitHub Actions Runner の Ubuntu-latest は 24.04 に自動的に置き換え中です（2024年10月いっぱいのはず）
- Terraform 等のいくつかのツールが 22.04 -> 24.04 の際に削除されています（インストールされていません）
- setup-terraform 等のワークフローを使うなどしてインストールして使う必要があります
- GitHub Actions Runner を使っている諸兄はご注意を。
- そういえば Act のイメージも更新がいるかな。。。

# おまけ

- ファイル名とタイトルの文字数制限をもうちょい緩和できないんか。。。
