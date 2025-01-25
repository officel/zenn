---
title: "New Relic の NRQL でメトリクスをグループ化"
emoji: "📈"
type: "tech"  # tech or idea
topics: ["newrelic","nrql"]
published: true
---

# tl;dr

- New Relic を使っている職場にいるので nrql を覚えたい
- メトリクス名をリストできる
- グループ化してわかりやすくしたい
- あんまりわかりやすくならなかった

# New Relic

@[card](https://newrelic.com/jp)

- 以前は DataDog だったんだけど、最近 New Relic を使っている
- 見た目とか使い方の違いに慣れないといけないなと思って nrql を勉強している
- （手軽さとわかりやすさで言ったらDataDogのほうが楽だなぁ）

# nrql

- [NRQLを始めましょう：データの言語 | New Relic Documentation](https://docs.newrelic.com/jp/docs/nrql/get-started/introduction-nrql-new-relics-query-language/)
- ANSI SQL と同じような感じで使える
- 要は select 欲しいもの from どこから
- 書き順変えても動く（式的には FROM どこから WITH こうやって SELECT これ、みたいな感じ）

# メトリクス名（metric）をグループ化したらわかりやすいかなって

- [Metricデータタイプの問い合わせ | New Relic Documentation](https://docs.newrelic.com/jp/docs/data-apis/understand-data/metric-data/query-metric-data-type/#explore-metric-data)

```nrql
# アカウント内のすべてのメトリック名を一覧表示
FROM Metric SELECT uniques(metricName)
```

- データが使えるか、または使えないかを知るには、何があるのかを知るのが寛容
- ツールを勉強するにはドキュメントに書いてあることに独自に手を加えて工夫してみることが寛容（持論）
- ドキュメントにはユニークでメトリクス名取ってこれるぜって書いてあるわけだけど、大雑把に全体把握したい時に全部は見たくない
- ピリオドで区切られたネームスペースみたいになってるわけだし、末尾の個別メトリクス名削ったらグルーピングできるんじゃない？って思ったってワケ
- ChatGPT くんに聞いてみたらあんまり良い答えをくれなかった（オールドタイプ）

# できたもの

```nrql
# アカウント内のすべてのメトリック名を一覧表示（再掲）
FROM Metric SELECT uniques(metricName)

# 動いてるけど結果がおかしいもの（ChatGPTくんに応えてもらったやつベース）なぜか消えて欲しくないやつも消える
FROM Metric SELECT uniques(substring(metricName,0,indexOf(metricName,'.',-1))) AS group

# メトリクス名の末尾（countとかdurationとか）を削ったもの（これはうまく動いてる）
FROM Metric WITH substring(metricName,0,indexOf(metricName,'.',-1)) as group SELECT uniques(group)

# 最終的に雑にグループ化するなら3階層目くらいまであればいいんじゃね？ってしたもの（3階層ないやつは消えちゃうけど）
FROM Metric WITH substring(metricName,0,indexOf(metricName,'.',2)) as group SELECT uniques(group)

# おまけ New Relic の Query AI に聞いて出てきたもの（あーあ）
FROM Metric SELECT uniques(aparse(metricName, '*.*')) AS 'Metric Group'
```

# 学び的なもの

- AI はゼロからの一手には使えるかもしれないけど、ズレた期待にはまだ応えてくれない気がする
- nrql は叩いてみてなんぼ
- アカウントを切り替えるの忘れない（アカウント毎に積み上がってるデータが違うので）
- まだ読んでない公式ドキュメントを読むこと
- Query Builder の左側のところを開くと Data Explorer が開いて、条件を設定することで積まれているデータテーブルが表示できる
- アカウントの特定のサービスのメトリクスだけ探す、とかは Data Explorer が楽そう
- New Relic をちゃんと使えるようにしよう
