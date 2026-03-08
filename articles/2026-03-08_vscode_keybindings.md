---
title: "VS Code の特選キーボードショートカットその２"
emoji: "⌨️"
type: "tech" # tech or idea
topics: ["vscode"]
published: true
---

# tl;dr

- 四半期に一度程度、設定の見直しをすることにしている
- VS Code のキーボードショートカットを少し入れ替えたので紹介

# VS Code のキーボードショートカット

- `ctrl+shift+p` から呼び出すか `ctrl+k ctrl+s`
- 自前のショートカットは json で編集したほうが手っ取り早い
- 前回の紹介

@[card](https://zenn.dev/raki/articles/2025-12-03_vscode_keybindings)

# 変更点

## 第一キーの変更

- 前回の最後にも書いているが、第1キーを `,` から `\ (oem_102)` に変更した
- カンマのほうが使用頻度が高かったのと、`\` のほうが入力しやすいことに気がついた

## スキーマ？

- 前回の記事を書いていた時、キーバインドのスキーマにないキーを立てるとエラーになっていた（と思う）
- 現在やってみると問題なく使えたので、コメントをいくつか整理した
- 将来的な公式の変更とバッティングするのを避けるため、`_title` のようなキーにした（アンダーバー始まりをプライベートとして扱うのはプログラマあるある）

## キーバインドの検索

- 前回の記事でできないこととして書いた `\` をキーボードショートカットのUIで検索できない件について
- `alt+k`（キーを記録）で入力可能であることに気がついた
- 単独では検索できないままだが、runCommands はUIでちゃんと表示されないし、あまり意味がないので放置することにした

# 新しいショートカット

## 新しいエディターグループを開く

- デフォルトだと `ctrl+1`, `ctrl+2` などでエディターグループが切り替えられる
- ただしグループ2が開いていないとグループ3以降は開けない（開いているエディターグループの次のエディターグループしか開けない）
- そこでこう

```json
  {
    "_title": "新しいエディターグループを開く",
    "_comment": "新しいファイルを開いて、次のエディターグループに移動して、エディターグループを最大化",
    "key": "oem_102 n",
    "command": "runCommands",
    "args": {
      "commands": [
        "workbench.action.files.newUntitledFile",
        "workbench.action.moveEditorToNextGroup",
        "workbench.action.toggleMaximizeEditorGroup"
        // "workbench.action.closeActiveEditor"
        // note: 新しいファイルを開いた後に閉じると、元のエディターグループに戻ってしまうのでコメントアウト
      ]
    }
  },
```

- 正確には今開いているエディターグループの次のエディターグループが開く（その上新しいファイルが開く）
- 機能的にはいまいちだが実用充分なので満足している

## エディターの画面共有モード

- 業務中に画面共有でエディターを表示することがよくある
- うちはデスクトップPCで画面解像度も少し高いので、そのまま共有すると相手先では小さくで見えにくいことがある
- そこでこう

```json
  {
    "_title": "エディターを画面共有モードにする",
    "key": "oem_102 1",
    "command": "runCommands",
    "args": {
      "commands": [
        // サイドバーを閉じる
        "workbench.action.closeSidebar",
        "workbench.action.closeAuxiliaryBar",
        // ターミナルにフォーカスしてトグルすると閉じる
        "workbench.action.terminal.focus",
        "workbench.action.terminal.toggleTerminal",
        // エディターにフォーカスして最大化
        "workbench.action.focusFirstEditorGroup",
        "workbench.action.toggleMaximizeEditorGroup",
        // スクリーンキャストモードを切り替える（トグルしかない。もう一度呼べばOK）
        "workbench.action.toggleScreencastMode",
        // 繰り返し呼び出しても同じサイズになるようにズームをリセット
        "workbench.action.zoomReset",
        "workbench.action.zoomIn",
        "workbench.action.zoomIn",
        "workbench.action.zoomIn",
      ]
    }
  },
  {
    "_title": "エディターを画面共有モードにする",
    "key": "oem_102 2",
    "command": "runCommands",
    "args": {
      "commands": [
        // サイドバーを閉じる
        "workbench.action.closeSidebar",
        "workbench.action.closeAuxiliaryBar",
        // ターミナルにフォーカスしてトグルすると閉じる
        "workbench.action.terminal.focus",
        "workbench.action.terminal.toggleTerminal",
        // エディターにフォーカスして最大化
        "workbench.action.focusSecondEditorGroup",  // キー割当に応じて変更すれば増やせる（今のところ必要ない）
        "workbench.action.toggleMaximizeEditorGroup",
        // スクリーンキャストモードを切り替える（トグルしかない。もう一度呼べばOK）
        "workbench.action.toggleScreencastMode",
        // 繰り返し呼び出しても同じサイズになるようにズームをリセット
        "workbench.action.zoomReset",
        "workbench.action.zoomIn",
        "workbench.action.zoomIn",
        "workbench.action.zoomIn",
      ]
    }
  },
```

- 先のとおり、エディターグループの切替は `ctrl+1`, `ctrl+2` ... なので、`\ 1`, `\ 2` のようにした
- エディターグループの切替と違ってグループを最大化して表示できるので便利
- スクリーンキャストモードはトグルしかできないようなので2回入力でスイッチできる（もちろん前回の `\ s` で切替もできる）
- ZoomInの回数で拡大表示をお好みで調整できる
- なにより画面共有で VS Code を見せてからしゅっと切替するとかっこいい（そう？）

## ターミナルの画面共有モード

- どちらかといえばエディターよりもターミナル（VS Code のターミナルを使っている）を見せるほうが多い
- 当然こう

```json
  {
    "_title": "ターミナルを画面共有モードにする",
    "key": "oem_102 9",
    "command": "runCommands",
    "args": {
      "commands": [
        // サイドバーを閉じる
        "workbench.action.closeSidebar",
        "workbench.action.closeAuxiliaryBar",
        // ターミナルにフォーカスしてトグルして最大化（常に最大化される）
        "workbench.action.terminal.focus",
        "workbench.action.terminal.toggleTerminal",
        "workbench.action.toggleMaximizedPanel",
        // スクリーンキャストモードを切り替える（トグルしかない。もう一度呼べばOK）
        "workbench.action.toggleScreencastMode",
        // 繰り返し呼び出しても同じサイズになるようにズームをリセット
        "workbench.action.zoomReset",
        "workbench.action.zoomIn",
        "workbench.action.zoomIn",
        "workbench.action.zoomIn",
      ]
    }
  },
```

- デフォルトでエディターグループは5までしかないので6でもいいんだけど（6はtの斜め上だし）気分で9にしている
- エディターグループよりターミナルのほうがスクリーンキャストモードが生きるし、何をしているかを伝えやすい

## 当然もとに戻したい

- 普段の自分の作業時はプライマリサイドバーが必要
- 画面共有が終わればもとに戻したいのが人情
- ならばこうだ

```json
  {
    "_title": "普段の作業モードにする",
    "key": "oem_102 0",
    "command": "runCommands",
    "args": {
      "commands": [
        // プライマリサイドバーを表示、セカンダリーサイドバーは非表示
        "workbench.action.focusSideBar",
        "workbench.action.closeAuxiliaryBar",
        // ターミナルを表示
        "workbench.action.terminal.focus",
        // エディターグループ１を表示して最大化
        "workbench.action.focusFirstEditorGroup",
        "workbench.action.toggleMaximizeEditorGroup",
        // スクリーンキャストモードを切り替える（トグルしかない。もう一度呼べばOK）
        "workbench.action.toggleScreencastMode",
        // 繰り返し呼び出しても同じサイズになるようにズームをリセット
        "workbench.action.zoomReset",
      ]
    }
  },
```

- ズーム後はサイドバーやターミナルの横幅が変わってしまうのをなんとかしたいが、VS Code では（標準的には）だめみたい
- 今後いろいろ変更していっても `\ 0` で普段の状態に近いレイアウトには戻せるので重宝する

# まとめ

- VS Code に限らないけど、自分の使う道具を使いやすく整備するのは大事
- 定期的に見直しや改善をするとブログのネタにできるぞｗ
