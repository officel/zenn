---
title: "ingress-nginx を kind にインストールしてみた"
emoji: "🐋"
type: "tech"
topics: ["terraform", "kubernetes", "kind", "ingress-nginx"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- 前回 [kind を terraform で管理](https://zenn.dev/terraform_jp/articles/2024-05-20_terraform_kind) するようにした
- もうちょっとあれこれしたいと思い、うまいやり方を模索中
- 今回は ingress-nginx を使えるようにして、ホストOSからもブラウザで参照できるようにした
- 実行可能な[コードはこちら](https://github.com/officel/zenn/tree/main/terraform/2024-06_kind_ingress_nginx)

# 経緯

- k8s で各種ツールを使うにあたって、ローカルである程度完結できるようにしたかった
- k8s 周りのことが記憶の彼方に飛んでるので思い出しつつ改善活動
- ツールやアプリケーションに port-forward でアクセスするのは手抜きっぽくて嫌だ
- サンプルもあるし terraform で管理するところとしないところの線引きも兼ねて ingress-nginx を導入しよう

# 改善、その他

- terraform なので使い終わったら destroy （前回分も捨てる）
- direnv で対象ディレクトリにいる時だけ kubeconfig を設定する（~/.kube/config を汚さない）
- コードを少し読みやすく
- helm 管理
- サンプルのとおり、アプリケーションは apply で処理（terraformで管理しない）

# コマンド確認

- [README](https://github.com/officel/zenn/tree/main/terraform/2024-06_kind_ingress_nginx) を見るのが早い

# このあとは

- ArgoCD を入れて、helm_release をそっちに任せるようにしたい
- Istio やその他のツールも入れて遊ぶ
- terraform とは別だけど k8s のあれこれを勉強しなおす（CKAD取得済とは思えない忘れっぷり）
