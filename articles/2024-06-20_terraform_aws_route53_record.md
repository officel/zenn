---
title: "terraform で細かすぎて伝わらない小ネタ allow_overwrite in aws_route53_record"
emoji: "🤏"
type: "tech"
topics: ["terraform", "aws", "route53"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- 細かすぎて伝わらない小ネタシリーズ
- [aws_route53_record.allow_overwrite](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record#allow_overwrite)
- 付けないと既にレコードがある場合にエラーになってしまう
- IaC としてコードが常に正でいいなら付けておくとよい

# aws_route53_record resource

- Amazon Route 53 のレコードを管理するリソース
- 普通に使っている分には特に問題ないはず
- 既に存在しているレコードを上書きしようとするとエラーになる

```bash
Error: creating Route53 Record: operation error Route 53: ChangeResourceRecordSets, https response error StatusCode: 400, RequestID: XXXXXX, InvalidChangeBatch: [Tried to create resource record set [name='XXXXXXX.', type='CNAME'] but it already exists]
```

- destroy に失敗してたり、レコード名を手動で変更していたりしてひっかかる
- `allow_overwrite = "true"` を設定しておくと上書きしてくれるので、常にコードが正にできる

# AWS では他にないっぽい

- [Code search results](https://github.com/search?q=repo%3Ahashicorp%2Fterraform-provider-aws+allow_overwrite+path%3Awebsite%2Fdocs%2Fr%2F&type=code)
- 他の AWS リソースにはないオプションみたい
- ACM 周りはよく見ると aws_route53_record のサンプルが書いてあるだけなのがわかる
- Issue もそこそこあるけど主に ACM 関係

# 小ネタ？

- たまたまさっき引っ掛けたのでネタとして書いた
- terraform-jp の rss channel に zenn のトピックを追加してなかったのでついでにテスト
