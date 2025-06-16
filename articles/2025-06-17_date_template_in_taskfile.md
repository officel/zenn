---
title: "date コマンドから脱却するテンプレート"
emoji: "📅"
type: "tech" # tech or idea
topics: ["taskfiledev", "taskfile", "gotask", "date", "sprig"]
published: true
---

# tl;dr

@[card](https://taskfile.dev/)

- [date コマンドの差異に気がついていなかった話（Taskfile）](https://zenn.dev/raki/articles/2025-06-14_date_command_in_taskfile) で date コマンドを使わないようにしようと考えた
- 今日日付は簡単だけど、個人的によく使う、前月、翌月の表現に悩んだ
- 日付確認用の taskfile を作ってチートシート化した
- 特定の日から前月、翌月を算出する方法の意見募集中

# 結果

@[card](https://github.com/officel/zenn/pull/257)

## 別ファイルのままでも呼べる

```bash
# alias t='task' してある
zenn $ t -t Taskfile.date.yml
task: Available tasks for this project:
* format-like-rfc:       date format like RFC      (aliases: rfc)
* format-sequence:       date format sample        (aliases: fs)
* samples:               date samples              (aliases: s)
```

## よく使う定型フォーマットは用意しておくと楽

```bash
zenn $ t -t Taskfile.date.yml rfc
2026-09-16 13:45:30
| Format Name           | Sprig                           | Result                          | Note |
|-----------------------|---------------------------------|---------------------------------|------|
| ISO 8601 like date -I | 2006-01-02                      | 2026-09-16                      |  |
| ISO 8601 w/z TZ       | 2006-01-02T15:04:05Z07:00       | 2026-09-16T13:45:30+09:00       |  |
| ISO 5322 a.k.a Email  | Mon, 02 Jan 2006 15:04:05 -0700 | Wed, 16 Sep 2026 13:45:30 +0900 |  |
| RFC 1123              | Mon, 02 Jan 2006 15:04:05 MST   | Wed, 16 Sep 2026 13:45:30 JST   |  |
| ISO 3339              | 2006-01-02T15:04:05Z07:00       | 2026-09-16T13:45:30+09:00       |  |
| YYYY-MM-DD HH:mm:ss   | 2006-01-02 03:04:05             | 2026-09-16 01:45:30             |  |
| YYYY-MM-DD hh:mm:ss   | 2006-01-02 15:04:05             | 2026-09-16 13:45:30             |  |
| YYYYMMDD              | 20060102                        | 20260916                        |  |
| ISO / YMD             | 2006-01-02                      | 2026-09-16                      |  |
| USA / MDY             | 01/02/2006                      | 09/16/2026                      |  |
| EUR / DMY             | 02/01/2006                      | 16/09/2026                      |  |
```

## Go の Sprig template は慣れ

```bash
zenn $ t -t Taskfile.date.yml fs
2026-09-16 13:45:30
| HCL   | Sprig     | Result     | Note               |
|-------|-----------|------------|--------------------|
| YYYY  | 2006      | 2026       | 年 4 桁 |
| YY    | 06        | 26         | 年 2 桁 |
| MMMM  | January   | September  | 月名（フル） |
| MMM   | Jan       | Sep        | 月名（短縮） |
| MM    | 01        | 09         | 月 2 桁 |
| M     | 1         | 9          | 月 1 桁 |
| DD    | 02        | 16         | 日 2 桁 |
| D     | 2         | 16         | 日 1 桁 |
| EEEE  | Monday    | Wednesday  | 曜日（フル） |
| EEE   | Mon       | Wed        | 曜日（短縮） |
| hh    | 15        | 13         | 時 24 時間表記 0 埋め |
| h     | 15        | 13         | X 存在しない |
| HH    | 03        | 01         | 時 12 時間表記 0 埋め |
| H     | 3         | 1          | 時 12 時間表記 0 埋めなし |
| AA    | PM        | PM         | AM / PM |
| aa    | pm        | pm         | am / pm |
| mm    | 04        | 45         | 分 2 桁 |
| m     | 4         | 45         | 分 1 桁 |
| ss    | 05        | 30         | 秒 2 桁 |
| s     | 5         | 30         | 秒 1 桁 |
| ZZZZZ | -07:00    | +09:00     | Timezone offset コロンあり |
| ZZZZ  | -0700     | +0900      | Timezone offset コロンなし |
| ZZZ   | MST       | JST        | like UTC (例: JST) |
```

- 学習曲線は確かに低いしゆるやかだけど正直嫌い
- テンプレートフォーマットはフォーマット文字列としての見た目を持っていて欲しい

## 日付計算

```bash
zenn $ t -t Taskfile.date.yml s
| Date                | Result |
| ---                 | --- |
| 2025-06-17 07:48:02 | now |
| 2026-09-16 13:45:30 | BASE_DATE |
| ---                 | --- |
| 2025                | Prev year  : YYYY |
| 2025-09-16          | Prev year  : YYYY-MM-DD |
| 2026-08             | Prev month : YYYY-MM |
| 2026-08-31          | Prev month : YYYY-MM-DD : Last day of last month |
| 2026-09-09          | Prev week  : 7 days ago |
| 2026-09-15          | Prev day   : Yesterday |
| 2026-09-16 12:45:30 | Prev hour  : 1 hour ago |
| 2026-09-16 13:45:30 | BASE_DATE  * |
| 2026-09-16 14:45:30 | Next hour  : 1 hour later |
| 2026-09-17          | Next day   : Tomorrow |
| 2026-09-23          | Next week  : 7 days later |
| 2026-10             | Next month : YYYY-MM |
| 2026-10-02          | Next month : YYYY-MM-DD : Last day of last month |
| 2027-09-16          | Next year  : YYYY-MM-DD |
| 2027                | Next year  : YYYY |
| ---                 | --- |
```

- テンプレートだけで割といろいろできる
- 年は加減算するだけでいいけど、月の移動は関数あったほうが楽
- 前月、翌月の生成に、他の手段あったら教えて欲しい

# まとめ

- date コマンドをやめるために 3 日も粘った
- 定期的な振り返り処理を別で書いていて、先月日付の取得は必須だったのでがんばった
- エポックタイムを計算した後、そこから time.time に戻すのができてない
- 前月、翌月の生成方法の別解大募集
- （おまけ）ChatGPT では正解にたどり着けなかった。AI で正解にたどり着くためのプロンプトも募集。。。
