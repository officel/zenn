---
title: "terraform azurerm provider v4.0.0 が GA"
emoji: "✨"
type: "tech"
topics: ["terraform", "azure", "terraform provider", "azurerm"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- [Terraform AzureRM provider 4.0 adds provider-defined functions](https://www.hashicorp.com/blog/terraform-azurerm-provider-4-0-adds-provider-defined-functions)
- 記事が出た時はまだ GitHub 側ではタグ打たれてなかったｗ
- 最近仕事で Azure を触っているけどまだまだできていない
- いい機会なので使ってない機能を遊んでいく

# Functions

- provider function がドキュメントのメニューで Guide のすぐ下なのでここから
- 同僚氏も parse_resource_id function 便利そうですねって言ってたので見てみる

```hcl:mai.tf
# これ書かないと function がないって怒られる
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/4.0.0/docs/functions/parse_resource_id

provider "azurerm" {
  features {}
}

locals {
  parsed_id = provider::azurerm::parse_resource_id("/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.ApiManagement/service/service1/gateways/gateway1/hostnameConfigurations/config1")
}

output "parsed" {
  value = local.parsed_id
}

output "resource_name" {
  value = local.parsed_id["resource_name"]
}
```

- 単純にこれだけなら Azure にログインしておく必要もない
- `The Subscription ID which should be used.` って聞かれるけど、適当な値でも大丈夫
- そもそもコードに書いてあるリソースIDも適当っぽい
- なるほどなるほど

@[card](https://github.com/hashicorp/terraform-provider-azurerm/blob/v4.0.0/internal/provider/function/parse_resource_id.go)

# ぶっちゃけ

- Azure はまだまだこれから勉強しないとなのでちょいちょい見ていく
- AWS でやってたように Terraform の data source でリソースがっつりリストしてレポートを作って理解を深めていきたい
