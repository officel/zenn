---
title: "Argo CD を kind にインストールして ingress-nginx でアクセスできるようにしてみた"
emoji: "🐙"
type: "tech"
topics: ["terraform", "kubernetes", "kind", "ingress-nginx", "argocd"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- [terraform で kind cluster を管理](https://zenn.dev/terraform_jp/articles/2024-05-20_terraform_kind) するようにした
- [ingress-nginx を追加](https://zenn.dev/terraform_jp/articles/2024-06-07_terraform_kind_ingress_nginx) してみた
- 今回は [Argo CD](https://argo-cd.readthedocs.io/) を動かしてアプリケーションを動かすことにした
- Argo CD CLI は別途インストールする（[aqua で楽できる](https://zenn.dev/raki/articles/2024-05-16_aqua)）
- 実行可能な[コードはこちら](https://github.com/officel/zenn/tree/main/terraform/2024-06_kind_argocd)

# 経緯

- 業務で Argo CD を使うことになった（github actions や他のCI/CDツールとの比較？）
- 業務用のクラスタであれこれすると周りにも迷惑をかけるかもしれないのでローカルで十分に遊ぶつもり
- port-forward を毎回手打ちするの面倒なので、フルオートで ingress 経由（業務用クラスタではLB、ローカル kind では NodePort）でアクセスさせたい

# 改善、その他

- terraform を使ってるので terraform 以外のコマンドをできるだけ叩きたくない
- Argo CD のようなツールは常に稼働していてなんぼのはず
- 思い立った時に `terraform apply -auto-approve` するだけで使えるようにした
- なので、リポジトリをクローンするかコピペして、ぜひそのまま試して欲しい
- 動作しない、コードが間違っている、改善提案がある等、ぜひアクションして欲しい

# コマンド確認

- [README](https://github.com/officel/zenn/tree/main/terraform/2024-06_kind_argocd) を見て欲しい
- port-forward を試した後、コードを修正せずに設定だけで ingress-nginx を処理できるようにしてあるので試して欲しい

# このあとは

- Argo CD を使いこなす練習をする。要は運用演習
- Istio を使う別のクラスタもあるので、Istio の使い方を学ぶ
- Istio の後ろに Argo CD をおける（ingress-nginxを代替する）のでそれも試したい
- 当然のように Kiali も付いてくるのでその辺も
