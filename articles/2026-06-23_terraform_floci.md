---
title: "Azure のローカル開発に floci を使ってみた。が"
emoji: "☁️"
type: "tech"
topics: ["terraform", "azure", "floci"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- AWS のローカル開発向け LocalStack が有償化して界隈が賑やか
- 現職は Azure なんだけど、サンドボックス環境があるのでローカル開発してなかった
- いい機会だから terraform 向けの Azure のローカル開発環境を見てみようかなって
- そんな流れで[Azure のローカル開発に miniblue を使ってみた。が](https://zenn.dev/terraform_jp/articles/2026-06-22_terraform_miniblue)って記事を書いた
- 次は floci ってワケ

# floci を試してみた

- [Floci — Local Cloud Emulators](https://floci.io/)
- [floci-az — Free Azure Emulator](https://floci.io/az/)
- ぱっとしか読んでないのでアレだけど作りが分かりにくいねん。。。
- リソースがたくさん管理できるぜって感じに見えるけど。。。

```yaml:compose.yaml
services:
  floci-az:
    image: floci/floci-az:latest
    container_name: floci-az
    ports:
      - "4577:4577"  # REST API
    volumes:
      - ./data:/app/data  # 証明書等の永続化
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      FLOCI_AZ_TLS_ENABLED: true  # TLS有効化
      FLOCI_AZ_HOSTNAME: floci-az
      FLOCI_AZ_STORAGE_MODE: hybrid
      FLOCI_AZ_LOG_LEVEL: info
    networks:
      - floci_az_default
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:4577/health"]
      interval: 5s
      timeout: 3s
      retries: 10

networks:
  floci_az_default:
```

- どっちかっていうと、リソースを使った開発向けのツールなので、terraform による IaC のテストは対象の全リソースってわけじゃないようだ
- terraform で使うには SSL 化が必須なんだけど、そのための説明とかドキュメントが不親切すぎる。。。_no

```shell
# 起動
docker compose up -d

# SSL を有効にする（compose.yamlで `FLOCI_AZ_TLS_ENABLED=true`）
mkdir -p ~/.floci-az
curl -sk https://localhost:4577/_floci/tls-cert -o ~/.floci-az/cert.pem

# この辺知見がなくてAI頼みなんだけど、Ubuntu 24.04 on WSL2 で問題なかった
sudo cp ~/.floci-az/cert.pem /usr/local/share/ca-certificates/floci-az.crt
sudo update-ca-certificates

# 動作確認
curl http://localhost:4577/health | jq
```

- 箱としては docker が楽みたい
- brew でインストールしても裏は docker が動くみたいなので、最初から compose.yaml 書いた方がコントロールが楽
- 環境も汚れにくいしね

```hcl:main.tf
terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

  metadata_host = "localhost:4577"

  # skip_provider_registration = true # Azure RM Provider v4 系では不要なので

  subscription_id = "00000000-0000-0000-0000-000000000000"
  tenant_id       = "00000000-0000-0000-0000-000000000001"
  client_id       = "floci"
  client_secret   = "floci"
}

data "azurerm_client_config" "current" {}

output "client" {
  value = data.azurerm_client_config.current
}

resource "azurerm_resource_group" "example" {
  name     = "floci-test-rg"
  location = "West Europe"
}
```

- SSL 設定が通ってないと plan エラーになる
- もうこの辺のドキュメントが不明瞭な時点でこれもダメだろって思った
- そもそも resource_group についてはドキュメントで触れられてないっぽいし
- 全然別件なんだけど、この手のテストに使われるサブスクリプションやテナントのIDって、なんでサブスクが1でテナントが0なんでしょう？
- 構造的にはテナントが最初でサブスクがぶら下がるんじゃないのかなって（Azure無知）

```shell
# terraform でリソースグループを作成後、リソースグループをリストしてみる
curl http://localhost:4577/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups?api-version=2024-05-01 | jq
```

- とりあえず terraform を通すのはできた
- `azfloci.py` で az をラッピングすることで az cli を使って動作確認ができるってことだったんだけど、できなかった
- 具体的にはエンドポイントを `http://localhost:4577` にしていると、az が python の実行時エラーになってしまう
- https にするとそれはそれでエラーになってしまう（それはそう）で、結局解消できなかった
- `brew install azure-cli` してると Python が brew に引っ張られてしまうところとか知見が足りな過ぎた
- リソースグループ以外のリソースはまだ試していないけど、az がラップできないとリソースのチェックが面倒
- terraform の対象リソースがそもそも期待したほど多くない
- つらい。。。

# というわけで

- miniblue よりはちょっとマシ（v4が使えるので）
- だけどやっぱり適切とは言い難いっぽい
- terraform の azure rm provider をテストするのを主眼に置くならサンドボックス環境で実リソースが一番いい気がした
- ちょっと気分転換のつもりで実リソースを使わない IaC のテスト、みたいなお気持ちだったけど今はまだダメかなって
