---
title: "Variable and Output Deprecation を試してみる"
emoji: "⚠️"
type: "tech"
topics: ["terraform"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- terraform v1.15.0 で追加される予定の deprecated attribute on variable and output blocks を試してみた
- 普段遣いではそんなにうれしくもないけど PFE 的なポジションから提供している自作モジュール等では表現として使えるなって

@[card](https://github.com/hashicorp/terraform/releases/tag/v1.15.0-rc2)

# deprecated attribute on variable and output blocks

- モジュールで使用される variable と output ブロックに `deprecated` をつけると plan/apply 時に教えてくれる機能追加

@[card](https://github.com/hashicorp/terraform/pull/38001)

# やってみた

```hcl:module/my_module/main.tf
resource "terraform_data" "this" {
  input = coalesce(var.new_variable, var.old_variable)
}

output "content" {
  value = terraform_data.this.output
}

output "old_content" {
  value      = terraform_data.this.output
  deprecated = "Use 'content' instead."
}

terraform {
  required_version = ">= 1.15.0"
  # rc は指定できないので、1.15.0 以降とする（GA前テストのお約束）
}

variable "old_variable" {
  type       = string
  default    = "deprecated"
  deprecated = "Use 'new_variable' instead."
}

variable "new_variable" {
  type    = string
  default = "active"
}
```

:::message
実コードは tflint してるので別ファイルだけど cat *.tf でまとめてある
:::

```hcl:main.tf
module "my_module" {
  source = "./modules/my_module"

  old_variable = "OLD_VALUE"
  new_variable = "NEW_VALUE"
}

output "module_content" {
  value = module.my_module.content
}

output "module_old_content" {
  value = module.my_module.old_content
}

terraform {
  required_version = ">= 1.15.0"
  # rc は指定できないので、1.15.0 以降とする（GA前テストのお約束）
}
```

:::message
そんなにいい例でもなかったかも。まぁ結果がわかればいいか
:::

# 結果

```bash
$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.my_module.terraform_data.this will be created
  + resource "terraform_data" "this" {
      + id     = (known after apply)
      + input  = "NEW_VALUE"
      + output = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + module_content     = (known after apply)
  + module_old_content = (known after apply)
╷
│ Warning: Deprecated variable got a value
│
│   on main.tf line 4, in module "my_module":
│    4:   old_variable = "OLD_VALUE"
│
│ Use 'new_variable' instead.
│
│ (and one more similar warning elsewhere)
╵
╷
│ Warning: Deprecated value used
│
│   on outputs.tf line 6, in output "module_old_content":
│    6:   value = module.my_module.old_content
│
│   The deprecation originates from module.my_module.old_content
│
│ Use 'content' instead.
│
│ (and one more similar warning elsewhere)
╵

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


module.my_module.terraform_data.this: Creating...
module.my_module.terraform_data.this: Creation complete after 0s [id=28db1028-c63c-dbce-6953-36cddcd96993]
╷
│ Warning: Deprecated variable got a value
│
│   on main.tf line 4, in module "my_module":
│    4:   old_variable = "OLD_VALUE"
│
│ Use 'new_variable' instead.
╵
╷
│ Warning: Deprecated value used
│
│   on outputs.tf line 6, in output "module_old_content":
│    6:   value = module.my_module.old_content
│
│   The deprecation originates from module.my_module.old_content
│
│ Use 'content' instead.
╵

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

module_content = "NEW_VALUE"
module_old_content = "NEW_VALUE"
```

- プロバイダーのバージョンがあがって変更がある時に見るやつと同じ形式で教えてくれる
- `deprecated` だけでこれが出せるのは便利

# まとめ

- terraform v1.15.0 から variables と output に deprecated がつけられるようになる
- 主に自作モジュールでの変更のお知らせに使える
- terraform block の require_version は `1.15.0` にする必要がある（以前のバージョンでは使えないので）
- 自作モジュールの利用者に terraform 本体の更新をせまるチャンス！（違うか）
- 個人的に 1.15.0 にはこれだ！って新機能が見当たらないので、とりあえず手軽なところから試してみたってワケ
