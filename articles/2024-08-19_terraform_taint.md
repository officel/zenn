---
title: "terraform で細かすぎて伝わらない小ネタ taint/untaint と -replace"
emoji: "✅"
type: "tech"
topics: ["terraform"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- terraform v0.15.2（2021年なのでだいぶ前）から非推奨になった taint とその代替の -replace
- 代替もあわせて遊び方を掘り起こし

# links

@[card](https://developer.hashicorp.com/terraform/cli/commands/taint)
@[card](https://developer.hashicorp.com/terraform/cli/commands/plan#replace-address)

# code

```hcl:main.tf
resource "random_string" "random" {
  length      = 8
  min_numeric = 4
  min_lower   = 4
}

output "random_name" {
  value = "this_is_random_${random_string.random.result}"
}
```

# 準備（いつもの）

```bash
$ terraform init

$ terraform plan

$ terraform apply
```

# taint & untaint

- 差分なしを確認

```bash
$ terraform plan
random_string.random: Refreshing state... [id=3162wwzp]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```

- taint

```bash
$ terraform taint random_string.random
Resource instance random_string.random has been marked as tainted.

$ terraform plan
random_string.random: Refreshing state... [id=3162wwzp]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # random_string.random is tainted, so must be replaced
-/+ resource "random_string" "random" {
      ~ id          = "3162wwzp" -> (known after apply)
      ~ result      = "3162wwzp" -> (known after apply)
        # (10 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  ~ random_name = "this_is_random_3162wwzp" -> (known after apply)

───────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```

- state が更新されるのを確認
- このせいで同時に処理される他の人に影響を与えてしまう（ので非推奨になった）

```bash
$ diff terraform.tfstate*
4c4
<   "serial": 3,
---
>   "serial": 2,
20d19
<           "status": "tainted",
```

- untaint
- state は更新されてしまうけど tainted は付けたり外したりできる
- 同時に他でapplyが走るとまずいことになる

```bash
$ terraform untaint random_string.random
Resource instance random_string.random has been successfully untainted.

$ terraform plan
random_string.random: Refreshing state... [id=3162wwzp]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

$ diff terraform.tfstate*
4c4
<   "serial": 4,
---
>   "serial": 3,
19a20
>           "status": "tainted",
# state から status tainted が消えた（矢印の方向に注意）
```

# -replace

- v0.15.2 以降からの推奨
- state を更新しない（実行時にマーキングするだけ）
- 読み慣れないとドキュメントからは読み取りにくいけど、plan と apply の両方で使える
- apply で適用しなければ他の人に影響を与えない

```bash
$ terraform plan -replace random_string.random
random_string.random: Refreshing state... [id=3162wwzp]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # random_string.random will be replaced, as requested
-/+ resource "random_string" "random" {
      ~ id          = "3162wwzp" -> (known after apply)
      ~ result      = "3162wwzp" -> (known after apply)
        # (10 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  ~ random_name = "this_is_random_3162wwzp" -> (known after apply)

───────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.


# -replace をつけないで plan しなおすと差分がないのがわかる


$ terraform apply -replace random_string.random -auto-approve
random_string.random: Refreshing state... [id=3162wwzp]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # random_string.random will be replaced, as requested
-/+ resource "random_string" "random" {
      ~ id          = "3162wwzp" -> (known after apply)
      ~ result      = "3162wwzp" -> (known after apply)
        # (10 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  ~ random_name = "this_is_random_3162wwzp" -> (known after apply)
random_string.random: Destroying... [id=3162wwzp]
random_string.random: Destruction complete after 0s
random_string.random: Creating...
random_string.random: Creation complete after 0s [id=0741qaiu]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

Outputs:

random_name = "this_is_random_0741qaiu"

# apply すると値が変わる
```

# 最後に

- taint/untaint は1人で遊ぶ時は問題ない
- 同じディレクトリで他の人も触る可能性がある場合に影響がある（かもしれない）
- 今後は -replace を使用する
- いつか taint/untaint は remove されるのかしら（v1になってずいぶん経つし放置なのかな）
- terraform はコマンド叩いてなんぼなので、普段使わないようなオプション類も遊んでみると理解が深まって楽しいよ
