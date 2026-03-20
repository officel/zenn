---
title: "GitHub Actions の cron にタイムゾーンが指定できるようになった、が。。。"
emoji: "🌐"
type: "tech" # tech or idea
topics: ["github", "githubactions", "cron", "timezone"]
published: true
---

# tl;dr

- [GitHub Actions: Late March 2026 updates - GitHub Changelog](https://github.blog/changelog/2026-03-19-github-actions-late-march-2026-updates/)
- GitHub Actions のスケジュールワークフローに、タイムゾーンが指定できるようになった
- 今のところそんなに必要でもないかなって

# スケジュールワークフロー

- GitHub Actions の `on.schedule` に cron 式を書くと定期実行ができる
- ずいぶん長いこと `UTC` 固定だった
- 日本の場合 `+9:00` なので、期待する日本時間の9時間前を書いておく必要があった

# これからはこう書ける

```yaml
on:
  schedule:
    - cron: "0 1 * * *" # UTC 1:00 → JST 10:00

    # ↑ を ↓ こう書いていい

    - cron: "0 10 * * *"
      timezone: "Asia/Tokyo"
```

# 言うほど便利か

- `timezone` が指定されていることで、コード的な可読性が上がっているのはわかる
- そもそも `UTC` 固定式ならそれはそれで前述のようにコメントを書いておくことでミスは減らせる
- 昨今は AI や IDE による補完でコメント部の修正はほぼ自動なのでは？
- `grep cron .github/workflows/*` みたいにした時、timezone の有無で期待が変わってしまうのではないか
- 全部書き直して統一するならいいけど、それはそれでだるくないだろうか
- それなら `UTC` 固定のままのほうが扱いやすいのではないか
- TimeZone が必要なのは、時間計算が苦手な人か、サマータイム等の調整時間がある場所に関連する人なのでは？
- と思ったので記事に残してみようかと思ったってワケ

# cron メモ

- [cron - Wikipedia](https://ja.wikipedia.org/wiki/Cron)
- [Crontab.guru - The cron schedule expression generator](https://crontab.guru/)
- [List of tz database time zones - Wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) タイムゾーンに指定するゾーン名のリスト
- [AWS Lambda](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/with-eventbridge-scheduler.html) （EventBridge スケジューラー）ではタイムゾーンが指定できる（[ECS タスク](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/tasks-scheduled-eventbridge-scheduler.html)も同じ）
- [Azure Logic Apps](https://learn.microsoft.com/ja-jp/azure/logic-apps/concepts-schedule-automated-recurring-tasks-workflows)もタイムゾーンの指定ができる

# 雑感

- `timezone` を指定できるようになったことで恩恵を受けるユーザーがいるのは認める
- 無理に修正する必要は今のところないはず
- 可読性の面で、既存のユーザーには大した違いはないはず
- 初心者にはゾーンが明記されていたほうがわかりやすい、のか？
- AI には（スキーマを理解させれば）どっちでもいいはず
- できればずっと修正（対応）しないままにしておきたいが、いくつかの懸念がある

  - 本当の内部的な構造はわからないけど、linux システム的にはシステムのタイムゾーン設定か、`CRON_TZ` などの環境変数で設定されたゾーンで動作するはず
  - 全機UTC固定で設定されているなら（既存のとおりに）UTCとして扱えばいいはず
  - 将来的に設定の異なるインスタンス上で起動された時、バグったりしないか
  - セルフホステッドランナーで時間比較がバグらないか（JST指定でPSTインスタンスで起動されるとか）
  - 文字列で起動時間渡ししてたり、実行時刻とシステム時刻を見てたりするとちょっと怖い

- 当面は対応せず `UTC` のままにしておき、どうしても `JST(Asia/Tokyo)` で指定したいってなったら自己責任でやってもらうのが良さそうな気がしている
- json-schema.org の `github-workflow.json` はまだ更新されていなくて、`timezone` を入れると赤波下線（エラー）になっちゃうので、まだそんなに心配はしていないけれども（すぐだろそんなの。。。）
