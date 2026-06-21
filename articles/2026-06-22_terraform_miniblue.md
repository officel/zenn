---
title: "Azure のローカル開発に miniblue を使ってみた。が"
emoji: "📘"
type: "tech"
topics: ["terraform", "azure", "miniblue"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- AWS のローカル開発向け LocalStack が有償化して界隈が賑やか
- 現職は Azure なんだけど、サンドボックス環境があるのでローカル開発してなかった
- いい機会だから terraform 向けの Azure のローカル開発環境を見てみようかなって
- miniblue はちょっとダメかもって話

# いつものように AI に調べてもらった

:::details Azure IaC テスト環境調査

調査で見つかった10ツールの評価根拠と選定理由をまとめます。

> ってなんか表がコピーできなかった

---

## 🥇 1位：Floci AZ（総合95点）

Floci AZはAzure SDK・CLI・TerraformをそのままローカルのAzure互換サービス（localhost:4577）に向けられる設計で、既存ワークフローをそのまま維持できます。
Cosmos DBの6エンジン（MongoDB/PostgreSQL/Cassandra/Gremlin/Table/NoSQL）対応、AKS・APIM・VNetまで含めた幅広いカバレッジが最大の強みです。
多言語（Python・Java・Node・Go）の互換テストマトリクスを持ちます。

### 🥈 2位：miniblue（総合88点）

miniblueはGoバイナリ1個・単一ポートで27のAzureサービスをエミュレートし、Terraform・Pulumi・Azure SDK・curlに対応します。
TerraformからはAzurermプロバイダの`metadata_host`を`localhost:4567`に設定するだけで連携できます。
ministack(AWS版)と同じ思想で作られた、LocalStack有償化対策として設計された専用品です。

### 🥉 3位：Azurite（総合80点）

Azurite(Microsoft公式)はオープンソースで無料のローカル環境を提供し、Blob・Queue・Table Storageを対象にクロスプラットフォームで動作します。
Storage特化ながら、他のエミュレータのバックエンドとしても使われる業界標準的な立ち位置です。

---

### ツール選択の指針

**純粋なエミュレーション目的**（LocalStackの代替という観点）では：

- **Floci AZ** → サービスカバレッジ・IaC連携・テストマトリクスが最充実
- **miniblue** → GoバイナリでシンプルにTerraformと繋ぎたい場合
- **Azurite** → Blob/Queue/Tableのみが対象で十分な場合

**組み合わせ例（おすすめ構成）**：

```text
miniblue or Floci AZ   ← エミュレータ層（IaC apply先）
+ TFLint               ← 構文・ベストプラクティスチェック
+ Checkov              ← セキュリティ/コンプライアンス静的解析
+ Terratest            ← 統合テスト（ステージング環境）
```

4〜7位（Microsoft公式のCosmos DB・Functions・Service Bus・Event Hubsエミュレータ）は個別サービス専用なので、1・2位の統合型と**競合というより補完**の関係です。
:::

# miniblue を試した

- 公式は後ででもいい
- 1位がいいなら先に下から試したほうがプロコンがわかりやすい
- というわけで [miniblue](https://github.com/moabukar/miniblue) を試してみた

```shell
# ドキュメントにあって、手っ取り早い気がするがダメ（cert.pem が取れないので terraform で使えない）
docker run -p 4566:4566 -p 4567:4567 moabukar/miniblue:latest

# なのでこう（目につくドキュメントが悪い。terraform のページで別に起動方法が書かれている）
mkdir ~/.miniblue
sudo chown 65534:65534 ~/.miniblue
docker run -d --name miniblue -p 4566:4566 -p 4567:4567 -v ~/.miniblue:/home/nonroot/.miniblue moabukar/miniblue:latest

# azlocal は問題なかった
go install github.com/moabukar/miniblue/cmd/azlocal@latest

# 動作確認
azlocal health

# リソースグループを作成して確認
azlocal group create --name myRG --location eastus
azlocal group list
azlocal group show --name myRG
azlocal group delete --name myRG
```

- そして terraform

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}

  # Point to miniblue HTTPS endpoint for metadata
  metadata_host              = "localhost:4567"
  skip_provider_registration = true


  # Mock credentials -- miniblue accepts anything
  subscription_id = "00000000-0000-0000-0000-000000000000"
  tenant_id       = "00000000-0000-0000-0000-000000000001"
  client_id       = "miniblue"
  client_secret   = "miniblue"
}

data "azurerm_client_config" "current" {}

output "client" {
  value = data.azurerm_client_config.current
}

resource "azurerm_resource_group" "example" {
  name     = "example-rg"
  location = "East US"
}

```

- examples/terraform のまま（v3）なら動く
- Azure RM Provider v4.0.0 は 2024-08-23 に出てるんだけれども。。。
- Provider v4 にすると resource group の作成でエラーになってしまう
- どうやら API のバージョンに追従できていないっぽい
- 他のリソースは試していないけど、terraform 向けには整備されていないドキュメントや、最新に追従されていないように見えるツールをがんばって使う必要はないかなって

# というわけで

- miniblue は Azure の Iac 向け（terraform向け）には最新化できていないようなので不適と判断
- terraform のコード部分にべた書きサンプル使ってるツールはだいたいダメなんじゃないか疑惑
- provider block の引数部分は環境変数で書いてあるほうが丁寧で親切だと思うの
- cert.pem も環境変数渡しなんだから全部そうすればいいのに、とか思いました。まる。
- とりあえず v4 または今夏予定？の v5 に対応されたらまた考えるということで
