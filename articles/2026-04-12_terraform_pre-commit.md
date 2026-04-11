---
title: "pre-commit と terraform 2026年版"
emoji: "🆕"
type: "tech"
topics: ["terraform", "pre-commit"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- pre-commit と terraform まわりの再整理
- 昨今のサプライチェーンアタックなどの脅威に対してできることやっていることできていないこと

# 過去記事

古いものリストアップしてもしょうがないので興味があれば見てください

@[card](https://zenn.dev/raki)

# できることとやっていること

- prek を使用して pre-commit-config のバージョン指定を固定
- pinact を使用してワークフローのバージョン指定を固定
- zizmor を使用してワークフローの静的チェック
- aqua を使用して関連ツールのバージョン指定を固定
- dependabot に cooldown を設定

# 具体的には

## pre-commit

- ツールとしては prek を使用している
- ローカルのツールは各自でインストールしたバージョンを使用していた
- 後述する aqua でリポジトリ毎に固定するようにした
- `prek autoupdate --freeze` で一度固定した後は dependabot に更新を任せている

```yaml:.pre-commit-config.yaml
repos:

  - repo: https://github.com/zizmorcore/zizmor-pre-commit
    rev: ea2eb407b4cbce87cf0d502f36578950494f5ac9  # frozen: v1.23.1
    hooks:
      - id: zizmor

  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: d0e12caebb2ab0ee8bf98181c8bfe9702bca103d  # frozen: v1.105.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_trivy
      - id: terraform_tflint
        args:
          - --args=--config=__GIT_WORKING_DIR__/.tflint.hcl
      - id: terraform_docs
        args:
          - "--args=--config=.terraform-docs.yml"
```

## pinact, zizmor

- `pinact run -u` でワークフローのバージョンをピン留めした
- `zizmor .` でワークフローの静的解析をしてワーニングに対応した
- `zizmor` は前述のとおり pre-commit にも入れて常時チェック

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
        with:
          persist-credentials: false
      - uses: hashicorp/setup-terraform@5e8dbf3c6d9deaf4193ca7a8fb23f2ac83bb6c85 # v4.0.0
        with:
          terraform_version: '1.14.8'

      # see https://aquaproj.github.io/docs/products/aqua-installer/
      - uses: actions/cache@668228422ae6a00e4ad889ee87cd7109ec5666a7 # v5.0.4
        with:
          path: '~/.local/share/aquaproj-aqua'
          key: v2-aqua-installer-${{runner.os}}-${{runner.arch}}-${{hashFiles('aqua.yaml', 'aqua-checksums.json')}}
          restore-keys: |
            v2-aqua-installer-${{runner.os}}-${{runner.arch}}-
      - uses: aquaproj/aqua-installer@11dd79b4e498d471a9385aa9fb7f62bb5f52a73c # v4.0.4
        with:
          aqua_version: 'v2.57.1'
          skip_install_aqua: true

      - uses: j178/prek-action@53276d8b0d10f8b6672aa85b4588c6921d0370cc # v2.0.1
```

## aqua

- 以前はツール類は各自でインストールしていてバージョン類も若干まちまちだった
- 多少ズレていてもさほど問題は起きていなかった
- せいぜいインストールしていないツールがある時にエラーになるだけ
- 昨今の脅威に対抗するにはバージョンのピン留めは最低限の対応として必要
- ツールのバージョンをSHAで固定し、インストールされるバージョンを安全なものとして扱うには、terraform-docs など、専用のアクションがないものなどに不安があった（ghのリリースから取得では不完全だと思った）
- そのため、インストールバージョンの SHA チェックが可能なツールとして aqua を使用した
- mise も同様のことができるが個人的に使い慣れていないので今のところは aqua で、という感じ

```yaml:aqua.yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/aquaproj/aqua/main/json-schema/aqua-yaml.json
# aqua - Declarative CLI Version Manager
# https://aquaproj.github.io/
checksum:
  enabled: true
  require_checksum: true
  supported_envs:
  - all
registries:
- type: standard
  ref: v4.492.0 # renovate: depName=aquaproj/aqua-registry
packages:
- name: terraform-docs/terraform-docs@v0.21.0
- name: terraform-linters/tflint@v0.61.0
- name: aquasecurity/trivy@v0.69.3
```

- `aqua upc` で `aqua-checksums.json` を出力して一緒に管理することで、インストール時に処理される

## dependabot

- 先月 pre-commit がエコシステム入りしたのでとても楽
- `schedule.interval` は急いでなければ monthly でもいいかなぁとか
- `groups` でまとめてしまうほうが対応頻度少なくていいかなぁとか
- `cooldown` は zizmor がデフォルトで 7 日って言うからあわせてある

```yaml:dependabot.yml
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
    cooldown:
      default-days: 7
  - package-ecosystem: "pre-commit"
    directory: "/"
    schedule:
      interval: "weekly"
    groups:
      dependencies:
        patterns:
          - "*"
    cooldown:
      default-days: 7
```

# なぜか

- 以前は pre-commit-terraform を使用するためにワークフロー中でツールのインストールを個別にしていた
- terraform-docs は専用のアクションがなく、インストールに（手抜きで）gh-releaseを使用していた
- が、セマンティックバージョンでの指定しかできず、SHAのチェックはベタ書きするしかない
- SHAの更新を自動化することが（簡単には）できず、それを作るのはめんどくさい
- ちゃんと管理できるツール（aquaやmise）があるならそれをちゃんと使おうという流れ

# できていないこと

やりたいんだけどまだできていないこと

## dependabot の更新の自動マージ

- 今のところ手動で目検してマージしている
- 自動でマージしたいところだけどできていない

## aqua（ツールバージョン） の自動更新

- pre-commit を CI としてまわすことで品質を担保しているが、ツールバージョンの更新について決めかねている
- 個人で使用している部分は週一くらいで更新するようにしているが、職場のリポジトリ数で手作業していたら大変なことになる
- まだ順次対応という感じ（急ぎが必要な分は終わっている）なので、今後に向けて対策を考える必要がある

## キャッシュ

- 前述のワークフローでのキャッシュが悪いせいか、terraform を aqua 管理にしたところ、高確率で aqua での terraform 呼び出しが失敗してエラーになってしまった
- そのため terraform だけは setup-terraform を使用している
- 今のところそれ以外は問題ないんだけど、いずれどうにかしたい（フルインストールしてフルキャッシュならうまくいくのかも）
- テストと動確の知見が足りていない

## tflint の設定のバージョン指定

- .tflint.hcl でプラグインのバージョン指定は今現在もSHAにできないみたい

# やっていないこと

個人的にやりたくないことも含めて、できるけどやっていないこと

## terraform.lock.hcl

- terraform 本体、プロバイダー、クラウド、手作業の兼ね合いで、ロックファイルをコミットしていない
- 常に最新の状態で実行されることを期待している（`terraform init -upgrade`しているのと同じ）
- もっとも、HCP Terraform はステート側が優先されるのか、ワークスペースの問題か、最新にならないケースがあるが。。。
- それはそれとして、ちゃんとするならロックしないとダメかもしれない、とてもとてもめんどくさいと思っている

## 対象リポジトリがまだたくさんある

- 自分用のローカルも含めて対応が終わってないリポジトリが多数ある
- 各ツールがそもそもあたってなかった分は通すだけでも大変なので
- とくに tflint を通すために設定をごまかすのはしたくないので時間がかかる。。。
- あとモノレポの場合はとてもじゃないけどこのままは使えない（全ワークスペースでマージの都度こんなの走ったらツライので書き方考えないといけない）
- これがうまく通るのは今のところ内製モジュールとCIとして走らせない場合だけ

# まとめはないけど

- 2026年4月現在で最低限やっておきたい terraform と pre-commit-terraform について、現状を公開した
- 他にできることややっている工夫などがあれば情報交換したいと思って書いてみた
- いいねは別に要らないのでコメントくださいｗ
- とくにダメそうなところや別の工夫など違う意見や知見が欲しいです
