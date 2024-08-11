---
title: "リポジトリの設定を .config ディレクトリに整理"
emoji: "🔧"
type: "tech"  # tech or idea
topics: ["config","git", "pre-commit"]
published: true
---

# tl;dr

- git hook のほうではなくツールとしての [pre-commit](https://pre-commit.com/) を使用している
- リポジトリ毎に少しずつ違うが必要な設定ファイルが増えてきて、リポジトリルートの直下が混雑してきた
- 設定を .config に整理することにした

# なぜ .config か

- `config` はリポジトリで扱うソースコード側が使用するケースがありうる

  - [Git - gitrepository-layout Documentation](https://git-scm.com/docs/gitrepository-layout) がそういうこと
  - フレームワーク等で config をルートディレクトリに置いている OSS は少なくない（個人的には行儀が悪いなって思うけど）

- `.config` は隠しディレクトリ扱いになるので、ソースコード側で使用するべきではない

  - [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/latest/)
  - 隠しディレクトリはIDEの設定等で表示させないことで存在しないもの扱いしやすい（必要な時だけあればいい）

# command

- `mkdir .config`
- `git mv .yamllint .config/`
- `code .pre-commit-config.yaml`
- 実際のPR [ci: mv config files to .config use pre-commit by officel · Pull Request #84 · officel/zenn](https://github.com/officel/zenn/pull/84)

# 面倒なところ

- pre-commit で使用する各ツールのオプションが統一されていない（それはそう）
- `-c` だったり `--config` だったりするので、ツール毎にドキュメントを確認する必要がある
- ツール側に pre-commit の利用方法が書いてある割にオプションの指定の仕方がなかったりする
- ローカルにインストール済みなツールはヘルプが直接参照できるけど、docker 形式のものはコマンドを直接参照しにくい（dockerを掘るのがめんどくさい）
- コミット時は対象のファイルしかチェックされないので、設定ファイルを移動させる等の処理をしたら `pre-commit run -a` でチェックしたほうがいい

# ちなみに

- pre-commit は Python 系
- [typicode/husky: Git hooks made easy 🐶 woof!](https://github.com/typicode/husky) は JavaScript 系
- [sds/overcommit at stackshare](https://github.com/sds/overcommit) は Ruby 系
- [evilmartians/lefthook: Fast and powerful Git hooks manager for any type of projects.](https://github.com/evilmartians/lefthook) は Go lang 系
- husky インスパイアな Rust 系ツールがいくつかあるけどあまり開発が盛んでないかもしれない
- 設定する以上のことができてしまうツールは正直ちょっと。。。
- pre-commit 自体も [pre-commit.ci](https://pre-commit.ci/) への移行を推奨しているし全部よいってわけではないけれども

# 近頃の悩み

- リポジトリ毎に設定がずれる

  - exclude 等、特定のディレクトリを範囲外にする
  - 会社名の略語、用語、単語など業務固有の内容
  - 必要かどうか（ansible-lintはansibleを必要としていないリポジトリには要らない）
  - 些細なミスによる同期ミス（改行、スペース、処理順など）

- autoupdate の頻度
- 管理自体が若干億劫になっている
- なにかいいソリューションはないものか
