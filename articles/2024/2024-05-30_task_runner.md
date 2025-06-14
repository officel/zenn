---
title: "モダンなタスクランナーを求めて task (taskfile.dev) を使うまでの軌跡"
emoji: "🏃"
type: "tech"
topics: ["task", "taskfiledev", "make"]
published: true
---

# tl;dr

- GNU Make に代わるタスクランナーが欲しいなって
- 条件を整理
- ひとまず [Task](https://taskfile.dev/) にした

# はじまり

- 以前からタスクランナーとして GNU Make を使っていた
- `alias m="make"`
- ルーチンワークはだいたい `m xx` で片付けていた。正直便利ではあった
- 複数のタスクをまとめて実行した時に、エラー箇所とその続きを処理しなければならない時に手間がかかることがあった（書き方の問題）
- 説明や階層などの作りのルールが暗黙過ぎて、育てれば育てるほど可読性が落ちた（だから書き方の問題）
- そもそも make はビルドツールで、タスクランナーじゃない（考え方の問題）
- ぶっちゃけワンライナーを積み上げる使い方をしているので、alias 化でも問題ない使い方をしている
- Windows 11 + WSL2 + Ubuntu 20.04 -> Ubuntu 24.04 に移行するのを機に、タスクランナーも移行しようと考えた
- せっかくだからモダンなランナーがいいよね

# 条件

## 要件を検討

- 個人で使うけど使えるならチームにも展開したい
- モダンであること（後発であって先人のツールを超える何かであること）
- 運用時に必要なものが増えたり手間がかかるものは避けたい
- 特定の要件に寄ったものは避けたい
- サーバ化は必要としていない（HashiCorp WayPoint は違うということ）
- ローカルでも（CI/CD などの）サーバでも使いやすいとうれしい → ワークフロー的なものにできるといい
- 更新が半年以上停滞しているものは避けたい（それはすでにモダンとは言わない）

## この時点で除外されるもの

- Grunt 等の JS を必要とするビルダーは全部落選（JS のビルドは要件外なのと、それらをラップするランナーが欲しいので）
- Apache 系ビルドツールは落選（モダンじゃないってゆうか Maven とか使うなら GNU Make でいいでしょって）
- [Waypoint by HashiCorp](https://www.waypointproject.io/)（リリース当時は良さげに見えたけどね。ローカルサーバは今回必要としてない）
- [babashka](https://github.com/babashka/babashka)（bb ってコマンド名はタイプしやすくて良さげだけど）
- [Hardhat](https://hardhat.org/)（JS 系だし Ethereum に寄りたいわけでもないので）
- [Buffalo](https://gobuffalo.io/)（開発停止したっぽい？あと日本ではググラビリティが悪そうｗ）
- [realize](https://github.com/oxequa/realize)（Go 用だし？）

## こうであって欲しいもの

- 現時点で半年以内に更新のあるもの（継続した更新が行われているもの）
- できる限り OS を超えて問題ないもの（少なくても Mac と Linux で動くもの。最悪 Windows は動かなくてもいい。WSL 使えばいいので）
- ワンバイナリが望ましい（導入負荷のないものが望ましい → Go や Rust 製に縛られる？）
- YAML かそれに準じる書式であるもの（手抜きをしても可読性が保ちやすいもの）
- ロジックな部分は強く求めない。宣言的な可読性を優先したい

## あると嬉しい機能

- サブディレクトリ以下でも遡って設定を読み込める（make にはない）
- 引数を渡せる（make では擬似的な工夫で処理する）
- テンプレート（Go 系のツールだと go-template を食ってるものが多い）
- インクルード（別ファイルを読み込める）
- 設定ファイルのヒエラルキー（プロジェクト用と個人用を別に管理できる）
- env の読み込み

# 候補

- GitHub は [こんな感じ](https://github.com/search?q=task+runner&type=repositories&s=updated&o=desc&p=1) で検索した
- 国外の OSS 比較サイトやツールの紹介ブログ等を使って探した
- 正直腐るほどあるので、全部は見ていない

条件を踏まえてあれこれ見て回った結果、次の候補が残った。

- [suzuki-shunsuke/cmdx](https://github.com/suzuki-shunsuke/cmdx)
- [go-task/task](https://github.com/go-task/task)

ググラビリティの悪いツールが多い（そりゃ同じような名前がつくよね）ので、しっかり確認できたとは言わない。
が、検討していた内容を踏まえると、これ以上は今のところ見つからなさそう。

# 比較

## 共通

- Go 製である（ワンバイナリ）
- 年単位で開発されており、現在も更新されている
- サブディレクトリ以下でも呼べる（内部タスクの実行時のディレクトリの解釈は異なるみたい）

## cmdx の良さそうなところ

- [aquaproj/aqua](https://github.com/aquaproj/aqua) の作者さんなので使い勝手が似てる（ように見える）
- 日本語で問い合わせができるｗ
- タイムアウトが設定できる（go-task は引数で指定しかできないっぽい？）

## go-task の良さそうなところ

- VS Code の機能拡張がある
- [ドキュメント](https://taskfile.dev/) が充実している
- [設定ファイルの読み込みヒエラルキー](https://taskfile.dev/usage/#supported-file-names) がある。ドットファイルが用意されていたらなおよかった
- コントリビューターの数が多い
- タスク自身にエイリアスが設定できる

# 今回は go-task/task を選択

- 普段から aqua [を使っている](https://zenn.dev/raki/articles/2024-05-16_aqua) ので、揃えで cmdx って目もあったんだけど、揃えない（ロックインしない）も正だと思った
- ぶっちゃけタスクランナーならいつでも入れ替えできる
- go-task のほうが人数差もあってドキュメントや機能が充実しているように見えた

というわけで今回は [go-task/task](https://github.com/go-task/task) を選択することにした。

# 最後に

- 星取表を簡単に作れるツールとか欲しいな
- メリデメの整理方法をもうちょっと勉強するべき
- 英語表現を勉強するべき（ディレクトリを遡って設定ファイルを探す機能って正式名称あるのかしら？最初ディレクトリトラバーサルかなとか思っていたｗ）
- ツールの良し悪しは使ってみないとわからないけど、使うと使い方の問題なんじゃないかって疑心暗鬼が出たりして、収拾ががつかなくなるので今回は使う前に記事を書いた
- しばらく使ったら使用感の記事がかけるという一石二鳥ｗ
