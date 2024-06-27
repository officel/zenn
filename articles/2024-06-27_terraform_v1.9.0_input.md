---
title: "terraform v1.9.0 では input の変数チェックに他の変数を利用できるようになりました"
emoji: "📑"
type: "tech"
topics: ["terraform"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- 🎉 [Release v1.9.0 · hashicorp/terraform](https://github.com/hashicorp/terraform/releases/tag/v1.9.0)
- input variables validation rules can refer to other objects ってことで、入力値のチェック処理に他の変数を使用することが可能になりました
- [この辺](https://developer.hashicorp.com/terraform/language/values/variables#custom-validation-rules)がもっと便利になったということ

# たとえば

```hcl:local.tf
locals {
  # ami の image_id に次のいずれかの番号を使用することにしたい
  allow_image_id = [
    "ami-11111",
    "ami-22222",
    "ami-33333"
  ]
}
```

というバリデーションを書きたいとする。

# これまで（v1.8.x 以前）

```hcl:input.tf
variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."

  default = "ami-11111"

  validation {
    # サンプルの validation
    condition     = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }

  validation {
    # v1.8.x までならこう書くしかなかった
    condition     = contains(["ami-11111", "ami-22222", "ami-33333"], var.image_id)
    error_message = "The image_id value must be a valid AMI id and must also be one of the following [ami-11111,ami-22222,ami-33333]."
  }
}
```

validation block に他の変数を含めることができなかったので、リストからの選択等、ちょっとしたバリデーションも書くのが面倒な場合が多かった。

# これから（v1.9.0 以降）

```hcl:input.tf
variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."

  default = "ami-11111"

  validation {
    # サンプルの validation
    condition     = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }

  validation {
    # v1.9.0 からはこう書けるようになった。見やすい！
    condition     = contains(local.allow_image_id, var.image_id)
    error_message = format("The image_id value must be a valid AMI id and must also be one of the following %v.", local.allow_image_id)
  }
}
```

# 比較

v1.8.x だと validation block に自分（var.image_id）以外の変数は使えない

```bash
2024-06_v1.9.0_input_validation $ cat .terraform-version
latest:^1.8
2024-06_v1.9.0_input_validation $ terraform plan
╷
│ Error: Invalid reference in variable validation
│
│   on main.tf line 30, in variable "image_id":
│   30:     condition     = contains(local.include_image_id, var.image_id)
│
│ The condition for variable "image_id" can only refer to the variable itself, using var.image_id.
╵
╷
│ Error: Invalid reference in variable validation
│
│   on main.tf line 31, in variable "image_id":
│   31:     error_message = format("The image_id value must be a valid AMI id and must also be one of the following %v.", local.include_image_id)
│
│ The error message for variable "image_id" can only refer to the variable itself, using var.image_id.
╵
```

v1.9.0 では使える。

```bash
2024-06_v1.9.0_input_validation $ cat .terraform-version
latest:^1.9
2024-06_v1.9.0_input_validation $ terraform plan

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```

エラーにさせてみる

```bash
2024-06_v1.9.0_input_validation $ tp -var image_id=ami12345

Planning failed. Terraform encountered an error while generating this plan.

╷
│ Error: Invalid value for variable
│
│   on main.tf line 10:
│   10: variable "image_id" {
│     ├────────────────
│     │ var.image_id is "ami12345"
│
│ The image_id value must be a valid AMI id, starting with "ami-".
│
│ This was checked by the validation rule at main.tf:16,3-13.
╵
╷
│ Error: Invalid value for variable
│
│   on main.tf line 10:
│   10: variable "image_id" {
│     ├────────────────
│     │ var.image_id is "ami12345"
│
│ The image_id value must be a valid AMI id and must also be one of the following [ami-11111,ami-22222,ami-33333].
│
│ This was checked by the validation rule at main.tf:22,3-13.
╵
╷
│ Error: Invalid value for variable
│
│   on main.tf line 10:
│   10: variable "image_id" {
│     ├────────────────
│     │ local.include_image_id is tuple with 3 elements
│     │ var.image_id is "ami12345"
│
│ The image_id value must be a valid AMI id and must also be one of the following ["ami-11111","ami-22222","ami-33333"].
│
│ This was checked by the validation rule at main.tf:28,3-13.
╵
```

# 結論

バリデーションが書きやすくなった！

@[card](https://github.com/officel/zenn/tree/main/terraform/2024-06_v1.9.0_input_validation)
