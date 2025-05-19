---
title: "git の小ネタ。add に除外パターン"
emoji: "🐙"
type: "tech"  # tech or idea
topics: ["git"]
published: true
---

# tl;dr

- git リポジトリで、add したくないファイルは ignore できる。が、git status で表示されなくなるので存在を忘れることがある
- 一時的にファイルとして置いておき、差分として表示しつつ、リポジトリには追加したくない。要は自分向けの注意喚起ファイルを置いておきたい
- 設定ではどうにもならなかったので `git add` のエイリアスに除外パターンを設定することで対処した

```bash
alias g='git'
alias ga='git add ":!**\!\!*"'  # :! は除外設定。 !! で始まるファイルを add しない
alias gau='git add -u ":!**\!\!*"'
```

# AI

- google 検索のトップに出てくる Search Labs の AI は嘘つきだった
- ![alt text](/images/2025-05-20.png)
- perplexity はできないとした上で、ignore を勧めてくる（要求を汲んでくれない）
- add しちゃった後で、hook を使って restore --stage してしまうというワークアラウンドまではたどり着いた（馬鹿っぽい）
- ツールのほうの pre-commit を愛用しているので、グローバルフックすると面倒だなって（個別のlocal stageでもいいけど）
- 他のAIにもちょっと聞いて、結局どれも `git add -A ':!除外パターン'` は教えてくれた

# できなかった（しなかった）こと

- attributes は使えない
- ignore したいわけじゃない
- hook で restore は、いくつかの理由でやるべきじゃない（と判断した）
- git add に対してグローバル設定で除外パターンを設定するのは無理っぽい
- `git config add.ignore_pattern` みたいな設定があったらよかったのに

# bash alias

- 普段できるだけ bash にしている
- git の alias を用意しているのでそこに追加することにした（tl;drのとおり）
- [Pull Request #30 · officel/config_bash](https://github.com/officel/config_bash/pull/30)
- [Pull Request #31 · officel/config_bash](https://github.com/officel/config_bash/pull/31)

# 経緯とか

- `__` で始まるファイルを ignore してメモ置き場にしている。が、目立たなくなるので忘れがちになる
- 同一のリポジトリで複数の作業をしていて、それぞれ別のメモが欲しくなった
- 作業的にも適用日的にも別々で、ブランチを切るほど作業していなくて、備忘録としておきたかった
- 注意喚起のためのファイルとして `!!` で始まるファイルを常に差分表示しつつ、普段の作業に影響がないようにしたくなった
- というわけ。

# まとめ

```bash
alias g='git'
alias ga='git add ":!**\!\!*"'  # :! は除外設定。 !! で始まるファイルを add しない
alias gau='git add -u ":!**\!\!*"'
```
