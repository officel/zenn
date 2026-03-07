---
title: "HCP Terraform と pre-commit-terraform"
emoji: "🥨"
type: "tech"
topics: ["terraform", "HCP"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- terraform を扱うリポジトリに pre-commit-terraform を導入
- HCP Terraform にプライベートレジストリを置いている場合に validate を使う時は `HCP_TF_API_TOKEN` が必要だったのでメモ

# 準備

- terraform を扱っているリポジトリで pre-commit を使う時は一緒に pre-commit-terraform を使うと楽です

@[card](https://github.com/pre-commit/pre-commit)

@[card](https://zenn.dev/raki/articles/2025-10-19_prek_alternative_pre-commit)

@[card](https://github.com/antonbabenko/pre-commit-terraform)

# `.pre-commit-config.yml`

- pre-commit-terraform 部分はこんな感じ

```yaml
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.105.0
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

@[card](https://zenn.dev/terraform_jp/articles/2025-10-23_terraform-docs)

@[card](https://zenn.dev/terraform_jp/articles/2025-11-03_terraform_tflint)

@[card](https://zenn.dev/terraform_jp/articles/2025-11-11_terraform_trivy)

- tflint の config は `__GIT_WORKING_DIR__` が使えるんだけど terraform-docs は使えないというかエラーになってしまうのなんでなんだぜ。。。（なくても困ってないから外してある）

# `.github/workflows/pre-commit.yml`

- GitHub Actions のワークフローはこんな感じ

```yaml
jobs:
  pre-commit:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@v6
      - uses: actions/setup-python@v6
        with:
          python-version: "3.14"
      - name: Install Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          cli_config_credentials_token: ${{ secrets.HCP_TF_API_TOKEN }}  # 今日はここ
      - name: Install TFLint
        uses: terraform-linters/setup-tflint@v6
      - name: Install terraform-docs
        uses: jaxxstorm/action-install-gh-release@v2.1.0
        with:
          repo: terraform-docs/terraform-docs
          tag: v0.21.0
          cache: enable
      - name: Install Trivy
        uses: aquasecurity/setup-trivy@v0.2.5
        with:
          version: v0.69.3
          cache: true
      - uses: j178/prek-action@v1
      # - uses: pre-commit/action@v3  # prek じゃなくて pre-commit を使いたい時はこっち
```

- 元々 pre-commit 用の CI で書いていてツールは prek に置き換えたけどジョブの名前は pre-commit のままにしている（pre-commitのほうが伝わりやすいと思って）
- setup-terraform で terraform がインストールされるのでそこに環境変数で HCP Terraform に接続する API Token をセットしてあげればおｋ
- Validate は普段手抜きで使ってなかったんだけど、ちゃんとやるかーと思ってセットしたらエラーになってしまったので調べたら、使用しているモジュールが HCP Terraform のプライベートレジストリに登録されている場合にトークンが必要だった、という話（それはそう）

@[card](https://zenn.dev/terraform_jp/articles/2026-02-22_terraform_docs_install_actions)

# `HCP_TF_API_TOKEN`

- HCP Terraform の Organization Settings の API tokens メニュー
- アクセスレベルの異なる4種類のトークンが発行できる
- CI/CD 向けは Team Tokens が適切

![Team Tokens](/images/2026-03-07.png)

# まとめ

- terraform を管理しているならワークフローをちゃんとしよう
- 後で設定するの大変なので、できるだけ早い段階で導入しましょう
- プライベートレジストリがダメだとは言わないけど、パブリックモジュールとして公開できるようにコードを書かないとガラパゴス化しちゃうと思うので注意しようね
- 現職のプライベートレジストリ用のモジュールと、普段多くの人の手が入るプライベートリポジトリにやっと導入できた（リンターのワーニングが多くてCIまで持っていけてなかった）ので記念に記事にしたってワケ
