---
title: "VS Code の特選キーボードショートカット"
emoji: "⌨️"
type: "tech" # tech or idea
topics: ["vscode", "アドベントカレンダー"]
published: true
---

# tl;dr

- [VS Code - Qiita Advent Calendar 2025](https://qiita.com/advent-calendar/2025/vscode) 3日目の記事です
- 昨日の分を書くにあたって整理したキーボードショートカットについて
- 第1キーを自分の好きなキー（ここでは oem_comma つまり `,`）にして統一していくと覚えやすいよ
- 結局ショートカットって普段使うやつ以外は死蔵されるだけなので、自分のしたいことをベースに整理していく作業なのかなって

# これだけはぜひ持って帰って

```json:keybindings.json
{
  // エディターグループを最大化したまま切替
  "key": "oem_comma e",
  "command": "runCommands",
  "args": {
    "commands": [
      "workbench.action.toggleMaximizeEditorGroup", // なくても大丈夫そう
      "workbench.action.focusNextGroup",
      "workbench.action.toggleMaximizeEditorGroup"
    ]
  }
},
{
  // スクリーンキャストモードの切替
  "key": "oem_comma s",
  "command": "workbench.action.toggleScreencastMode",
},
{
  // ターミナルをフォーカスして最大化する like a zen mode for terminal
  "key": "oem_comma t",
  "command": "runCommands",
  "args": {
    "commands": [
      "workbench.action.terminal.focus",
      "workbench.action.toggleMaximizedPanel",
      "workbench.action.toggleSidebarVisibility"
      // note: 通常時にサイドバーを閉じていると逆に開いてしまうのを分岐したい
    ]
  }
}
```

# エディターグループを最大化したまま切替

```json
{
  // エディターグループを最大化したまま切替
  "key": "oem_comma e",
  "command": "runCommands",
  "args": {
    "commands": [
      "workbench.action.toggleMaximizeEditorGroup",
      "workbench.action.focusNextGroup",
      "workbench.action.toggleMaximizeEditorGroup"
    ]
  }
}
```

- 作業ディレクトリやリポジトリ毎にエディターグループをわけるのよくあるよね
- デフォルトだとマークダウンのプレビューを横に表示とかすると分離するアレ
- エクスプローラービューで、開いているエディターのところがグループ分けされる
- ウルトラワイドディスプレイとかなら困らないかもしれないけど、普通のディスプレイだと横幅ががが
- これを使うとエディターグループを最大化したまま順番に切替ができて便利

# スクリーンキャストモードの切替

```json
{
  // スクリーンキャストモードの切替
  "key": "oem_comma s",
  "command": "workbench.action.toggleScreencastMode",
}
```

- リモートワークの際に VS Code の画面を表示して見せることが多い
- スクリーンキャスト（入力したキーを表示してくれる）を有効にしておくと伝えやすい
- デフォルトではショートカットがついてないので、適当なプレフィックス（ここでは`,`）+sにしておくと覚えやすくていいよ

# Zen mode for terminal

```json
{
  // ターミナルをフォーカスして最大化する like a zen mode for terminal
  "key": "oem_comma t",
  "command": "runCommands",
  "args": {
    "commands": [
      "workbench.action.terminal.focus",
      "workbench.action.toggleMaximizedPanel",
      "workbench.action.toggleSidebarVisibility"
      // note: 通常時にサイドバーを閉じていると逆に開いてしまうのを分岐したい
    ]
  }
}
```

- 以前は Tera Term や Windows 標準のターミナルを使ったりしていた
- 最近はもっぱら VS Code のターミナルで完結させている
- いつでもどこでもターミナルを最大化して作業しやすく
- エディターウィンドウの zen mode とは少し違うけどフルサイズってことで
- コマンド的にはトグルにしたかったのでこう書いてある
- が、プライマリーサイドバーの表示もそれに引きづられる（プライマリー閉じてる時にこれ叩くとターミナルだけで最大化じゃなくてプライマリーも開いてしまう）
- という問題に気がついてセカンダリーは書いていない

# お気づきだろうか

- 以前は複数のコマンドを実行するのに multi-command 機能拡張などが紹介されていた
- どこかのブログでそういう記事を見て俺も使っていた
- キーボードショートカットの整理をしている時に runCommands に気がついて書き直した
- settings.json から multi-command 機能拡張のコードが削減できた
- 難点は keybindings.json には名前や説明を書くためのキーがスキーマ定義されていないので UI 表示の時は全部 runCommands になってしまうこと
- いい整理の機会になった。コメントとキーの並びを統一したし、キーバインディングも見直した

# 細かいやつ

```json
{
  // ターミナル間の移動
  "key": "ctrl+tab",
  "command": "workbench.action.terminal.focusNext",
  "when": "terminalFocus"
},
{
  // ターミナル間の移動（逆方向）使っていないのでなくてもいい
  "key": "ctrl+shift+tab",
  "command": "workbench.action.terminal.focusPrevious",
  "when": "terminalFocus"
},
{
  // パネルの最大化（ターミナルを最大化して表示）
  // oem_3 は @ キー（日本語キーボードの場合）
  // zen mode も書いたので要らないかも
  "key": "ctrl+alt+oem_3"
  "command": "workbench.action.toggleMaximizedPanel",
},
```

- デフォルトでは複数ターミナルを開いている時の切替は alt + ↑↓
- エディターの切替は ctrl + tab なのになんでターミナルは違うの？
- というわけで揃えた
- shift をつけて逆方向への選択も一応書いてあるんだけど、コメントのとおり個人的には使わないので要らないかなとか
- パネルの最大化はデフォルトでショートカットがついていない
- runCommands に気づくまではプライマリサイドバーを出しっぱなしにするか ctrl + b で消していたので zen mode もどきができて不要になった

# いまいちできてないやつ

```json
{
  // エディターでカンマを入力（カンマを第一キーにしているため）
  "key": "oem_comma oem_comma",
  "command": "type",
  "args": {
    "text": ","
  },
  "when": "textInputFocus"
},
{
  // ターミナルでカンマを送信（カンマを第一キーにしているため）
  "key": "oem_comma oem_comma",
  "command": "workbench.action.terminal.sendSequence",
  "args": {
    "text": ","
  },
  "when": "terminalFocus"
},
```

- `oem_comma` は `,` で、入力の機会が少ないから第1キーに設定して自前キーボードショートカットの起点にしている
- システム的には `ctrl + k` を起点にするものが多い（ので別の割り当てにしている）
- 副作用として `,` 自体の入力ができなくなってしまうので、ニ回入力で値を type させている
- つまりこれとセットじゃないと、前述のショートカットをそのまま使うとカンマが入力できなくなる（ここまで読まないとアレっとなる。ちょっとしたお茶目だ）
- それはそれとして when 節には condition が使えるので `"when": "textInputFocus || terminalFocus"` のようにして、これらを 1 つにしたいんだけどうまくいってない（やってみて）
- あとキーボードショートカットの UI の検索ボックスへも `,` が入力できなくて、困ってはいないけどできないことがあるのがわかっているのがむず痒い

# 欲しいけどまだできていないやつ

- 別のエディターグループのファイルを選択したい（`ctrl + tab + なにか` みたいな感じで別のグループのファイルをぱっと呼びたい）
- 新しいエディターグループでファイルを開く（機能拡張の域かもだけどエクスプローラーから指定のエディターグループで開きたい）

# その他

- VSpaceCode 機能拡張（とくっついてくるWhichKey）と vim キーバインドが settings.json に陣取っていたんだけど、vim をやめて整理したので丸ごと消せた
- VSpaceCode 機能拡張はかゆいところに手が届きやすいメニューなんだけど、使ってない機能を選択可能にしてくれるメリットと、自分でやりたいことを検索して適用する学びを比較して検討するの大事かもなって
- 起点になるキーに `,` を使っているのはどこかのブログで使っているのを真似たからなんだけど、利用頻度の低いキーかつ入力しやすい位置のキーであるほうが操作しやすいので、`\`（コード的には `oem_102`）あたりにするといいのかもしれないとうっすら思っている

# 最後に

- みんなのオススメの機能拡張とかキーボードショートカットもっと見たいな
