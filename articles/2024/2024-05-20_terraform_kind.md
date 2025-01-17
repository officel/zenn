---
title: "terraform で kind を設定してみた"
emoji: "🐋"
type: "tech"
topics: ["terraform", "kubernetes", "kind"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- kind(Kubernetes IN Docker) を使う
- コマンドを叩くのが面倒なので terraform で管理したい
- Provider に迷ったけどとくに問題なかった
- 実行可能な[コードはこちら](https://github.com/officel/zenn/tree/main/terraform/2024-05_kind)

# 経緯

CKAD を取得してから5年以上が過ぎました（更新してません）。
仕事では職場の同僚氏たちに k8s を触る機会を譲っていたのですっかり忘れてしまいました。
k8s は主戦場にしなくても食べてはいけるしなって気にしてなかったんだけど、ちょっと必要になりそうな雰囲気になってきたので再入門することにしました。
インフラ業が長いし、どちらかといえばマルチノードで必要な作業を行うことが多くなると思うので、kind を使ってローカル環境を構築することにしました。

# 普通に作ってみた

qiita にも zenn にも kind に関する多数の記事があって、検索上位にあがってくるような記事を見ればコマンドによる構築は普通に動きました。
ツール類が古いままだったので、ほとんど全部 [aqua](https://zenn.dev/raki/articles/2024-05-16_aqua) で管理するようにしました。
この辺りは省略にします。

# terraform kind provider

[Terraform Registry](https://registry.terraform.io/search/providers?q=kind) で `kind` を検索してみると、検索結果の精度が酷い。
ハズレをぶん投げて見つけたのが [tehcyx/kind](https://registry.terraform.io/providers/tehcyx/kind/latest/docs) です。
GitHub を見に行くと fork なのがわかるけど、fork 元はすでにアーカイブなので、今後はこれで問題ないのかなと。
野良 provider しかないのは仕方ないというか、provider を自作するほどの時間もスキルもないのでよしとします。

# terraform で動かしてみる

example に書いてないので忘れがちだけど required_providers を書かないとどこから持ってきていいのかわからないためエラーになります。

```hcl
# kind_provider.tf
terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.4.0"
    }
  }
}

provider "kind" {}
```

クラスターの設定を hcl でリソースとして表現します。

```hcl
# kind_cluster.tf
resource "kind_cluster" "this" {
  name           = local.name
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      kubeadm_config_patches = [
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
      ]

      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }
    }

    node {
      role = "worker"
    }

    node {
      role = "worker"
    }
  }

}
```

共通部分を main に切り出すのはお作法です。

```hcl
# main.tf
locals {
  name = "my-kind"
}
```

あとは普段どうりで完成

```bash
terraform init
terraform plan
terraform apply
```

backend を定義していないので、ローカルに state ができます。
また、config もローカルに出力されます。
同時に、~/.kube/config が更新されるので、要らなくなったら捨てるのを忘れないように。

# 所感

- ローカルで一人実行なら十分
- kind を kind としてではなく、terraform resource として扱うのは terraform ユーザとしては楽
- 今のところ cluster の設定変更の差分更新はできず、どこを変更してもクラスターごと作り直しになるみたい（providerの仕様）
- 乗せる k8s リソースも helm や terraform でインストールしたり更新したりするテストをするのでとくに困らない
- 普段から terraform 運用をしていると、通常使わない provider はいじらないことが多いと思うので、たまには違うことをしてみるのもおもしろい
- （余談）markdown lint で no-bare-urls に引っ掛けるので、zenn のマークダウンで裸の URL 処理やめて欲しいなって思った
