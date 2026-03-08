---
title: "date コマンドの差異に気がついていなかった話（Taskfile）"
emoji: "⌨"
type: "tech" # tech or idea
topics: ["taskfiledev", "taskfile", "gotask", "GNU", "BSD"]
published: true
---

# tl;dr

- コマンドのオプション差異を忘れていた
- OS 、パッケージの違いを意識すること
- 出し分けるの面倒なのでもうちょっといい方法はないかしら

# taskfile

@[card](https://taskfile.dev/)

@[card](https://zenn.dev/topics/taskfiledev)

- 今んとこ zenn では、task, gotask, taskfile, などのトピックが使われている
- いまいち統一されていないので、ドメインそのままの taskfiledev を以前から推している

# 経緯

- 職場の朝会で、小咄ついでにタスクランナーの taskfile を紹介した
- 同僚氏が気に入ってくれて使ってみたところ、うまく動かないケースが発覚した
- `date` コマンドのオプション差異で日付が取得できなかったらしい

# 原因

- うちは Windows 11 + WSL 2 + Ubuntu 24.04 + bash なので GNU 版のコマンドが使われている
- 同僚氏は Mac なので BSD 版のコマンドが使われていた
- `date -I` を好んで使っていたが、BSD 版では `date -I date` または `date "+%Y-%m-%d"` のようにする必要があった
- 手抜きして taskfile 内でシェルコマンド使うのが悪い

# 回避策

- シェルコマンドを taskfile 内で直接呼ばないのがもっとも正しい
- OS 差異（含むコマンド差異）の吸収は[ファイルを分ける](https://taskfile.dev/usage/#os-specific-taskfiles)ことで可能
- 正直めんどい
- シェルコマンド自体で差分を吸収した書き方をすればいったん大丈夫
- `date` ならフォーマットオプションをベタ書き（`date "+%Y-%m-%d"`）すれば大丈夫（元々これがだるいから `-I` にしたわけだけど）
- ヒューマンリーダブルオプション（`last month`など）が使えないのが痛い
- 他のコマンド類の差異はどうする（awk はともかく sed はだめかも）

# ひとまず

- タスク毎にコマンド実行していた部分を変数に置き換え、コマンド実行部分を一箇所にした
- `date -I` は `date "+%Y-%m-%d` でいいので置き換えた

@[card](https://github.com/officel/zenn/pull/253/files)

# まとめ

- 手元に Mac がないので差分を気にするの忘れてた（新しい Mac 買おう）
- OS やパッケージの違いに注意するのを忘れない
- `date` コマンドのオプション差異を吸収した書き方を整理しておく（他のリポジトリの使用中のものを修正する必要がある）
- `taskfiledev` トピックを推していくｗ
