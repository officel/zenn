---
title: "たまにしか使わない git コマンドのメモ"
emoji: "🎍"
type: "tech"  # tech or idea
topics: ["git"]
published: true
---

# tl;dr

- たまにしか使わない git コマンドの備忘録
- 他の手段で代替できると本当に稀にしか使わないので忘れない程度に
- つまり初心者には必要ない

# 逆引き

## origin/HEAD がない場合につける

- 新規リポジトリの作成直後など
- 普段からデタッチしたまま作業していると origin/HEAD がないと困る
- 使わないコマンドの中でも比較的使うほう（新規リポジトリを作ったら使うので）

```bash
git remote set-head origin main


# こんな時に
$ git log HEAD
commit 48d9130c0a3013449f61fe8646e51af9826c6147 (HEAD, origin/main)

# こうしたい
commit 48d9130c0a3013449f61fe8646e51af9826c6147 (HEAD, origin/main, origin/HEAD)
```

## ファイルの権限操作

- バッチファイルとか
- たまにテストもされてないファイルが混じってることもある、、、か？

```bash
git update-index --add --chmod=+x [filename]
```

## 別のブランチのファイルを表示する

- diff だとわかりにくい時に
- リダイレクトして別名のファイルにして使うとか
- 取得（checkout）したほうが早くない？

```bash
# ブランチ名:ファイル名　ということ
git show main:README.md
```

## リモートブランチを削除

- GitHub 等なら Web の UI で消せる
- そもそも `Automatically delete head branches` をオンにしていると機会がないかも
- 作業用のブランチをいつまでもとっておく派の人とは相容れない

```bash
# : の後にリモートブランチ名
git push origin :[branch_name]
```

## リモートのタグをリスト

- 普段 `git fetch --all --prune` しているのでローカルにも同じものがだいたいある
- ローカルのタグは `git tag -n` とか

```bash
git ls-remote --tags
```

## ファイルの更新を確認

- ブラウザで見るほうがずっと見やすいので使わない
- 自分で更新したところじゃないのを一瞬確認する、くらいの時には叩いてみる

```bash
git blame [filename]
```

## ブランチを切り替える

- リリースされた時に少し使ったけど、`git checkout HASH` で事足りているので使っていない
- git switch でブランチをあちこち移動して仕事をするのって、作業のやり方か内容を見直したほうがよくない？って思ってる
- もっとも、普段からブランチで作業をしてないせいなだけかも

```bash
git switch
```

## おまけ

- 普段インフラ的なコードを書いていて、テストを書かないので `git bisect` を活用したことがない

# まとめ

- よく使うコマンド類は他の人がよく書くので逆に使わないほうを書いてみた
- ときどきコマンドの棚卸しとか他の人の作業方法とか見ないと改善とかできないので、どこかでこういう特定の技術に依らないモブプログラミングとかしたい
- git がすでに特定の技術ってことはこの際置いておく
