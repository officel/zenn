---
title: "Technology Radar"
emoji: "📡"
type: "tech"  # tech or idea
topics: ["Thoughtworks", "techniques", "platforms", "languages", "frameworks"]
published: true
---

# tl;dr

- [Technology Radar | An opinionated guide to today's technology landscape | Thoughtworks](https://www.thoughtworks.com/radar)
- Thoughtworks による独自のテクノロジーガイド。年2回更新
- 若干情報が遅かったりするけど、少し前までのトレンドとしては大変優秀（だと思う）
- 近年はLLM系が話題の中心
- このレーダーを [自分で作るOSS版](https://www.thoughtworks.com/radar/byor) がある
- やってみたもの [officel/byor: Build Your Own Radar visualization tool's data](https://github.com/officel/byor)

# Technology Radar

- IT業界の流行り廃りのレーダーチャート
- 技術選定時の評価の参考にしていた
- 概ね対象のツールやテクニックなどについて、外から入ってきて中心に抜けて卒業（殿堂入り的な）していく
- たとえば [Terraform | Technology Radar | Thoughtworks](https://www.thoughtworks.com/radar/tools/terraform)
- たとえば [OpenTofu | Technology Radar | Thoughtworks](https://www.thoughtworks.com/radar/tools/opentofu)
- 公平かどうかはものによる（気がする）
- 殿堂入りしたから消えたのか、もう流行らないから消えたのか、はいまいちわかりにくい（全部常に追うの面倒ですし）

# byor

- 自分用のレーダーチャートを作れる仕組み
- [ローカルで実行するツールのリポジトリ](https://github.com/thoughtworks/build-your-own-radar)
- json か csv を渡せば公開できる [Build your own Radar](https://radar.thoughtworks.com/)
- 情報収集に使われる（ことに利用規約的にはなっている）ので気になる人は注意

# 自分の

- [officel/byor: Build Your Own Radar visualization tool's data](https://github.com/officel/byor)
- 自分のスキルや知見、現在の様子などを残してみようと思って。
- 単純な [json](https://github.com/officel/byor/blob/main/Office_L.json) でレーダーはできる
- 本家のように説明や履歴を残せるようにしたくて、データをマークダウンで書いて、python で front matter を引っこ抜いて json を出力している
- タグを切って固定の json への URL を作ることでレーダーの履歴も作れるようにした（マークダウンは更新されてしまうけど）
- スキルスタックの整理によろしいかと

# 今後

- もう使わなくなったり使えなくなったりしたものをどうするか検討中
- Q毎に更新していくブランチを作成済。次回は9月に更新予定
- 他の人のレーダーも見てみたい（ので作ったらコメントで教えてください）
