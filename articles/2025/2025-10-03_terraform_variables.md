---
title: "terraform アンチパターン variable"
emoji: "🙅"
type: "tech"
topics: ["terraform"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- Terraform における variable の「正しい使い方」と「やってはいけない使い方」を整理
- ラノベ調に言うとこんな感じ

  - 「やはりお前らの variable の使い方は間違っている」
  - 「ルートモジュールで variable を使うのは是か非か」
  - 「variable のつらいアンチパターン」

# variable block

- [variable block reference](https://developer.hashicorp.com/terraform/language/block/variable)
- Terraform を少し触れば必ず出てくる要素であり、公式サンプルでも多用されている
- その結果「とりあえず使う」ことが当たり前になり、正しい設計意識が弱いケースが目立つ

# アンチパターン

## すべて variable にしてしまう

- 実行時に変更してほしくない値まで variable にする
- ルートモジュールで variable を定義するということは、-var や tfvars で実行時に上書き可能にするということ
- インスタンスタイプや台数の調整は「実行時に変更してもよい変数」として理に適う（ことがある）
- 逆にリソース名やセキュリティ系設定を variable 化すると、意図せぬ事故や悪意ある変更の危険がある
- IaC の基本は「コードとしての変更履歴を残すこと」なので、実行時に上書き可能な状態は望ましい状態ではないはず

:::message alert
実行時に変更してほしい対象だけ variable にする。それ以外は locals で表現する。
:::

## ひとつの variable にリソースのプロパティをまとめて渡す

- object 型や map 型でリソースの全プロパティを一括管理する設計は整理されているように見える（ことがある）
- しかし以下の問題がある

  - validation を細かく設定しにくい
  - リソースの仕様変更（プロパティのリネームや分割）に弱い
  - ネストや複数リソース定義が入り込み可読性が落ちる

:::message alert
設定値はなるべく「個別の variable」として渡す。渡しにくさを感じる場合、まず設計を疑うこと。
:::

## 複合型を説明代わりに使う

- 複合型をそのまま設計書代わりにしてしまうケースはありがち
- 説明も validate もおろそかになり、結果的に「読みにくく脆い設計」になる
- 本来の役割は「使う人に正しい入力の形を示す」こと

:::message alert
variable には適切な命名・説明・validate を用意すること。
locals で代替できるなら複合型 variable にしない。
:::

## variable 名と同じ内容の description

- よくある「user_id: description = 'user_id'」のような自己言及説明
- description を必須にしたポリシーの回避のためだけに適当に書いてしまう
- やむを得ない場合はあるが、できるだけ意義のある説明を書きたい
- 「description は英語、コメントは日本語」などルールを決めておくと良い

:::message alert
最初から description を丁寧に書く習慣をつけよう。後から直すのは辛い。
:::

## default にネストした複合型を置く

- 複雑な object や list を default に書き込むと一見便利だが、弊害が多い

  - 個別の description が書けない
  - 個別の validate を書きにくい
  - 実行時上書きで破壊されやすい（例: -var xxx=[]）
  - 可読性が低い

:::message alert
複合型 variable はその構造に詳しい人だけが見やすいのであって、後から見直した時に見やすいとは限らない
:::

# variable を使わずに済むようにするための理由づけ

- 不要な variable をルートモジュールから削ることで

  - 実行時の危険な変更を防ぐ（セキュリティ・事故対策）
  - コード変更としての IaC 本来の運用スタイルに従える
  - validate や説明が欠けた状態を避けられる

- locals なら他の値を参照可能、可読性も整理しやすい

# まとめ

- ルートモジュールでは外部からの変更が必要なものだけを variable にする
- ルートモジュールに variable は 9 割不要、locals で十分（極論）
- 呼び出されるモジュールでは variable を丁寧に設計する
- variable は一つに一つの情報だけを持たせ、複雑さを詰めこまない
- description と validate を必ず設定する

# 編集後記

- 「とりあえず書いた」ではなく「残しやすいコード」に向けて整理してみた
- 過去コードを見返すと variable 設計の乱雑さが一番つらいと改めて痛感
- 改修したい気持ちはあるが、まずはこういう整理観点を共有するのが大切かなと思ったので書いた
