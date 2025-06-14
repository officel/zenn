---
title: "go-task に issue をあげた"
emoji: "🤔"
type: "tech" # tech or idea
topics: ["task", "taskfile", "taskfiledev", "issue"]
published: true
---

# tl;dr

- v3.39.0 以降で ignore_issue, EXIT_CODE, vars 辺りがおかしくなった
- [EXIT_CODE is empty when ignore_error:true · Issue #1826 · go-task/task](https://github.com/go-task/task/issues/1826)

# できていたこと

- [zenn/Taskfile.yml at main · officel/zenn](https://github.com/officel/zenn/blob/main/Taskfile.yml#L176)
- このリポジトリで git まわりを自動化していた
- v3.38 までは問題なく動いていた

# 問題になったこと

- v3.39.0 から、処理後に rm がエラーになって、git reset が走ってしまうようになった
- `rm: オペランドがありません` という task とは関係がない処理のエラーだと思っていた
- rm の引数にしている ON_ERROR のファイル名が渡されなくなった？
- [一連の流れを scrap に書いた](https://zenn.dev/link/comments/7d0ee3b5f2f6fb)
- とりあえず EXIT_CODE まわりは 2 回の更新を経て解消されたようだ
- が、 `ignore_error:true` だとやはりダメ（EXIT_CODE が渡らない）
- また、defer で変数渡しがダメになったところがまだうまくいってない

# 回避

- 途中経過にあるように、EXIT_CODE に関連して vars が渡らない、のは解決したようだ
- `ignore_error: true` の場合に EXIT_CODE や vars が渡らない？
- とりあえず issue を書いた
- 別件で作業をしていて、ignore_error を外せば回避できた（ように見えたが違うみたい）
- Go 力が足りなくて、なぜ ignore_error の場合に vars が消えてしまうのかわからなかった（反省

# まとめ

- Make から移行して早 4 か月近く、バージョンアップで明確にバグったのははじめて
- もっと Go 力をつけて、解消できるようになりたい
- ignore_error は task からのエラーメッセージ（標準エラー出力される）を出したくないだけ
- 機能的に修正されるか、エラーメッセージの抑止がフラグでコントロールできるようになればいいな

# 余談

- 同僚氏が task を使い始めたと聞いた
- もうちょっと仲間が増えるといいね
- ユーザーコミュニティがあるといいのかな
