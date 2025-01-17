---
title: "go-task に以前挙げた課題のワークアラウンド"
emoji: "🛠️"
type: "tech"  # tech or idea
topics: ["taskfile","task","go-task","taskfiledev"]
published: true
---

# tl;dr

- 以前[go-task に issue をあげた](https://zenn.dev/raki/articles/2024-09-23_task_issue)を書いた
- EXIT_CODE が期待通りに渡らないのはこの際もういい
- 元の課題は[taskfile.dev のメモ](https://zenn.dev/raki/scraps/b076f624777be2#comment-7d0ee3b5f2f6fb)に書いた `defer` に変数が渡せないということ
- ワークアラウンドってほどでもないけど回避策としてグローバル変数を上書きする方法にした

# 元の課題について

- task v3.39.0 以降、defer まわりの仕様が変わってしまった
- EXIT_CODE を使えるようにしたため、ということになっているが、EXIT_CODE 自体も ignore_errors が有効だと消えてしまう
- 関連して消えてしまった機能として、defer で呼び出すタスクに vars をつけることができなくなった
- 複数のタスクから呼び出されるため、呼び出し元のタスクで個別に変数を渡していたが、使えなくなってしまったので、値が参照できず、処理がエラーになってしまう
- json schema 的にはいけていたはずなのですぐ直るのかなと思っていた（が、直らないようだ）

# ワークアラウンド

- タスクから defer で変数が渡せないならグローバル変数にすればいいじゃない
- タスクファイルのグローバル `vars` にデフォルトの変数を入れる
- defer からは vars を消す
- defer を呼び出しているタスク中でデフォルトの変数を上書きする

@[card](https://github.com/officel/zenn/pull/172/files#diff-cd2d359855d0301ce190f1ec3b4c572ea690c83747f6df61c9340720e3d2425eR6)

- ちなみに仕様的にはグローバルを置かなくても親タスクが宣言していると伝搬するので大丈夫らしい
- （親タスクの宣言忘れがあるとエラーになるので書くことにしている）

# task について

- GNU Make の代替として task を使うことにした　-> [モダンなタスクランナーを求めて task (taskfile.dev) を使うまでの軌跡](https://zenn.dev/raki/articles/2024-05-30_task_runner)
- ベタ書きしている時はそんなに問題ない
- ちょっと工夫しようかなって時に、ちょいちょい問題に当たる
- [task runner go-task(taskfile.dev) の Advent Calendar をやりませんか](https://zenn.dev/raki/articles/2024-11-09_go-task_adcal)

@[card](https://qiita.com/advent-calendar/2024/go-task)
