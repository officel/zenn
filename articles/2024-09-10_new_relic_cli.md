---
title: "今更ながら New Relic に入門しまして"
emoji: "🔀"
type: "tech"  # tech or idea
topics: ["newrelic"]
published: true
---

# tl;dr

- DataDog 育ちなんだけど New Relic を使うことになった
- とりあえず new relic cli を使い始めた
- アカウントのリストを作る、が cli でできないみたいだったんだけどできた（からメモ）
- `newrelic nerdgraph query '{actor{accounts{id name}}}' | jq -cr ".actor.accounts[]"`

# インストール

- [Get started with the New Relic CLI | New Relic Documentation](https://docs.newrelic.com/docs/new-relic-solutions/tutorials/new-relic-cli/)
- brew でもいいんだけど [aqua で管理](https://github.com/officel/config_aqua/pull/37/files) することにした
- API Key ベタ打ちでローカルプロファイルが作成されちゃうのどうなの？
- [New Relic API キー | New Relic Documentation](https://docs.newrelic.com/jp/docs/apis/intro-apis/new-relic-api-keys/#user-api-key)
- [newrelic-cli/docs/cli/newrelic_completion.md at main · newrelic/newrelic-cli](https://github.com/newrelic/newrelic-cli/blob/main/docs/cli/newrelic_completion.md)
- completion コマンドそのまま叩いてもエラーになるってゆうか、`--shell` オプション要るのでは。。。
- new relic cli と nr1 の違いってなんなの？
- profile を使わずに環境変数で処理する方法はないのかしら？（ドキュメントに見当たらない？）

# cli でできないシリーズ

- もしかしたらできないことのほうが多いのかも？
- 正確にはサブコマンドが用意されていなくて nerdgraph 等の API 呼び出しでどうにかしないといけない？
- スクラップとかでまとめるといいのかもしれない → 作った [New Relic CLI のメモ](https://zenn.dev/raki/scraps/206cde95f9b8cb)
- 最初にやりたかったのは、account のリストを作る、だったんだけど、cli のコマンドにはなかった

# Account の list

- organization にぶら下がるアカウントの一覧を作りたい
- cli では作れないと AI が言う

![AI](/images/2024-09-10-001.jpg)

- [NerdGraph API explorer](https://docs.newrelic.com/docs/apis/nerdgraph/get-started/nerdgraph-explorer/) を使うとできた
- それを cli 渡しにすればできた（今日のポイントはこれ）
- `newrelic nerdgraph query '{actor{accounts{id name}}}' | jq -cr ".actor.accounts[]"`
- `newrelic account list` でええやろ。。。

# まだできていないシリーズ

- profile なしで dotenv 等を使った環境変数渡しでディレクトリ毎設定変更
- terraform の新規準備（既存は動いている）
- エンティティ等のリスト（こっから本番）
- terraform で未管理の部分を cli から import させる（terraformerがもうちょっと頑張ってくれれば）
- [terraformer/docs/relic.md at master · GoogleCloudPlatform/terraformer](https://github.com/GoogleCloudPlatform/terraformer/blob/master/docs/relic.md)

# まとめ

- New Relic CLI のインストールは aqua で簡単
- 古い情報との混在が不便
- ドキュメントがわかりにくい。。。
- 後発組なのでとりあえずコマンド叩いて覚えるしか
- terraform と同時進行でがんばる
