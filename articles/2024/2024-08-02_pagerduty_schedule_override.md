---
title: "PagerDuty でスケジュールをオーバーライドする"
emoji: "📟"
type: "tech"  # tech or idea
topics: ["PagerDuty","api","On Call"]
published: true
---

# tl;dr

- PagerDuty のスケジュールを上書きしたい
- 以前書いたやつを流用
- ブログネタを整理する時間が取れないので簡単なやつでお茶を濁す

# PagerDuty

@[card](https://www.pagerduty.co.jp/)

インシデント管理プラットフォームとして有名ですね。

@[card](https://www.pagerduty.co.jp/pagerdutyontourtokyo/)

イベントは来週です。同僚氏が登壇する予定なのですが、人混みは苦手なので離れたところで応援するだけにしていますｗ

# エスカレーションポリシーとオンコールスケジュール

- 正直組み立てには慣れがいる
- 1つの service（イベントソースの都合で分解したくない）
- 日中は外部運用担当と予備に内部運用担当が数人ずつ、**内部担当は当番制でスケジュールが不定**
- 夜間は内部運用担当数人で週交代
- エスカレーションポリシーをちゃちゃっと組んだ後、当番制スケジュールをどう埋めるか
- ちょっとしたパズルみたい
- （まだ担当のネゴ取れていないので非公開）

# API でスケジュールオーバーライド

@[card](https://developer.pagerduty.com/api-reference/41d0a7c3c3a01-create-one-or-more-overrides)

- 日中の内部運用担当は日毎に担当変更（不定）
- 不定のオンコールスケジュールは書けない（はず）
- 担当者全員をリストして、日毎ローテーションするスケジュールをフェールセーフとして設定（オーバーライド用のID取得用）
- このスケジュールに不定の担当者をオーバーライドで登録すれば運用が楽になるかなって
- もちろん手作業厳禁
- IaC（terraform）で毎日管理するのめんどくさい
- よろしい。ならばAPIだ

# というわけでコード

- 以前 PagerDuty の本に寄稿した時はメンテナンスウィンドウを設定した

@[card](https://github.com/officel/pagerduty-terraform-examples/blob/main/bin/pd_maintenance.sh)

- ぶっちゃけ焼き直し

```bash
#! /usr/bin/env bash

# My Profiles の User Settings からトークン（必須）
export PD_TOKEN=""

# 自分のメールアドレス（必須）
export PD_MAIL=""

# スケジュールID
export PD_SCHEDULE_ID=""

# 担当ユーザ（）
PD_USER_ID="A"
# PD_USER_ID="B"
# PD_USER_ID="C"

export PD_START_TIME='2024-08-01T09:00:00+09:00'
export PD_END_TIME='2024-08-01T18:00:00+09:00'

curl -s \
    --request POST \
    --url    https://api.pagerduty.com/schedules/${PD_SCHEDULE_ID}/overrides \
    --header 'Accept: application/json' \
    --header "Authorization: Token token=${PD_TOKEN}" \
    --header 'Content-Type: application/json' \
    --header "From: ${PD_MAIL}" \
    --data '{
      "overrides": [
        {
            "start":  "'"${PD_START_TIME}"'",
            "end":    "'"${PD_END_TIME}"'",
            "user": {
            "id": "'"${PD_USER_ID}"'",
            "type": "user_reference"
            },
            "time_zone": "UTC"
        }
      ]
    }'
```

- 時間は決め打ちなので日付だけもうちょい工夫してもいいかも
- 人もIDが揃ったら引数で切り替えとか直接渡すとかしてもいい
- 一応API的には複数追加できるので、 `overrides` の中のオブジェクトを複数書ける
- 1週間分まとめて登録、とかならそれなりに書き直しもできるはず

# 最後に

- シェルスクリプトが一番楽なのは仕様
- GitHub 使ってたら Actions にして実行環境を選ばないようにするのが楽なんだけど Azure DevOps なもんで
- PagerDuty 便利だし設定するのは楽しいんだけど、鳴らないにこしたことはないのよね
- 運用お疲れ様ですｗ
