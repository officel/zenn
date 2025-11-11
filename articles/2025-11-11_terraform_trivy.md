---
title: "これから始める trivy"
emoji: "🐣"
type: "tech"
topics: ["terraform", "trivy", "tfsec"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- これから trivy を始める人向け
- まだ Terraform しかチェックできていない。。。

# trivy

@[card](https://trivy.dev/)

- terraform の構成ファイルなどの脆弱性や設定誤りをチェックしてくれるツール
- terraform 向けに [tfsec](https://github.com/aquasecurity/tfsec) があったが、trivy に統合されるということで移行が推奨されている
- IaC の一環として、PR 時にチェックするようにしたい
- trivy してねぇやついるぅ？いねぇよなぁ（イメージ略）

# 経緯

- [これから始める terraform-docs](https://zenn.dev/terraform_jp/articles/2025-10-23_terraform-docs)
- [これから始める tflint](https://zenn.dev/terraform_jp/articles/2025-11-03_terraform_tflint)
- ついでだから trivy も書こうかなって
- 前 2 つの記事に書いたとおり、これまではこれらのツールを使っていなかった
- 現職では PFE として割と自由に（業務委託のフリーランスな自分にも）やらせてもらっているので、せっかくだからよりよい環境構築のためにちょこちょこ試している
- docs と lint は提供済の機能に大きな影響がない（ようにしている）のですでにリポジトリに登録して使っているが、trivy のチェック結果は対応するために影響が大きいのでいったん様子見中

# 説明を省略すること

- インストールはお好みでどうぞ。[aqua](https://aquaproj.github.io/) が便利です
- terraform のリポジトリでしか使っていないので、他のチェックのことはまだ見ていません
- tfsec については過去のものとして取り扱いません

# 使用方法

```bash
# trivy は alias を作らない（実践未投入なのと、いい塩梅の省略が決められなかった）

# バージョンの確認
trivy -v

# ヘルプ
trivy -h

# .tf ファイルが下層にあるディレクトリで
trivy config .

# カレントディレクトリ（.）を指定するだけで再帰的に下層ディレクトリをチェックしてくれるので便利
```

# 設定ファイルの調整

- 設定ファイルを必要とせずにだいたい機能する
- リポジトリルートから実行するとチェックしなくていいディレクトリも見てくれてしまうので除外ディレクトリだけ指定するようにした

```yaml
# trivy.yaml
scan:
  skip-dirs:
    - ".config/**"
    - "backup/**"
```

- チェックの除外については `.trivyignore` に書ける
- チェックから除外したい ID を追加しておけるが、ご利用は計画的に、だと思う

```ini
# .trivyignore
AVD-AWS-0104
```

# 実行

```bash
trivy config .
```

- `-c trivy.yaml` のように設定ファイルを渡せる
- `--ignorefile .trivyignore` のように除外設定ファイルを渡せる
- 指摘の多いディレクトリとそうでもないディレクトリとあって、どうしようか思案中
- 指摘内容について精査できていないのと、tflint のようにそうあるべきという指摘にいまいち納得できないものがある（AWS の SG で egress 0.0.0.0 はだめって出るっぽいんだけど、場合によるよなぁ？とか？）
- というわけで trivy についてのチェック内容の精査は今後の課題
- ゆえに自動化への対応も pre-commit への適用も未精査
- もうしばらくの間は受け持ちのディレクトリでこっそりチェックしつつ精査していく予定

# task

- 自動で再帰的に処理してくれるのでリポジトリルートに設定を置いておいてそこから実行すればいい気もする
- ディレクトリやリソースが多いとか、担当があるとか、つまり現職ではまとめてどかんは向いていないので各ディレクトリでも問題ないようにした（docs や lint と同じになってるだけともいう）
- 基本的に ignore による除外は避けたいと思っているので今のところ対応なし（前述のとおり指定はできる）
- 他のターゲットをチェックしたりするのと混ぜるときは注意がいるかもしんまい

```yaml
tasks:
  trivy:
    desc: Run trivy for Terraform
    aliases:
      - t
      - trivy
    vars:
      CONFIG_FILE: "trivy.yaml"
      CONFIG_FILE_PATH: "{{relPath .USER_WORKING_DIR .TASKFILE_DIR}}/{{.CONFIG_FILE}}"
    cmds:
      - trivy config -c {{.CONFIG_FILE_PATH}} .
    dir: "{{.USER_WORKING_DIR}}"
    silent: false
```

# 主観

- tfsec をちゃんと使ってなかったのでアレだけど、細かい設定はできない？
- 他のターゲットのチェックもどこかでやっていかねば
- とくに k8s でどういうチェックができるのかとか（今全然見てない）
- [Rego](https://www.openpolicyagent.org/docs/policy-language) がチェックできる？らしいんだけど、現職 Sentinel なので。。。
- 結局動くのが優先なので対応は後回しになってしまう（なっている）けど、ちょいちょい時間見つけて調べていきたい
