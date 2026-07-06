---
title: "terraform graph -format mermaid が来るっぽいので試してみた"
emoji: "💹"
type: "tech"
topics: ["terraform", "mermaid", "graph"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- [Release v1.16.0-alpha20260706 · hashicorp/terraform](https://github.com/hashicorp/terraform/releases/tag/v1.16.0-alpha20260706) が出ました

> The 'terraform graph' command now accepts a -format flag, and can output graphs in Mermaid format

- ならば試してみるしかないじゃないかってワケ

# terraform graph

- [terraform graph command reference | Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/cli/commands/graph)
- DOT 出力できるので Graphviz で画像化するのが一般的だった
- 作るの面倒だしインストールだるいしリソース数が多いワークスペースだと時間使うわりに実入りの少ない機能（言い過ぎｗ
- サードパーティツールで重要ではないリソースを削って調整することで辛うじて使えるかなとか（それもまた面倒
- で、今回 mermaid 形式で出力できるようになると。たいていの mermaid viewer は拡大縮小機能を備えているので（使い勝手はともかく）少なくても DOT よりはいいんじゃないか

# というわけでやってみた

- X でメモしていたのでダイジェストでどうぞ（こういう時にスクラップ使うんだよｗ
- 最近毎週 terraform の alpha が出てる気がする

@[tweet](https://x.com/raki/status/2074164709616685302)

- とりあえずちょっと試してみた

@[tweet](https://x.com/raki/status/2074189856360861717)

- コード中で `flowchart LR` を文字リテラルベタ打ちしてるんだよね

@[tweet](https://x.com/raki/status/2074193365734977876)

- terraform graph はリソースアドレッシング、つまりリソースコネクションの表現なんだから、architecture diagram か requirement diagram が適切な気はするんだよね

@[tweet](https://x.com/raki/status/2074195554477998536)

- 実コードで試してみた。リソース数の少ないとこ選んだつもりだったんだけどまだ多いな

@[tweet](https://x.com/raki/status/2074203075104112661)

- mermaid のコードしか出力されないので、ドキュメントへの埋め込み等は自分たちで考えないといけない

@[tweet](https://x.com/raki/status/2074205586179469602)

- 画像化したほうが手っ取り早いのかなって

@[tweet](https://x.com/raki/status/2074207257005568044)

- mermaid cli で svg 化することができるらしいのでやってみた

@[tweet](https://x.com/raki/status/2074213809712193662)

- 家の環境は Windows 11 + WSL2 + Ubuntu 24.04 なんだけど、brew install した mermaid cli ではエラーになってしまった（Puppeteerとか使ったことなくてよく知らない）
- docker でいけたのでよしっ（AA略
- `aqua g i` で見たら登録されてなかったっぽ。。。brew にあって aqua にないツールを入れたの久しぶりかも

# まとめ

- terraform v1.16.0-alpha20260706 から `terraform graph -format mermaid` でマーメイド形式のグラフが出力できます
- 残念ながらチャート的にはフローチャートが使われています（Viewerとの兼ね合いと思われる）
- それでも DOT よりは扱いやすいと思われます（出力されたマーメイドはただのインデントされたリソースリストになるので加工しやすい）
- pre-commit-terraform には graph 出力を処理するアクションがないと思うので、CIに組み込むには自分たちで仕掛けを用意しないといけません
- mermaid-cli を使用して svg 化が可能なので、既存のドキュメントへの埋め込みもそんなに手間なくできるかなとか
- terraform v1.16.0 に向けて着実に機能追加が進んでいてうれしいですね
