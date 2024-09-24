---
title: "git リポジトリの命名規則とディレクトリ構成"
emoji: "📂"
type: "tech"  # tech or idea
topics: ["git","repository","name"]
published: true
---

# tl;dr

- リポジトリの命名とディレクトリ構成のプラクティス（ベストとは言ってない）

```txt
repos/
|-- codecommit
|-- dev.azure.com
|   `-- ORG
|       `-- PROJECTS
|           `-- repo
`-- github.com
    |-- ORG1
    |-- ORG2
    `-- officel
        |-- my-private_repo1
        |-- my-private_repo2
        |-- public_repo1
        `-- public_repo2
```

# プラクティス

## 単一のリポジトリ用ディレクトリを作成する

- `repos` など
- ホームディレクトリやルートディレクトリ、デスクトップ等の直下に clone しない
- 個人的には外付けのデータドライブの直下に `repos` を置いている
- 散らばらない、まとめてバックアップができる、VS Code のワークスペースなどをまとめやすいなどの利点がある

## リポジトリのホスティングサービス名のディレクトリを作成する

- `github.com` など
- 組織やチームによってリポジトリのホスティングサービスが異なる（たくさんある）
- 自分の組織よりもサービスのほうが大きい概念なので先にする
- Azure DevOps はブラウザで見ると `dev.azure.com` だけど、ssh clone 時は `ssh.dev.azure.com` だったりする
- AWS CodeCommit は `git-codecommit.ap-northeast-1.amazonaws.com` のようにリージョンが挟まるし長いし、マネジメントコンソール上の URL とも違うので `codecommit` にしてる（バッティングする使い方をしていないので）
- GitLab や SourceForge なんかもそれぞれのドメインにしておく

## （サービスによって）オーガニゼーションやアカウント名など URL に倣ってディレクトリを作成する

- `ORG`, `officel` など
- 組織ならオーガニゼーション、個人ならユーザ名のようなグループで区切られているので倣う
- 意外とこの辺について考えずに clone している人をよくみかける
- OSS のリポジトリを clone する時もちゃんとしておくと fork との区別がつきやすい
- （fork を clone 追加するなら元リポジトリ内で remote add するほうがいい気もする）

## （サービスによって）プロジェクト名のディレクトリを作成する（github.com にはない）

- 組織やチームなどでプロジェクトが分かれている場合に使う（URLに倣うだけ）
- Azure DevOps は org の下にプロジェクト名がつく（dev.azure.com/ORG/PROJECT/_git/REPO のような URL）
- （全サービス揃えて使うなら Azure DevOps のワンストップ感はよさげなんだけど、GitHub に慣れていると戸惑いが多い。。。）

## リポジトリの命名規則を作る

- リポジトリの命名規則は早めに決める
- 個人用ではプライベートリポジトリに `private-` や `my-` のようなプレフィックスをつけるとリストした時に見やすい
- 何かを試してみたりするリポジトリには `examples`, `samples`, 短いのがよければ `case` などの決まった語句を付けるとわかりやすい
- こんな感じ（`my-examples-`で始まっているのはプライベート、それ以外はパブリック）

```bash
# /mnt/d/repos/github.com/officel/ 下の抜粋
$ ls -1
examples-terraform
github-web-cosmetic
my-examples-ansible
my-examples-docker
my-examples-flutter
my-examples-github
my-examples-go-lang
my-examples-mysql
my-examples-rust
my-examples-terraform
my-issues
my-links
my-sof
my-til
officel
```

- パブリックの `examples-terraform` とプライベートの `my-examples-terraform` のように用途に応じて分けつつ、一目で区別がつきやすい
- ターミナルでは補完できるので `cd m(tab)e(tab)t` で `my-examples-terraform` に移動している。別に全部叩いたりコピペしたりはしない（するな）
- もっとも VS Code を使っているので `ctrl+shift+@` でワークスペース中のディレクトリには選択だけで入れる

# まとめ

- ディレクトリ構成と命名が統一されていると使いやすい

```txt
repos/
|-- codecommit
|-- dev.azure.com
|   `-- org
|       `-- projects
|           `-- repo
`-- github.com
    |-- ORG1
    |-- ORG2
    `-- officel
        |-- my-private_repo1
        |-- my-private_repo2
        |-- public_repo1
        `-- public_repo2
```

# 余談

- リポジトリ名の命名は、サービス名が先か後か、単数形か複数系か、`sample` か `examples` かなどの紆余曲折あった
- この記事のとおり、サービス名が後、複数形、`examples`になった
- 所属組織名のディレクトリを上位に持ってきてもいいんだけど、結局大抵はオーガニゼーションが挟まるので今の形になった（今のところグループやオーガニゼーションが挟まらないのって CodeCommit だけかな？）
- GitHub 以外は使ってないから気にしてない、みたいな人は幸いである（rakiによる福音書）
