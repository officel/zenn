---
title: "terraform のディレクトリ構造のプラクティス"
emoji: "📁"
type: "tech"
topics: ["terraform"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- terraform を使うリポジトリのディレクトリ構造のプラクティス（ベストプラクティスとは言ってない）
- パターンの中から使いやすいものを選択すればいいだけ
- ~~ストライク~~で消してるところは冗談なので受け流して欲しい

# 万人受けしやすい構造やルールについて

## 管理しやすい最大公約数的なリポジトリにする

- AWS ならアカウント毎（同一アカウントのすべてのリソースを1つのリポジトリで管理する）
- Azure ならサブスクリプション毎など（要は課金体で分ける）
- 広範囲に共通なリソースは分離してもよい（複数の部署で同一のDNSゾーンを共有しているなど）
- 小さいリポジトリをたくさん作るよりは大きいリポジトリに集約されているほうが混乱が少ない（~~そこになければないですね~~）
- 後で集約するより分割するほうが楽だということ

## リポジトリルートに `terraform` ディレクトリを作る

- terraform しか管理しないリポジトリであっても作る
- その下に terraform のコードがあることが誰にでも一目でわかる（超重要）
- インフラ管理によく使われる他のツール（ansibleなど）と同居しやすい
- docs など、他のディレクトリを後から追加しやすい
- 後で他のリポジトリと合流するなどしても問題が起きにくい
- などの理由で、`tf` ディレクトリなどにせず、`terraform` ディレクトリを作ることを推奨する（書き忘れていたけどOpenTofuのことは考えていません）
- ~~たかが一ディレクトリ増えるのを嫌がる面倒くさいタイプの人とは距離をおいたほうがいい~~
- ~~リポジトリルートが汚くても平気な人ってデスクトップも汚そう~~

## ディレクトリ内のファイルやディレクトリの数が50以下になるように分割する

- 昔のターミナルが 80 文字 24 行だった名残（~~IT老人会~~）
- 単純に `ls -l` してスクロールが面倒でない量
- 初期設計でいけると思っていても、経年でディレクトリは増えると心得る
- 1つのディレクトリ直下のディレクトリ数は、最大10以下に抑えると心得る
- 基本的には `docs/yyyy/mm/` なのだと思っておくと楽。`dd` 相当部分は許容してもしなくてもよい（末端ディレクトリ部分をどこまで分割するかは別の話ということ）
- ディレクトリやファイルは、増えることはあっても減ることはないと心得る

# terraform ディレクトリ直下（トップレベルディレクトリ）の分割について

- ~~どうしても terraform ディレクトリを作りたくないって頑固者はリポジトリルートだと思っていいよ~~
- terraform を管理するディレクトリは時間経過で間違いなく肥大化するので、トップレベルのディレクトリ分割には最初から細心の注意を払う

## modules ディレクトリ

- 社内等でのサービス提供（昨今のSREチームでよくあるやつ）以外では自作モジュールは避けるのを勧める
- 公式モジュールだけを使うなら必要ない
- 自作モジュールのメンテナンスは時間経過と共に負荷があがる
- 必要なコードをディレクトリやファイル単位でコピーして再利用するほうが中長期的に見て運用が楽
- ~~自作モジュールをがちがちに書いて楽しいのは最初だけ~~
- ~~何もしてないのに差分が出た、に遭遇したことがない者は幸いである~~
- ~~バージョンアップ対応したことがない者も幸いである~~
- ~~サービス終了まで自作モジュールをメンテナンスし続けたことがある者だけが modules ディレクトリを作りなさい~~

## プロバイダーディレクトリ

- aws, google, azure 等のクラウドプロバイダーディレクトリを作っておくと、ディレクトリ管理が容易になる
- DataDog, PagerDuty, Akamai 等の SaaS サービスプロバイダーディレクトリを作っておいてもわかりやすい
- おわかりかと思うが、ここで言うプロバイダーディレクトリとは、terraform provider とほぼ同義

## サービスディレクトリ

- `aws_s3` や `aws_ec2` のようにしておくと、使用サービスから目的のディレクトリを探しやすい

  - （個人的に）すでに一度失敗しているのであまり勧めない
  - プロバイダーサービスは大人しくプロバイダーディレクトリの下に配置したほうがよい
  - ほぼそれだけの管理で終わる `Amazon` 系サービスでとくに有効（そう S3 などだ）
  - 社内向けサービスや、IAM 等の比較的更新頻度が高くなりがちなディレクトリは見える位置にあるとわかりやすい（こともある）
  - terraform provider の resource name に合わせた命名にしておく（`amazon_s3`ディレクトリにしない。そう terraform ディレクトリの下なのだ）
  - リソース名揃えにしておくと、他のディレクトリの混在時もまとまって見やすい（`aws_xxx` のようになるので揃う）

- 管理しやすいのであれば、自社サービス、システム等のディレクトリをここで分けてもよい

  - to C 向けサービス（example.comなど）
  - to B 向けサービス（business.example.comなど）
  - 社内システム（HRやNWなど）
  - など、組織によってわかりやすい分類があり、管理する数が少ないのであれば有効かもしれない

## 環境別ディレクトリ

- 本番環境やその他の開発用環境
- （個人的にはトップレベルで環境を分けるのは環境の有無の差がわかりにくくなるので好ましくないと思っている）
- （~~`env/prod/`や`env/dev/`とかなってたらやり直しを要求したくなる~~）
- （あとmoduleで環境差を吸収するのは中長期的に困難なのでやめるべきだと思っている）
- そもそも課金体で分離していれば環境別ディレクトリは必要ないはず（課金体の段階で環境は分離してあるでしょう？）

# 末端ディレクトリについて

セカンドレベルのディレクトリの前に、末端ディレクトリつまり terraform の実行ディレクトリ（working directory）について。

## 実行ディレクトリ内のリソース数

- 最大で100と心得えておく（気がつくと増えていて数百になることもザラにある）
- リソース数が多いとAPIコール数と時間とコストがかかる
- なんでもかんでも同じディレクトリに入れておくと、管理は楽に見えるかもしれない
- 対価としてリソース数に応じてAPIコール数、処理時間、コストが増える。ほんの少しの修正でも毎回支払うことになる
- たとえば Amazon S3 Bucket を管理しようと思った時のリソースは bucket 1つではない
- （[aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/5.62.0/docs/resources/s3_bucket) で Deprecated になっているものは概ね別リソース扱いなので、それぞれリソースが必要でAPIが呼び出される）
- IAM 等の比較的変更（ユーザ追加とか）が多いケースではもっと顕著になる

## 極論として実行ディレクトリ＝対象のリソース1セットにする

- セットをどのような規模として捉えるかは組織や管理体に依存する
- data source を使ってうまく別ディレクトリに切り出せるようにする
- 必然的に含まれるリソースが少なくなるのでドリフト検知を自動化してあれば運用はとても楽

### 環境差をここで分離するとわかりやすい

- xxx-service-dev, xxx-service-stg, xxx-service-prod がディレクトリとして分離してあり、並んでいれば `diff -r` で差分を見やすい
- `xxx-service/dev/`, `xxx-service/stg/` のようにするのとどちらがいいかは好みかもしれない
- 個人的にはリソースにつける name と同等のディレクトリであるほうが検索性が高いので好み（`xxx-service-prod/`のほうが検索しやすいし、`pwd`した時もわかりやすい。`xxx-service/xxx-service-prod/` とするかは悩ましいところ）

### s3 なら 1 bucket 1 ディレクトリでもよい

- どうせ自動化してドリフトは検知する
- バケットを増やす時にディレクトリ丸コピーで横展開しやすい
- `aws_s3/` 下は、マネージドコンソールの bucket 一覧と同等になるイメージ

### IAM は将来を見越して分割しておく

- 最初は数人分の IAM User だったものがあっとゆうまに増える
- グループが（権限に応じて）増える
- もちろんポリシーは言うまでもない
- たいていの組織において、組織体の管理グループ（ADなど）毎に分離しておくとよい
- `aws_iam/user/チーム` や `aws_iam/group/チーム` のようになる

# セカンドレベル以下のディレクトリ分割について

## 深すぎても浅すぎてもつらい

- ディレクトリの数をできるだけ均等にわけようとしても難しい
- 何段と決めてかかるのは悪手になるので避けるほうがいい（そのうち限界がきてしまう）
- 想定する期間での最大の拡充を見越して決める（最初は1つのディレクトリに10個入りそうなら分けることを検討する＝深くする）

## 後からきた人が見ただけで掘り進めやすいようにする

- ディレクトリを分割設計するのは、プログラミングでいう名前空間や変数名を設計するのと同じ
- 見ただけでわかりやすく、その下に何があるかを推測しやすくする
- 本番環境か開発環境か、は大した問題ではない（上位のディレクトリで分割するのは望ましくない）
- ~~git ops であればマージされたPRが処理されるのだから、ディレクトリ間違いなど発生することを想定するほうがどうかしている~~
- ~~そもそもディレクトリレベルで環境間違いを起こす人選もどうなの？~~
- ~~そもそも権限をちゃんとするかリポジトリを分けるかして本番環境での実行抑制ができていればコードのディレクトリで環境差に注目する必要はほとんどない~~

## 理想的には

- たとえば特定のリソースの修正依頼があった時、すぐ対象のディレクトリにたどり着けるか
- 新規加入したメンバーでも迷いなくたどり着けるか
- plan の実行時間が許容範囲まで分解されているか（個人的には5分かかるようなディレクトリは管理したくない。人によっては10分を許容するかもしれない）
- `git grep` またはブラウザからの検索等で対象リソースを探せるか（直撃でなくてもよい）

# 書かなかったこと

- ファイルの分割は [Standard Module Structure | Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/language/modules/develop/structure) なので書いてない
- 何を誰がどう管理するかによるので、公式にはディレクトリ管理は言及されていない（はず）[Plugin Development - Best Practices | Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/plugin/best-practices)
- 半公式？ｗ [Terraform Best Practices](https://www.terraform-best-practices.com/) でもディレクトリ構造については言及してない（はず）
- 同じものをたくさん作る組織については別でどうぞ
- ケイパビリティが低いうちにモジュール書くと死ぬぞ
- state ファイルについて
- HCP Terraform について
- そのうちちょっと書きたい

# 最後に

- ~~まるでコピペみたいなディレクトリ構造例の記事がたくさん出回っていて、イラッとしたので書いた。反省はしてない~~
- 組織やその規模によって必要な構造は違って当然
- ベストではないかもしれないが、実務に基づいたプラクティスということでひとつ