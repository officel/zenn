---
title: "terraform の細かすぎて伝わらない小ネタ Style Guide file name"
emoji: "🗒"
type: "tech"
topics: ["terraform", "style guide"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- [Style Guide](https://developer.hashicorp.com/terraform/language/style) が守られていないと保守しにくい
- [Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure) も合わせて読みたい
- ただし、スタイルガイドに盲目にしたがっても保守しにくいケースは多数ある
- ファイル名の命名規則を今一度見直してみよう

# 公式のスタイルガイドのファイル名

※ アルファベット順でソート済み

- `backend.tf`
- `locals.tf`
- `main.tf`
- `outputs.tf`
- `override.tf`
- `providers.tf`
- `terraform.tf`
- `variables.tf`
- 規模が大きくなってきたらロジカルにファイルを分離する

# よくあるひっかけ

## backend.tf

- たとえば HCP Terraform（と Enterprise）ではバックエンド（ワークスペース）は、`cloud` block に置く（`backend` block は使えない）
- これは `backend.tf` に置くべきか、`terraform.tf` に置くべきか
- `terraform` block は分割して複数書けるので `cloud` block 部分だけ `backend.tf` に置くことができる
- 条件により後述するとおり `backend.tf` ではなく `terraform.tf` に置きたい
- リモートステートを参照する場合は `date.tf` より `backend.tf` にあるほうがわかりやすい（リモートステートはどこかのbackendなので）

## locals.tf

- `locals` block は複数書ける
- `locals.tf` にするのは読みやすさを損なわないように注意する
- 多くの場合は、使用するリソースの近くにあるほうが読みやすい
- 共通の場合（`name`など）は `locals.tf` が適切かもしれないが、後述するとおり、`main.tf` に置くほうがさらにわかりやすい

## main.tf

- ほとんどの場合、ディレクトリ中のリソース数が多くなるので適切にファイル分割したい（≒ `main.tf` に全リソースを置くのはやめる）
- 1つのことしかしないなら `main.tf` を使用し、複数のことをするならファイルを分割するのがよい
- 適切に分割すると `main.tf` には共通の処理（`locals`）だけが残る。多くの場合は `name`, `tags` などの組み立てだけ
- 前述のとおり、処理を別ファイルに分け、固有の locals を追従させ、共通部分を抜き出すと、`locals.tf` が不要になり `main.tf` に `locals` block だけが残るイメージ

## output.tf

- ファイルを分割したら、関連する output は一緒に移動したほうが便利
- terraform-docs 等で README を生成している場合、output が整理されるので、どこに置いてあっても大丈夫
- ファイル数を減らせるので、リソースのファイルに `output` block を移動させることで `output.tf` を使用しない選択はあり
- ただし、モジュールの場合は [Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure) 的にもあったほうがよい（かもしれない）
- OSS で公開するモジュールなら必須、そうでない場合は管理しやすさを優先

## providers.tf

- 強いポジションがなければ従うのがよい
- 使用する `provider` block の数にも拠るが、`terraform.tf` にまとめて置くほうがわかりやすい（気がする）
- とくに、`required_providers` block が必要なものは `terraform` block とセットにしておくとわかりやすい
- クラウドプロバイダー別にファイルを分けると、見た目はわかりやすい

## terraform.tf

- `backend.tf` と `providers.tf` をまとめて `terraform.tf` にすると管理が楽になる
- この3つはリポジトリや組織で統一して使い方を決めておくとよい
- 機能的にファイルを分割する場合、とくに有効

## variables.tf

- モジュールでない場合はむしろ使わないほうがよい
- `variables.tf` は `variable` を与える場合に使うもの（モジュールなど）であり、極端な話、値を変更して実行してよいと解釈できる
- 当該ディレクトリにおいて値を変えて実行するべきではない場合、`variables` ではなく `locals` を使用するべき

# モジュールのスタイルガイドから

## README

- モジュールの場合は terraform-docs 等でファイルを自動更新させる
- モジュールではない場合は、当該ディレクトリが何であるかを説明するドキュメントを書く
- 個人的には拡張子があるべきだと考えているし、マークダウン以外にする理由がないので、`README.md` が正

## その他のファイル

- 基本的にはドキュメントにしたがう
- 複雑な `variables` は型安全のメリットよりも、その変数がどのリソースに使われるのかが読みにくくなるデメリットが大きいので避けるべき
- 中長期運用で苦労したことがないものだけが自作モジュールを作りなさい（rakiによる福音書）

# ちょっとしたプラクティス

- ファイルを分割する時は、機能で分割する。ビジネスサービスの機能でもいいし、リソース的な機能でもいい
- リソース的な機能で分割する場合、プロバイダーをプレフィックスにするとわかりやすい（例：`aws_s3.tf` や `aws_alb.tf` など）
- 同様のリソースを複数作るケースでは、名前をポストフィックスにするとわかりやすい（例：`aws_s3_xxx.tf` や `aws_iam_policy_xxx.tf` など）
- いずれの場合も、目的のリソースがどのファイルにあるか、を正しく判別できるのがよい命名である
- 同時に、目的のリソースを変更するために、3つ以上ファイルを開かずに済むのがよい分割である
- 同様のリソースを作成する際にディレクトリごと丸コピーして、`diff -r` した時に差分がわかりやすい、のがよい分割である
- どのディレクトリにも同じファイル名が存在し、必要な差分が極小の範囲に収まっているのが望ましい

# まとめ

- [terraform のディレクトリ構造のプラクティス](https://zenn.dev/terraform_jp/articles/2024-08-12_terraform_directories) を以前書いた
- 命名規則もプラクティスとして書こうかと思ったんだけど、基本となるドキュメントがあるので、それをベースにしたほうがいいかなって
- （それ言ったらディレクトリ構造だって [ドキュメント](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/best-practices#group-by-volatility) はあるけれども）
- どこに本家のドキュメントがあって、自分がどう考えていてどう実践してきて今後こうしたいんだ、を説明する元になる記事を書いた
