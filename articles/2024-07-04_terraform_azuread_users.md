---
title: "terraform で細かすぎて伝わらない小ネタ ignore_missing in azuread_users"
emoji: "🤏"
type: "tech"
topics: ["terraform", "azure", "azuread"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

@[card](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/users#ignore_missing)

- 細かすぎて伝わらない小ネタシリーズ
- 通常のデータソースは対象のリソース等が1件もない場合にエラーになって落ちる
- azuread_users データソースでは ignore_missing arguments を true にすることで対象のユーザが見つからない場合でもエラーにならない

# azuread_users data source

- Azure Active Directory Provider のデータソースの1つ
- Azure Active Directory のユーザー情報を取得する
- 全件取得（return_all）の他、名前、ID、メールアドレス等で検索ができる
- 他のプロバイダーのデータソースもだいたい同じだが、検索結果が0件の場合はエラーで停止する
- `ignore_missing = true` を設定するとエラーを無視してくれる（ただし return_all との併用は不可）

# azuread provider でも半々くらい

- ある例 [azuread_service_principals | Data Sources | hashicorp/azuread | Terraform | Terraform Registry](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principals)
- ない例 [azuread_domains | Data Sources | hashicorp/azuread | Terraform | Terraform Registry](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/domains)
- なかったらなかったでどうにかなる系とそうじゃない系ということ？

# 小ネタ？

- ちゃっかり業務で調べて課題を回避したのでネタにした
- 個人的にはメタ引数化して全データソースで0件エラーを回避できるようになってもいいと思っている
- 今月から Azure をメインに仕事をすることになってなかなか楽しい
