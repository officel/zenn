---
title: "VS Code のキーボードショートカットの掃除をした"
emoji: "🆚"
type: "tech" # tech or idea
topics: ["vscode", "taskfiledev", "taskfile", "gotask"]
published: true
---

# tl;dr

- VS Code のキーボードショートカットが増えすぎて、機能するものとしないものがでてきた
- 確認がてら整理して、不要なものを削除した
- ついでに fortune のデータファイルにして task から呼び出して、tips 表示するようにした

# VS Code のキーボードショートカット

- [Keyboard shortcuts for Visual Studio Code](https://code.visualstudio.com/docs/configure/keybindings)
- `ctrl + k` して `ctrl + s`
- ユーザーのキーバインドを表示でフィルター `@source:user`

# 掃除の基準

- 今は使っていないエクステンションのキーバインドを削除
- どこかの記事で見かけた使わないキーバインドを削除
- 同じ割り当てのショートカットを整理

# 副次効果

- コメントをつけてなくて意味がわからないやつをテストして確認した
- ちょっと使わないと忘れてしまうキーバインドを思い出した
- スニペット呼び出しをショートカットにしている一部をスニペットに移動した
- よくわからないまま他人の設定を真似ていたキーバインドについて再整理した
- 少し前から問題視していたエラーを解消した

## コメント

- VS Code の json はコメントを書いていいやつ（jsonc）なので適宜コメントを残そう
- `ctrl+b` と `ctrl+alt+b` はプライマリサイドバーとセカンダリサイドバーの表示トグルだけど逆にする設定にしていた
- 標準に戻してから気がついたんだけど、マークダウンファイルを開いている時に `ctrl+b` すると強調表示処理が走ってしまう（別のエクステンションかな）
- 再度ひっくり返してコメントを追加しておいた（もう忘れない）

## 使わないと忘れてしまう

- 開発者モードに、スクリーンキャストモードというのがある
- オンラインミーティング等でキーボードの入力を表示してくれるアレ
- 別のエクステンションとの組み合わせで、`, + s` に設定してるんだけど、最近披露する機会がなくて忘れてた

## スニペット

- ベタな入力はスニペットファイルで管理したほうが楽
- 文字列を選択してそこから起動させる時はショートカットのほうが楽
- terraform のスニペット類はスニペットファイルへ移動
- Foam を管理しているワークスペース用にサラウンドスニペット（`[[]]`で囲むとか）はショートカットのまま

## 他人の真似

- 前述の `,` 始まりは VSpaceCode と Vim の合せ技を記事で見た時に真似て書いた
- `,` が入力できなくなる課題があったが、`, + space` で `,` を入力させるキーバインドを作って回避していた
- 今は BSpaceCode も vim も使っていないので（標準的な操作から外れると人に教える時に大変なのでやめた）`,` の入力を `, + space` から `,,`（`,` 2 回打ち）に変更した

## エラー

- しばらく気がついてなかったんだけど、前述のキーバインドのせいで、ターミナルで `,` が入力できなくなっていた
- エディター上では `textInputFocus` 時に `type` でいけるんだけど、ターミナルでは type が使えない
- ターミナル上では `workbench.action.terminal.sendSequence` で送ってあげる必要があった
- おかげでエディターでもターミナルでも `,` 2 回打ちで入力できるようになった
- 正直なところ `,` をシーケンスにしないで `ctrl + k` にすればもうちょっとすっきりする（かもしれない）

# fortune

- 古き良き時代の格言表示ツール
- 個人的にはランダムテキスト表示ツールとして使っている
- 整理した VS Code のキーボードショートカットやスニペットを fortune のデータファイルにした
- `fortune 100% jp_vscode_key` みたいにすると 1 件表示できる
- keybindings.json にコメントを書くより手間はかかってしまうが、tips 的にランダム表示させるとその場でしゅっと試して確認できるので便利

```bash
$ fortune 100% jp_vscode_key

type

{
  "key": "oem_comma oem_comma",
  "command": "type",
  "when": "textInputFocus"
}

カンマを VSpaceCode と Vim mode エクステンションで拡張しているので、二度打ちでそのままカンマが入力されるようにした。
textInputFocus（エディタでの入力中）と、TerminalFocus（ターミナルでの入力中）で設定している。
```

# taskfile.dev

- 当然 ↑ を毎回手打ちするのは面倒なので task に追加した
- `alias t=task` してあって、task のデフォルトタスクに自分のタスクの一覧を表示している
- そこにタスクとして追加したので、`t` だけで毎回ランダムに tips を表示できるようになった

```bash
$ t # 出力内容は少し省略済み
task: Available tasks for this project:
* echo_vars:              echo vars                     (aliases: v)
* lookback:               look back on last month       (aliases: lb)
* til:                    how was today(yesterday)      (aliases: t)
* vscode_tips:            VS Code Keyboard Shortcuts tips      (aliases: vscode)

VS Code Keyboard Shortcuts tips

基本設定: キーボード ショートカットを開く

{
  "key": "ctrl+k ctrl+s",
  "command": "workbench.action.openGlobalKeybindings"
}
```

# まとめ

- 定期的なツールのお掃除は大事
- なんとなくでやってたところをよりよく知る機会
- しばらく使ってないツールや機能の復習も大事
- 今回はユーザー分だけだったけど、そのうちシステムや機能拡張の分も確認しなくっちゃ
