---
title: "GitHub Actions におけるスケジュール実行について考える"
emoji: "🗓"
type: "tech"  # tech or idea
topics: ["github actions","github","cron"]
published: true
---

# tl;dr

@[card](https://docs.github.com/ja/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows#schedule)

- crontab との違い
- AWS の [cron](https://docs.aws.amazon.com/ja_jp/eventbridge/latest/userguide/eb-scheduled-rule-pattern.html#eb-cron-expressions) との違い
- 違いがあるのは仕方ない
- 単純な定期実行では困らないが、多少工夫が必要なものはある

# スケジュール実行の前提

- 定刻どおりに実行されるスケジューラではない
- 権限やプラクティスについては別で
- サマータイムは別で

# よくある残念なケース

- 隔週実行で年をまたぐと年によって1週ずれる（2週連続で実行されないとかされるとか）

  - `date +%W / 2` は9割これ
  - `date +%U / 2` も今年やると大丈夫に見えてだいじょばない
  - カレンダーの方式について勉強するいい機会

- うるう年が視野に入っていない
- 空振り（スケジュールで実行するけどチェックで落とす）が多い
- schedule.cron は複数書ける（ことを知らない？）

# 特殊な定期実行のためのテンプレート

```yaml:.github/workflows/schedule.yml
name: テンプレート
on:
  schedule:
    - cron: "0 15 * * *"  # JST で 0:00 実行
  workflow_dispatch:

jobs:
  check:
    runs-on: ubuntu-latest
    timeout-minutes: 1
    outputs:
      is-run: ${{ steps.check.outputs.is-run }}
    steps:
      - name: 実行チェック（具体的な実行条件を記載するのがベスト）
        id: check
        env:
          TZ: 'Asia/Tokyo'
        shell: bash
        run: |
          # 条件に応じて振り分け
          today=$(date +%d)
          if [ $today -eq "" ]; then
            echo "is-run=true" >> $GITHUB_OUTPUT
          else
            echo "is-run=false" >> $GITHUB_OUTPUT
          fi

  do:
    runs-on: ubuntu-latest
    timeout-minutes: 1
    needs: check
    if: needs.check.outputs.is-run == 'true'
    steps:
      - name: 実行する処理
        run: echo "do this"
```

# 特殊な定期実行の例（やってみよう）

1. 日本時間で毎月1日の午前0時に実行する
2. 日本時間で毎月第1月曜日の午前0時に実行する
3. 日本時間で毎月最終金曜日（プレミアムフライデー）の午前0時に実行する（もう終わったよね）
4. 日本時間で明日が13日の金曜日なら実行する（12日の木曜日のどこかで実行する）
5. 隔週金曜日の夜に実行する
6. 他に

# 検討するべきところ

- タイムゾーン（JSTは+9）
- 境界値（うるう年とか）
- 実行回数（試行回数は少ないほうがよい）
- 特殊な条件での回避方法（コメントで対処可能ならそれでもいいはず）
- 別解の有無

# お気持ち

- 隔週実行を検討した際に見かけた記事が軒並み年またぎについて検討されていなかった
- （年末年始だしずれてもいいなら問題ないけれども）
- 条件について説明されているならいいけど、されてない記事はよくないなって思った
- ちなみに、`date +%W / 2` みたいなやつが年末年始にダメになる検算

|date|%W|%W/2|%U|%U/2|
|-|-|-|-|-|
| 2024-12-20 Fri | 51 | 1 | 50 | 0 |
| 2024-12-27 Fri | 52 | 0 | 51 | 1 |
| 2025-01-03 Fri | 00 | 0 ダメ| 00 | 0 |
| 2025-01-10 Fri | 01 | 1 | 01 | 1 |
| 2025-01-17 Fri | 02 | 0 | 02 | 0 |
| 2028-12-15 Fri | 50 | 0 | 50 | 0 |
| 2028-12-22 Fri | 51 | 1 | 51 | 1 |
| 2028-12-29 Fri | 52 | 0 | 52 | 0 |
| 2029-01-05 Fri | 01 | 1 | 00 | 0 ダメ|
| 2029-01-12 Fri | 02 | 0 | 01 | 1 |

- 隔週実行の別解ってゆうか、ちゃんとした記事見つけた
- [Bi-Weekly GitHub Actions. A GitHub Actions workflow can be… | by Tomáš Veselý | Medium](https://medium.com/@VeselyCodes/bi-weekly-github-actions-7bea6be7bd96)
- この方式ならたしかに年をまたいでも問題ない（ように見える）
