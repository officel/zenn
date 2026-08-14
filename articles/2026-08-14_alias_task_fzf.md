---
title: "task を fzf で選択して実行する alias の成長過程"
emoji: "👽"
type: "tech" # tech or idea
topics: ["taskfile.dev", "go-task", "fzf", "alias"]
published: true
---

# tl;dr

@[tweet](https://x.com/taskfiledev/status/2087938185598755294)

- タスクランナーの [Task](https://taskfile.dev/) を推す理由が増えたんじゃないかって
- 以前 [go-task のデフォルトタスク](https://zenn.dev/raki/articles/2024-12-20_raki) って記事を書いていて
- `t` で `task --list --sort alphanumeric` を呼べるようにしていた
- タスクが増えたら fzf で選択して実行したら楽じゃね？
- というわけで現在値

```sh
alias tlr='task --list --json | jq -r .tasks[].name | sort | fzf --preview "task --summary {}" | xargs task'
```

# はじめに

- かねてから go-task をよく使っている
- `alias t='task'` していて、デフォルトタスクを書いているので、`t` だけで常にタスクの一覧を表示している
- GitHub で紹介されるくらいメジャーな OSS になってきた（と思う）ので、チームに紹介（たぶん現職でも2回目）した
- タスクには常に alias を設定するようにしているのでコマンド入力には困ってない
- 困ってないんだけど、もうちょっと、うおーすげー便利ーとか言われたい

# というわけで

- fzf と組み合わせて、タスクの一覧から選択してしゅっとタスクを実行できたらかっこいいかなって
- ペインをわけてプレビューで説明とかでるとかっこいいかなって
- そんな感じで試してみた記録を残しておこうかなって

# 標準的なコマンド例

- 標準で `task --list` （-l はショートオプション）するとこう

```sh
$ task -l
task: Available tasks for this project:
* raki:                       generate articles                  (aliases: r)
* terraform:                  generate articles                  (aliases: t)
* date:format-like-rfc:       date format like RFC               (aliases: date:rfc)
* date:format-sequence:       date format sample                 (aliases: date:fs)
* date:samples:               date samples                       (aliases: date:s)
* raki:git:                   auto git, use -- COMMIT TITLE      (aliases: rg)
* terraform:git:              auto git, use -- COMMIT TITLE      (aliases: tg)
```

- default タスクを設定しておくとこう（このブログのリポジトリに[コードがある](https://github.com/officel/zenn/blob/a9c93d6e7fb77189ca54d8a9523186327a971081/Taskfile.dist.yml#L20)）

```sh
$ t
task: Available tasks for this project:
* date:format-like-rfc:       date format like RFC               (aliases: date:rfc)
* date:format-sequence:       date format sample                 (aliases: date:fs)
* date:samples:               date samples                       (aliases: date:s)
* raki:                       generate articles                  (aliases: r)
* raki:git:                   auto git, use -- COMMIT TITLE      (aliases: rg)
* terraform:                  generate articles                  (aliases: t)
* terraform:git:              auto git, use -- COMMIT TITLE      (aliases: tg)

Showing 4 of 4 open issues in officel/zenn

ID    TITLE               LABELS             UPDATED
#438  08/07 terraform-jp  zenn.terraform-jp  about 7 days ago
#437  08/07 blog          zenn.blog          about 7 days ago
#432  07/21 terraform-jp  zenn.terraform-jp  about 24 days ago
#427  07/07 terraform-jp  zenn.terraform-jp  about 1 month ago
2026-08-14
```

- このブログを書く時は `t r` で個人ブログ用の記事の準備ができて、`t rg` でコミットしてPRしてオートマージされて自動的に公開される（便利）

# ダメというかあまり美しくない例

## 行末のコロンが邪魔

```sh
$ task --list | fzf | cut -d " " -f2
raki:
```

- 普通にコマンドを使うと表示についてくるコロンが邪魔になる

## 末尾コロンをしゅっと消す

```sh
$ task --list | fzf | cut -d " " -f2 | rev | cut -c 2- | rev
raki
```

- `rev | cut | rev` はコマンドラインで末尾削除のイディオムだけどあんまりかっこよくないよね
- 複数コマンドを呼び出しているのが減点なのよ

## 冗長1

```sh
$ task --list --silent
raki
r
terraform
t
date:format-like-rfc
date:rfc
date:format-sequence
date:fs
date:samples
date:s
raki:git
rg
terraform:git
tg
```

- list の出力を抑制すると alias も1行になってしまって、選択がだるい

## 冗長2

```sh
$ task --list --json | jq -cr ".tasks[] | [.name, .desc] | @tsv" | fzf | cut -f1
raki
```

- json 出力にしてあげると name だけにできるのですっきりする
- column コマンドなどを使うとテーブル状に表示できて見やすい

## その他

- awk や sed は重くなるしモダンじゃないなって
- desc は選択時の補助にいいけど、fzf を使って別ペインに詳細を表示するならもっといい方法があるはず？

# いったんの完成形

```sh
$ task --list --json | jq -r .tasks[].name | fzf --preview 'task --summary {}' | xargs task
# 選択したタスクが実行される
```

![実行イメージ](/images/2026-08-14_1.png)

- json 出力した上で name だけを抽出してリストを作る
- fzf に渡して、preview ペインに summary コマンドで詳細を表示
- 選択したものを引き渡して task として実行
- 表示的な期待値は満たせたので alias にするとこう（Task List & Run 的な命名をしたけどしばらく様子見）

```sh
alias tlr='task --list --json | jq -r .tasks[].name | fzf --preview "task --summary {}" | xargs task'
```

## よもやま

- list で sort をしても jq の後で sort しても fzf に渡った時に期待した順にならない？
- LC系の設定のせいかもしれない（絞り込めるのでいったんスルー）
- json path が使えれば jq 要らないのにな
- もしくは list のオプションに exclude alias 的なのがつくとか
- fzf の preview 設定（幅とか位置とか色とか）はどうとでも調整できるけどデフォルトのまま（どうしても必要じゃなければ手を入れないマイルール）
- fzf から抜けないで `--bind` で実行もできるっぽいんだけど、 xargs 引き渡しとどっちがわかりやすいかなって
- 選択する都度 `task --summary xxx` が走るの、自分の環境ではまったく問題ないんだけど、他所ではどうなのかなって
- 選択時に esc すると空で渡っちゃうので（デフォルトタスクが実行される）、困りはしないけどいまいちかもしんまい

# 終わりに

- zoxide みたいな上下ペイン（ウィンドウ）も悪くないんだけど、今回は aqua と同様の左右ペインとした（記述が短くて済むしね）
- いままでは `t` から `t xxx` にしていたけど、これからは `tlr` で一発
- そういう意味では alias t 自体をこれに置き換えても問題ないかもなって（むしろそのほうがいいかも）
- お盆休みの薄い自己学習的な感じってことで

# 最終的に

```sh
alias t='task --list --json | jq -r .tasks[].name | fzf --preview "task --summary {}" | xargs task'
alias ta='task'
alias tl='task --list'
```

- のようにした
- 記事駆動改善的な感じで大変よろしい
- 今まで `t` は `task default`（デフォルトタスクの実行＝`task --list`とほぼ同義、ファイルによる）だったのを `ta` にした
- 新しい `t` はこの記事のとおり fzf でリストから選択してタスクを実行、esc しても `task default` とほぼ同じ
- デフォルトタスクを積んでなかったり、list じゃない時のために `tl` を設定した
- `td` は Treasure Data の CLI とバッティングするので設定しない
- という感じに落ち着いた
