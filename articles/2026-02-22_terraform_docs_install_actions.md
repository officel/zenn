---
title: "GitHub Actions で terraform-docs をインストール"
emoji: "📚"
type: "tech"
topics: ["terraform", "github actions", "terraform-docs"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- [これから始める terraform-docs](https://zenn.dev/terraform_jp/articles/2025-10-23_terraform-docs) をちょっと前に書いた
- GitHub Actions のワークフロー部分に書かなかったけど、pre-commit-terraform で使用する時には別途各ツールをインストールする必要がある
- シェルでインストールしてたんだけど [jaxxstorm/action-install-gh-release](https://github.com/jaxxstorm/action-install-gh-release) を使うことにしたという話

# 元々

- GitHub Actions で terraform-docs を単独で使うなら `terraform-docs/gh-actions` が使える
- [antonbabenko/pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform) で使う時は別途インストールが必要
- こんな感じの

```yaml
      - name: Install Terraform Docs
        run: |
          TF_DOCS_URL="https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest"
          curl -L "$(curl -s $TF_DOCS_URL | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > terraform-docs.tgz
          tar -xzf terraform-docs.tgz terraform-docs
          rm terraform-docs.tgz
          chmod +x terraform-docs
          sudo mv terraform-docs /usr/bin/
```

- terraform 本体や tflint は setup- action が用意されていてインストール処理を書く必要がない

# 探してみた

- [Migrate to setup-terraform-docs style action · Issue #89 · terraform-docs/gh-actions](https://github.com/terraform-docs/gh-actions/issues/89) ｱｯﾊｲ
- まぁ自分たちのコードを自分たちが使いやすく使っている形であることのほうがいいよね

# やってみた

- コメントの下に書いてあるとおり、setup-terraform-docs は DEPRECATED なので放置
- [jaxxstorm/action-install-gh-release](https://github.com/jaxxstorm/action-install-gh-release) を使えば楽できると

```yaml
      - name: Install terraform-docs
        uses: jaxxstorm/action-install-gh-release@v2.1.0
        with:
          repo: terraform-docs/terraform-docs
          tag: v0.21.0
          cache: enable
```

- tag はデフォルトで latest なんだけど、cache を使う時はバージョン指定しないとダメ

https://github.com/jaxxstorm/action-install-gh-release/blob/v2.1.0/src/main.ts#L53

# よし

- 職場向けに新しい terraform module 用意してて、リポジトリを新しくしたついでに整理して掃除したということ
- コードを push して一仕事終えたのでブログにしとくかと思って書いた
- 書いてる途中でミス（バージョンの指定と cache: true って書いてた）に気がついたので修正した
- やったことのアウトプット大事。ひとりダブルチェック的なｗ

# ちなみに

- pre-commit-terraform のドキュメントを読んでる限り、リポジトリにこれら使用するツールのインストール等も含めた環境整備が求められているなって思った
- pre-commit, terraform, tflint, terraform-docs, trivy などをリポジトリ毎に管理設定しておけと（そうであれば GitHub Actions で前述のような個別インストール処理は不要になる）
- 難しいな。個人的にはこれらのツールは常に最新が正だと思ってるし（セキュリティ系のうんちくは必要ないです）リポジトリ毎にそれらの設定をするの、だいぶめんどうでは。。。
- mise 等々でツール整備が共通化を強制してるとかならまぁいいんだけど、現職ではその手のツールをロックインしてないので、各自好きなの使ってて。。。
- 御社の環境はどんな感じかぜひコメントしていって。。。:bow:
