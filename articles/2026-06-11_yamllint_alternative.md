---
title: "ryl -- yamllint の代替ツールを探して"
emoji: "🔎"
type: "tech" # tech or idea
topics: ["git", "pre-commit", "prek", "yamllint", "ryl"]
published: false # 公開前に true に直す
---

# tl;dr

- pre-commit(prek) のツールの定期見直しを実施中
- yamllint の代替 ryl をお試し中

# pre-commit(prek)の定期見直し

- prek については前に書いた
- [prek を使ってみる ADR - alternative pre-commit -](https://zenn.dev/raki/articles/2025-10-19_prek_alternative_pre-commit)
- よりよいツールや、設定、あるべき姿を探して定期的に見直しをしている
- そろそろ yamllint の番かなって

# yaml 関係の pre-commit チェック

- pre-commit に元から入っている `check-yaml`
- 今まで使っていた Python ベースの `adrienverge/yamllint`
- チェックの基準やできることが違うので両方入れている
- 実は actionlint も yaml チェックである（余談）
- そもそも普段は言うほど yaml のチェックを必要としていない
- どちらかといれば prettier のようなフォーマッタで規定の形に揃えてくれるほうがありがたい
- とはいえ新しいツールを探すことを放棄する理由にはならないのでAIにレポートを作ってもらった

:::details AI に作ってもらった yamllint 代替ツールのレポート

# yamllint代替Rust/Go製YAMLリンター比較レポート

## 概要

本レポートは、既存のPython製`yamllint`の代替となる、RustまたはGo言語で開発されたYAMLリンター20製品を調査し、ユーザーの指定された要件（高速性、2026年以降の活発な開発、適切なリリースノート、`pre-commit`または`prek`への言及）に基づき評価・ランキング化したものです。

## 評価基準

各リンターは以下の基準で評価され、スコアが算出されました。

* yamllint互換性: `yamllint`の代替としてどの程度機能するか（ドロップイン、インスパイア、部分互換など）。
* 高速性: Rust/Go言語の特性を活かしたパフォーマンス向上。
* 2026年以降の活動: 2026年中に1回以上の更新があるか。これはプロジェクトの活発な開発状況を示す重要な指標です。
* リリースノート: リリースノートが明確に記載されているか。
* pre-commit/prek対応: `pre-commit`または`prek`フックへの対応が明記されているか。

## ランキング表

| 順位 | 名称 (GitHubリンク) | 言語 | yamllint互換性 | 高速性 | 2026年活動 | リリースノート | pre-commit/prek対応 | スコア |
|------|------|------|--------------------|-------|---------------|---------------|-------------------|-------|
| 1 | [ryl](https://github.com/owenlamont/ryl) | Rust | 高 (ドロップイン) | ⚡⚡⚡ | あり | 非常に良い | あり | 100 |
| 2 | [yaml-lint-rs](https://github.com/hiromaily/yaml-lint-rs) | Rust | 中 (インスパイア) | ⚡⚡⚡ | あり | 良い | あり | 95 |
| 3 | [fast-yaml](https://github.com/bug-ops/fast-yaml) | Rust | 中 (部分互換) | ⚡⚡⚡ | あり | 非常に良い | あり | 90 |
| 4 | [actionlint](https://github.com/rhysd/actionlint) | Go | 低 (GitHub Actions特化) | ⚡⚡⚡ | あり | 非常に良い | あり | 85 |
| 5 | [yamlfmt](https://github.com/google/yamlfmt) | Go | 低 (フォーマッター) | ⚡⚡ | あり | 良い | あり | 80 |
| 6 | [kube-linter](https://github.com/stackrox/kube-linter) | Go | 低 (K8s特化) | ⚡⚡ | あり | 良い | あり | 75 |
| 7 | [lintnet](https://github.com/lintnet/lintnet) | Go | 低 (汎用リンター) | ⚡⚡ | あり | 良い | あり | 70 |
| 8 | [rslint](https://github.com/web-infra-dev/rslint) | Rust | 低 (汎用リンターフレームワーク) | ⚡⚡⚡ | あり | 普通 | あり | 65 |
| 9 | [rumdl](https://github.com/rvben/rumdl) | Rust | 中 (rylと連携) | ⚡⚡⚡ | あり | 良い | あり | 65 |
| 10 | [flint](https://github.com/grafana/flint) | Go | 低 (汎用リンター) | ⚡⚡⚡ | あり | 良い | あり | 60 |
| 11 | [dasel](https://github.com/TomWright/dasel) | Go | 低 (データセレクター) | ⚡⚡⚡ | あり | 良い | なし | 55 |
| 12 | [yq (mikefarah)](https://github.com/mikefarah/yq) | Go | 低 (YAMLプロセッサー) | ⚡⚡ | あり | 良い | なし | 50 |
| 13 | [yaml-serde](https://github.com/yaml/yaml-serde) | Rust | 低 (ライブラリ) | ⚡⚡⚡ | あり | 普通 | なし | 45 |
| 14 | [go-yaml (canonical)](https://github.com/go-yaml/yaml) | Go | 低 (ライブラリ) | ⚡⚡ | あり | 普通 | なし | 40 |
| 15 | [go-faster/yaml](https://github.com/go-faster/yaml) | Go | 低 (ライブラリ) | ⚡⚡⚡ | あり | 普通 | なし | 40 |
| 16 | [publiccode-parser-go](https://github.com/italia/publiccode-parser-go) | Go | 低 (特定用途) | ⚡ | あり | 普通 | なし | 35 |
| 17 | [protoyaml-go](https://github.com/bufbuild/protoyaml-go) | Go | 低 (特定用途) | ⚡⚡ | あり | 普通 | なし | 35 |
| 18 | [yaml-validator](https://github.com/MathiasPius/yaml-validator) | Go | 低 (CLIツール) | ⚡ | あり | 普通 | なし | 30 |
| 19 | [torrust-linting](https://github.com/torrust/torrust-linting) | Rust | 低 (組織内ツール) | ⚡⚡ | あり | 普通 | なし | 25 |
| 20 | [spectral](https://github.com/stoplightio/spectral) | JS/Go | 低 (汎用JSON/YAML) | ⚡ | あり | 良い | あり | 20 |

## 結論

`yamllint`の代替として最も推奨されるのは、Rust製の`ryl`です。これは`yamllint`との高い互換性を持ちつつ、Rustの恩恵による高速性、活発な開発、そして`pre-commit`対応など、ユーザーの主要な要件をすべて満たしています。

次点としては`yaml-lint-rs`と`fast-yaml`が挙げられます。これらも高速性と活発な開発が特徴ですが、`yamllint`との互換性や機能面で`ryl`にわずかに劣る点があります。

Go言語製では`actionlint`がGitHub Actionsに特化しているものの、非常に活発で`pre-commit`対応もしているため、特定の用途では強力な選択肢となります。汎用的なYAMLリンターとしては`yamlfmt`や`lintnet`が有力です。

最終的な選択は、ユーザーの具体的なプロジェクト要件や既存のワークフローとの統合のしやすさによって異なりますが、本レポートが意思決定の一助となれば幸いです。
:::

# というわけで

- いったんざっと眺めて良さそうなのが [ryl](https://ryl-docs.pages.dev/) だった
- 以前の記事でも書いたけど、シングルバイナリであること、開発が活発であることが優先
- 既存ツールとの差異をコントロールできること、prek に乗せて問題ないことなどが次点
- aqua で簡単にインストールできるので楽ｗ

# ryl を使ってみた

## .pre-commit-config.yaml に乗せる

- 既存のやつもしばらく併用
- これは最終系（作業中は args 等を書き直してた）

```yaml:.pre-commit-config.yaml
  - repo: https://github.com/adrienverge/yamllint.git
    rev: cba56bcde1fdd01c1deb3f945e69764c291a6530  # frozen: v1.38.0
    hooks:
      - id: yamllint
        args:
          - -c=.config/.yamllint

  - repo: https://github.com/owenlamont/ryl-pre-commit
    rev: 75e565ff428fb9bad213c3c76d1bde37ffeb8fcf  # frozen: v0.15.0
    hooks:
      - id: ryl
        types_or: [yaml, markdown]
        args:
          - -c=.config/.ryl.toml
```

## --fix なしで同じ設定ファイルを使って実行

- 10倍速い
- 俺じゃなきゃ見逃しちゃうね💛

```shell
$ prek run ryl -a -v
ryl......................................................................Passed
- hook id: ryl
- duration: 0.01s

  .github/workflows/github_workflow_status_badge.yml
    26:73     warning  too few spaces before comment: expected 2  (comments)
    45:88     warning  too few spaces before comment: expected 2  (comments)

  Taskfile.habits.yml
    35:9      warning  comment not indented like content  (comments-indentation)
    39:9      warning  comment not indented like content  (comments-indentation)
    47:9      warning  comment not indented like content  (comments-indentation)
    62:9      warning  comment not indented like content  (comments-indentation)
    73:9      warning  comment not indented like content  (comments-indentation)
    97:9      warning  comment not indented like content  (comments-indentation)
    99:9      warning  comment not indented like content  (comments-indentation)
    116:9     warning  comment not indented like content  (comments-indentation)

  .github/workflows/stale.yml
    17:70     warning  too few spaces before comment: expected 2  (comments)

  .github/workflows/pre-commit.yml
    15:73     warning  too few spaces before comment: expected 2  (comments)
    19:77     warning  too few spaces before comment: expected 2  (comments)
    23:73     warning  too few spaces before comment: expected 2  (comments)

$ prek run yamllint -a -v
yamllint.................................................................Passed
- hook id: yamllint
- duration: 0.10s

  .github/workflows/github_workflow_status_badge.yml
    26:73     warning  too few spaces before comment: expected 2  (comments)
    45:88     warning  too few spaces before comment: expected 2  (comments)

  Taskfile.habits.yml
    35:9      warning  comment not indented like content  (comments-indentation)
    39:9      warning  comment not indented like content  (comments-indentation)
    47:9      warning  comment not indented like content  (comments-indentation)
    62:9      warning  comment not indented like content  (comments-indentation)
    73:9      warning  comment not indented like content  (comments-indentation)
    97:9      warning  comment not indented like content  (comments-indentation)
    99:9      warning  comment not indented like content  (comments-indentation)
    116:9     warning  comment not indented like content  (comments-indentation)

  .github/workflows/stale.yml
    17:70     warning  too few spaces before comment: expected 2  (comments)

  .github/workflows/pre-commit.yml
    15:73     warning  too few spaces before comment: expected 2  (comments)
    19:77     warning  too few spaces before comment: expected 2  (comments)
    23:73     warning  too few spaces before comment: expected 2  (comments)
```

## --fix 付きで実行

- `--fix` を設定に追加して実行
- fix したファイルのリストは欲しかったな
- でも必要十分な修正が行われた
- 業務では影響大きいからダメかもな
- 前述の warning が全部修正された

```shell
$ prek run ryl -a -v
ryl......................................................................Failed
- hook id: ryl
- duration: 0.01s
- files were modified by this hook

  Found 2 problems (2 fixed, 0 remaining).
  Found 9 problems (9 fixed, 0 remaining).
  Found 3 problems (3 fixed, 0 remaining).
```

## 設定の引き継ぎ

- `.config/.yamllint` が現行ツールの設定ファイル

```shell
$ ryl --migrate-configs
./.config/.yamllint -> ./.config/.ryl.toml
```

- 出力内容とかなくて、設定ファイルをこれからこれにするぜって教えてくれるだけ

```shell
$ ryl --migrate-configs --migrate-write
./.config/.yamllint -> ./.config/.ryl.toml
```

- 既存の設定と同等の ryl 用設定ファイルが出力された
- 個人的には toml 好きじゃないんだけど、ryl 独自の設定は toml ファイルにしか書けないようなので用意した

```shell
$ cat .config/.ryl.toml
ignore = [
    "backup/",
    "node_modules/",
    "Taskfile.git.yml",
]

[files]
yaml = [
    "*.yaml",
    "*.yml",
    ".yamllint",
]

[rules]
anchors = "enable"
braces = "enable"
brackets = "enable"
colons = "enable"
commas = "enable"
document-end = "disable"
document-start = "disable"
empty-values = "disable"
float-values = "disable"
hyphens = "enable"
indentation = "enable"
key-duplicates = "enable"
key-ordering = "disable"
new-line-at-end-of-file = "enable"
octal-values = "disable"
quoted-strings = "disable"
trailing-spaces = "enable"

[rules.comments]
level = "warning"

[rules.comments-indentation]
level = "warning"

[rules.empty-lines]
level = "warning"

[rules.line-length]
allow-non-breakable-inline-mappings = false
allow-non-breakable-words = true
max = 160

[rules.new-lines]
level = "warning"

[rules.truthy]
allowed-values = [
    "true",
    "false",
]
check-keys = false
level = "warning"
```

# 総評

- とりあえず早いのはいいことだ
- 既存の yamllint は自動 fix がないので同僚氏たちの承認が得られたら fix 付きで組み込みたい気はする
- コメントスペースあたりは賛否あるよね
- 当面は既存の yamllint と fix なしの ryl を併用してみる予定
- ルールが全部処理できているわけじゃないのと、yaml の仕様に対する違いとかがドキュメントにあるのでよく読む必要がある
- まぁ yaml 1.2 の仕様がどうのとか言ってもみんなそんなに興味ないよねｗｗ

# まとめ

- yamllint alternative ryl 良さそうです
- しばらくは併用で様子見です
