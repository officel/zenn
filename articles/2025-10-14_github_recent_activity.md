---
title: "GitHub の Dashboard から Recent Activity が消えてしまったので"
emoji: "💨"
type: "tech" # tech or idea
topics: ["github", "dashboard"]
published: true
---

# tl;dr

- GitHub の dashboard から Recent Activity が消えた（以下、旧アクティビティ）
- ひとまず View で我慢（以下、新アクティビティ）
- Open したまま放置していた Issue を片付けたい
- GitHub Projects で Draft Item をバックログとして扱い、新アクティビティをクリーンに保ちたい

# ことのはじまり

- GitHub の dashboard の左ペインから recent activity が消えた（以下、旧アクティビティ）

@[tweet](https://x.com/raki/status/1976042459240268218)

- chrome のタブで固定表示しておく程度には常に使っていたんだけど。。。

# なんでやねん

- community でも話題沸騰（そうでもない）
- [Recent activity panel is gone from dashboard · community · Discussion #176283](https://github.com/orgs/community/discussions/176283)
- コメントにもあるとおり、issue の view でも作れというアドバイス
- 個人的には旧アクティビティには PR も含まれていたし、コレジャナイ感がある（View の工夫次第で作れるけど）
- 戻ってこないものは仕方がないので、view を作った（以下、新アクティビティ）
- アイコンと色も変えられるので常時開いておくのはこっちになりそう

@[tweet](https://x.com/raki/status/1977616591987912909)

- 新アクティビティとした View にもいいところはあって、リストを表示したまま右ペインで issue が開くので、順番に issue を片付けたい時にとても便利
- 日課の issue を立てていて、終了した昨日の分を確認して閉じて、今日の分を開いて、というルーチンワークがスムーズになった

# そして

- この機会に issue が放置されて溜まっているのを整理することにした
- GitHub の issue にはバックログがないからなと思ったが、Projects の存在を思い出した
- GitHub Projects は draft item が作れるので

  1. GitHub Projects で draft item を作る（バックログとして扱う。新アクティビティにリストされない）
  2. 作業対象にしたら issue 化する（新アクティビティにリストされる）
  3. 通常どおり issue を消化する

- という感じに落ち着いた（というか思い出した）
- projects に一発で飛べるようにして欲しいなぁ（リポジトリの種類に合わせて複数のプロジェクトを使っている）
- 長いこと放置していた issue もやるやらを決めてだいぶ整理した（まだ残ってる）

# これから

- GitHub におかれましては dashboard の Recent Activity をもとに戻していただきたく
- なんでも issue をあらため、projects の Draft Item でバックログ化して作業するのをルーチン化し、放置 issue を撲滅していきたい所存
