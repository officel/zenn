---
title: "Task(taskfile.dev) で zenn の記事執筆の前後を楽にする"
emoji: "✍"
type: "tech"
topics: ["task", "taskfile", "taskfiledev", "git","github"]
published: true
---

# tl;dr

- [Task](https://taskfile.dev/) で記事を書く前後の処理を自動化
- Task 自体の使い方の練習を兼ねている
- [現在の Taskfile.yml](https://github.com/officel/zenn/blob/main/Taskfile.yml)
- Windows 11 + VS Code + WSL2 + Ubuntu 24.04 で VS Code のターミナルとエディターで処理

# task(taskfile.dev)

- alternative GNU Make
- ググラビリティの悪い名前なので検索がツラい（zenn でもトピックが割れるので全部つけている）
- [モダンなタスクランナーを求めて task (taskfile.dev) を使うまでの軌跡](https://zenn.dev/raki/articles/2024-05-30_task_runner)
- まだ記事にしてないやつは [taskfile.dev のメモ](https://zenn.dev/raki/scraps/b076f624777be2) に書いている

## 事前タスク

- zenn cli は使用していない
- テンプレートをコピーして当日日付のファイルを生成
- VS Code で開く
- 注意点というか、執筆前のチェックリストをターミナルに表示

## 記事を書く

- Taskfile は記事を書くのには使ってない
- というか今のところ記事のネタ
- ファイル名が slug になるので手で変更している

## git タスク

- コードを見るのが早い
- git fetch, checkout, add, commit, push を自動
- （GitHub cliで）gh pr create, gh pr merge を自動
- テスト中はよくこけるし、やり直すの面倒なので、エラーが発生したら git reset
- エラー処理の[マージ待ち](https://github.com/go-task/task/issues/1484)

## パブリケーション

- [terraform-jp | Zenn](https://zenn.dev/p/terraform_jp)（メンバー募集中です）
- 同じリポジトリで書いているので、コミットタイトルでスコープを別にする形にしている
- 詳しくはリポジトリのログを参照

## 工夫しているところ

- デフォルトタスクを list に割り当てているので何も考えずに `task` を叩いて大丈夫
- 叩くタスクには aliases を指定してしゅっと叩けるようにしている

```bash
zenn $ task
task: Available tasks for this project:
* raki:                generate articles                  (aliases: r)
* raki:git:            auto git, use -- COMMIT TITLE      (aliases: rg)
* terraform:           generate articles                  (aliases: t)
* terraform:git:       auto git, use -- COMMIT TITLE      (aliases: tg)
```

- プライベートタスクは見せてないだけ

```bash
zenn $ task ul
task: Available tasks for this project:
* _git:
* _git:auto:
* _git:gh:
* default:
* raki:                generate articles                  (aliases: r)
* raki:git:            auto git, use -- COMMIT TITLE      (aliases: rg)
* terraform:           generate articles                  (aliases: t)
* terraform:git:       auto git, use -- COMMIT TITLE      (aliases: tg)
* util:list:                                              (aliases: ul)
* util:summary:                                           (aliases: us)
```

- タスクのグルーピングに名前空間を使って同じようなタスクは同じように見える（ようにしている）
- `_git` は自分の他のリポジトリでも再利用できそうなので別ファイル化を検討中
- 前述のとおり、エラー処理には自分でも不満があって（シェルで分岐はもってのほか）改善の余地があると思っている
- util:summary で登録されているタスクを全部抽出してそれぞれ --summary を出力できるようにした

```bash
tasks:
  util:summary:
    # desc: view summary of all tasks
    summary: |
      全タスクのサマリー出力
    aliases:
      - us
    cmd: task --list-all --sort alphanumeric -j | jq -cr ".tasks[].name" | xargs -i sh -c 'task --summary {}; echo "\n---\n"'
    silent: true
```

## 気づき

- 表示するタスクと非表示にするタスクの区別をつける
- 名前空間を利用してタスクをグルーピングする
- エラー処理まわりが書きにくいので更新をチェック
- -n（--dry）でテスト大事
- -v（--verbose）でタスクの流れを確認すると理解が深まる

# おわりに

- [config_aqua](https://github.com/officel/config_aqua/blob/main/Taskfile.yml) 等で実装したものを改善している
- モダンとはを常に考えている
