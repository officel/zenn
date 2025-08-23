---
title: "VS Code の機能拡張でステータスバーにビジュアルタイマーを置いてみた"
emoji: "🕒"
type: "tech" # tech or idea
topics: ["vscode", "github", "azure", "devops"]
published: true
---

# tl;dr

- 手慰みに VS Code の機能拡張を AI に作ってもらった
- せっかくだからマーケットプレイスで公開するところまで持ってった
- SVBT Simple Visual Bar Timer です

@[card]([Simple Visual Bar Timer - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=officel.simple-visual-bar-timer))

# AI と戯れ

- 要は AI やってみたでブログ記事を書こうかなって
- どうせゴミを量産するだけなら個人的に欲しいものを作らないとね
- これだ！

@[card](https://www.kingjim.co.jp/sp/vbt10/)

- ちょっと欲しいなって思ってるんだけど、購入には至らなかったツール
- 昨今はワイドなディスプレイも多いし、VS Code を普段遣いしていてデッドスペースになっているステータスバーを有効活用したいなって
- 今回は [Jules - An Asynchronous Coding Agent](https://jules.google/) でやってみよう

# 雑なプロンプト

```text
- VS Code の機能拡張
- ステータスバーの上で動作するバー型のタイマーを作成する
- バー部分をクリックか、コマンドパネルから起動して、タイマーの時間を指定する
- タイマーの時間は最短1分最長60分とし、デフォルトは30分
- | を 10 個使って時間の割合を表現する
- カウントダウン時間も表示する。フォーマットは MM:SS
- 開始ボタンと停止ボタンを絵文字を使い、トグルで表現する
```

- このまんま渡して[初版](https://github.com/officel/SVBT/pull/1)を作ってもらった
- あちこちダメだけど、手直しすれば十分使えそうなコードが出てきたので、手でごにょごにょして体裁を整えた

# 公開

- [VSCode の拡張機能を作る手順](https://zenn.dev/daifukuninja/articles/13a35a8bb3a4a1#%E6%8B%A1%E5%BC%B5%E6%A9%9F%E8%83%BD%E3%81%AE%E5%85%AC%E9%96%8B) から
- [Publishing Extensions | Visual Studio Code Extension API](https://code.visualstudio.com/api/working-with-extensions/publishing-extension) を見ながら登録
- そういえば個人の Azure があったので、Azure ポータルにしゅっと入った
- Azure DevOps でオーガニゼーションもしゅっとできた
- パーソナルアクセストークンを作成するところ、マーケットプレイスのパーミッションをつけるところにうっすら手間取った（リンククリックして開かないと出てこない）
- パブリッシャーの設定値をどうするかとかちょい悩む
- ドキュメントがしっかりしてるので概ね問題なくできた
- パブリッシャー ID を package.json と違う値にしてたので揃えた（エラーになったから）

# 公開前のコマンド（ドキュメントに書いてあるとおり）

```bash
SVBT $ npx vsce login officel
 WARNING  Failed to open credential store. Falling back to storing secrets clear-text in: /home/raki/.vsce
https://marketplace.visualstudio.com/manage/publishers/
Personal Access Token for publisher 'officel': ************************************************************************************

The Personal Access Token verification succeeded for the publisher 'officel'.
SVBT $
```

パブリッシュしようとしたらエラーになった

```bash
SVBT $ npx vsce publish
Executing prepublish script 'npm run vscode:prepublish'...

> simple-visual-bar-timer@0.0.1 vscode:prepublish
> npm run package


> simple-visual-bar-timer@0.0.1 package
> webpack --mode production --devtool hidden-source-map

asset extension.js 2.13 KiB [compared for emit] [minimized] (name: main) 1 related asset
cacheable modules 4.54 KiB
  ./src/extension.ts 3.61 KiB [built] [code generated]
  ./src/Timer.ts 950 bytes [built] [code generated]
external "vscode" 42 bytes [built] [code generated]
external "events" 42 bytes [built] [code generated]
webpack 5.101.3 compiled successfully in 3070 ms
 ERROR  Invalid publisher name 'Office L'. Expected the identifier of a publisher, not its human-friendly name.  Learn more: https://code.visualstudio.com/api/working-with-extensions/publishing-extension#publishing-extensions
```

package.json の publisher を ID に設定した officel に変更する

```bash
SVBT $ npx vsce publish
Executing prepublish script 'npm run vscode:prepublish'...

> simple-visual-bar-timer@0.0.1 vscode:prepublish
> npm run package


> simple-visual-bar-timer@0.0.1 package
> webpack --mode production --devtool hidden-source-map

asset extension.js 2.13 KiB [compared for emit] [minimized] (name: main) 1 related asset
cacheable modules 4.54 KiB
  ./src/extension.ts 3.61 KiB [built] [code generated]
  ./src/Timer.ts 950 bytes [built] [code generated]
external "vscode" 42 bytes [built] [code generated]
external "events" 42 bytes [built] [code generated]
webpack 5.101.3 compiled successfully in 2998 ms
 WARNING  Failed to open credential store. Falling back to storing secrets clear-text in: /home/raki/.vsce
 INFO  Publishing 'officel.simple-visual-bar-timer v0.0.1'...
 INFO  Extension URL (might take a few minutes): https://marketplace.visualstudio.com/items?itemName=officel.simple-visual-bar-timer
 INFO  Hub URL: https://marketplace.visualstudio.com/manage/publishers/officel/extensions/simple-visual-bar-timer/hub
 DONE  Published officel.simple-visual-bar-timer v0.0.1.
SVBT $
```

# 今後について

- VS Code のマーケットプレイスで検索する時はダブルクォーテーションで囲むと早い "simple visual bar timer"
- README に画像置いたり
- コードのリファクタリングしたり（同じ文字列をリテラルベタ書きされてる）
- Copilot にやらせてみたり
- しようかなって

# まとめ

- AI でコード書かせるの、まだちょっとだるい
- ただ、学習レベルが足りてないところでもさっとやってくれるのは便利
- やってみた、はとても大事だけど、自分が欲しいと思うものをちゃんとやるのはもっと大事だと思った
- 最後までもっていく（作る、正しく公開する、ブログを書く、あとは育てる）ための熱量が違うからね
- よかったら使ってみて感想などいただけると喜びますｗ

@[card]([Simple Visual Bar Timer - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=officel.simple-visual-bar-timer))
