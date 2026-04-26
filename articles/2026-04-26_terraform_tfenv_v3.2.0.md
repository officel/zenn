---
title: "tfenv が数年ぶりにアップデート"
emoji: "🆙"
type: "tech"
topics: ["terraform", "tfenv"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- [Release v3.2.0 · tfutils/tfenv](https://github.com/tfutils/tfenv/releases/tag/v3.2.0)
- terraform のバージョンマネージャーである tfenv が v3.0.0 から約4年近く経ってアップデートされた
- [terraform のバージョンマネージャー選び](https://zenn.dev/terraform_jp/articles/2024-08-22_terraform_version_manager) なんて記事も書いていたが
- まだ現役だねということで記事にした

# tfenv とは

- terraform のバージョンマネージャー
- ディレクトリ毎に使用バージョンを変更できる
- 一般的な業務では同一組織内では統一された同一バージョンを使用すると思うが、複数の組織に所属していたり、モジュールを最低バージョン保証で書いていたりする場合に役に立つ
- v3.0.0 がリリースされたのは 2022-07-22 ってことになっているので、実に3年と9カ月ぶりのバージョンアップ
- tl;dr にもリンクしたとおり、あまりにも更新されないので別のツールへの乗り換えも検討していた
- 今回のバージョンアップで AGENT.md をはじめ、AIや人向けのガイドが充実したようだ

# AI にバージョンアップを分析してもらった

- バージョンアップの差分を渡してブログの記事にするように指示した

:::details AIによる説明

# tfenv が数年ぶりに復活的アップデート：v3.0.0 → v3.2.0 差分まとめ

Terraform のバージョンマネージャである tfenv において、2022年の v3.0.0 以来ほぼ更新が止まっていた状態から、突如として v3.1.0 / v3.2.0 が連続リリースされた。

特に v3.1.0 → v3.2.0 は「数時間差」でリリースされており、実質的に一連の大規模アップデートとして扱うのが自然である。

本記事では、v3.0.0 から v3.2.0 までの差分を整理し、今回のアップデートのトピックをまとめる。

---

# 全体像：今回のアップデートの性質

結論から言うと、今回のアップデートは以下の3つに集約できる。

* Terraform ワークフローへの適応強化
* CI/CD・大規模運用への対応
* UX（CLI操作性）の改善

v3.0.0 が内部改善中心だったのに対し、v3.1.0 / v3.2.0 は「実運用での使い勝手」に明確に踏み込んでいる。

---

# v3.0.0 の位置づけ（前提）

v3.0.0 の主な内容は以下：

* bashlog のリファクタリング
* macOS 周りの修正
* auto install / use ロジック修正
* private mirror（netrc / reverse）対応 ([GitHub][1])

ポイントは「基盤の整理と安定化」であり、機能的な進化は限定的だった。

---

# トピック1：Terraform バージョン解決ロジックの強化

## required_version の解釈強化

v3.1.0 の最大の変更点はこれ。

* `latest-allowed` が Terraform の `required_version` を解釈可能に
* `=`, `>=`, `>`, `<=`, `~>` に対応 ([New Releases][2])

### 意味

これにより：

* `.terraform-version` に依存しなくても良いケースが増える
* Terraform コードから直接バージョンを解決できる

### 実務インパクト

* モジュールごとに version pin されている環境との親和性向上
* CI/CD でのバージョン管理がより declarative に

---

# トピック2：エンタープライズ / CI向け機能の強化

## リモートチェックのスキップ

* `TFENV_SKIP_REMOTE_CHECK` が追加 ([New Releases][2])

### 意味

* インストール時の remote API 呼び出しを抑制可能
* オフライン / 制限環境での利用が現実的に

---

## カスタムミラー対応の強化

* Artifactory 等との互換性改善 ([New Releases][2])
* v3.0.0 の reverse remote 対応の延長線

### 意味

* 企業内ミラー前提の Terraform 配布に対応

---

## インストール競合対策（ロック）

* バージョンごとの file lock を導入 ([New Releases][2])

### 意味

* 並列実行時の race condition を防止

### 実務インパクト

* CI での並列 job 実行時に安全性向上

---

## Docker サポート

* Dockerfile 提供（E2E テスト用途） ([New Releases][2])

### 意味

* コンテナベースの利用が公式に考慮されるように

---

# トピック3：CLI UX の改善（地味に重要）

## `.terraform-version` にコメント対応

* `#` コメント・インラインコメント対応 ([New Releases][3])

### Before

```text
1.5.0
```

### After

```text
1.5.0 # production
```

### 意味

* ドキュメント性の向上
* チーム運用での可読性改善

---

## `tfenv use -`（直前バージョンに戻る）

* シェル的な「直前に戻る」操作が可能に ([New Releases][3])

### 意味

* バージョン切り替えの試行が容易に

---

## `tfenv uninstall` の複数指定

* 複数バージョンを一括削除可能 ([New Releases][3])

### 意味

* キャッシュ整理・CI cleanup が楽に

---

## `tfenv list` にアーキテクチャ表示

* `amd64 / arm64` を明示表示 ([New Releases][3])

### 意味

* Apple Silicon 環境などでの混乱を軽減

---

## bashlog の遅延ロード

* shell interactive 時のみ有効化 ([New Releases][2])

### 意味

* 非対話環境（CI）でのオーバーヘッド削減

---

# トピック4：バグ修正と挙動の明確化

主な変更：

* `latest` が pre-release を除外する仕様へ ([New Releases][2])
* CLI 引数が env var より優先されるよう修正 ([New Releases][2])

## 意味

* より直感的な CLI 挙動
* 予期しないバージョン選択の防止

---

# まとめ：アップデートの本質

今回のアップデートは単なる機能追加ではなく、 **「ローカル開発ツール → 運用ツール」への進化** と言える。

特に重要なのは以下：

* Terraform コードとの統合（required_version）
* CI/CD / 並列実行への耐性
* エンタープライズ環境（ミラー・オフライン）対応

---

# 個人的な注目ポイント

優先度順に並べると：

1. `latest-allowed` の進化（最重要）
2. install lock（CI 安定化）
3. remote check スキップ
4. コメント付き `.terraform-version`

---

# おわりに

数年間ほぼ更新が止まっていた tfenv が、ここに来て実運用寄りに大きく進化した。

Terraform のバージョン管理は依然として課題になりやすい領域であり、今回のアップデートによって tfenv は再び有力な選択肢として復活したと言える。

特に以下のような環境ではアップデートの恩恵が大きい：

* CI/CD で Terraform を実行している
* 複数バージョンを横断して運用している
* private mirror / オフライン環境を使っている

アップグレードは比較的安全な範囲に収まっているため、積極的に検証してよいタイミング。

[1]: https://github.com/tfutils/tfenv/releases?utm_source=chatgpt.com "Releases · tfutils/tfenv · GitHub"
[2]: https://newreleases.io/project/github/tfutils/tfenv/release/v3.1.0?utm_source=chatgpt.com "tfutils/tfenv v3.1.0 on GitHub"
[3]: https://newreleases.io/project/github/tfutils/tfenv/release/v3.2.0?utm_source=chatgpt.com "tfutils/tfenv v3.2.0 on GitHub"

:::

- AI の書いた内容はコピペなので検証はしてない
- 参考程度でいいんじゃないかな

# まとめ

- tfenv がバージョンアップしてめでたい
- 解決できていない terraform ネタがあって詰まっていたのでちょっとお茶を濁したｗ
- とりあえず `terraform version` して `v1.14.9` 以外を使っているようなら導入を検討したほうがいいんじゃないかな
