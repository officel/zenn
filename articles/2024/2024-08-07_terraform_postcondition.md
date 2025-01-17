---
title: "terraform で細かすぎて伝わらない小ネタ condition"
emoji: "🏁"
type: "tech"
topics: ["terraform"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- data ソース等で文字列を生成するケース（jsonなど）
- AWS の IAM Policy Document 等にはサイズ制限がある（当然）
- 事前チェックをしないとplanは通るのにapplyに失敗することがある
- というわけで事前チェック

# コード

@[card](https://developer.hashicorp.com/terraform/language/checks)

check block を使う方法だと terraform の実行はブロックされないので、precondition または postcondition を使うほうが手っ取り早い。

```hcl:main.tf
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "oidc" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:my_org/my_repo:*"
      ]
    }
  }

  lifecycle {
    postcondition {
      condition     = length(self.json) <= 100
      error_message = "too long"
    }
  }
}

resource "aws_iam_role" "oidc" {
  name               = "GitHubActionsOIDC_my_repo"
  assume_role_policy = data.aws_iam_policy_document.oidc.json
}

```

- ポリシーの組み立ては例（OIDCのポリシーにステートメントで権限をつける人はそういないと思うけど）
- 制限ぎりぎりを攻めると運用が面倒なので、小さめのしきい値で早めに気がつくようにするとよい
- 他にもいろんなところに制限が隠れているので事前にチェックできるようにして、クォータ引き上げが可能なものは対処できるようにされたし

# エラー例

```bash
data.aws_caller_identity.current: Reading...
data.aws_caller_identity.current: Read complete after 0s [id=]
data.aws_iam_policy_document.oidc: Reading...
data.aws_iam_policy_document.oidc: Read complete after 0s [id=]

Planning failed. Terraform encountered an error while generating this plan.

╷
│ Error: Resource postcondition failed
│
│   on main.tf line 34, in data "aws_iam_policy_document" "oidc":
│   34:       condition     = length(self.json) <= 100
│     ├────────────────
│     │ self.json is "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": \"sts:AssumeRoleWithWebIdentity\",\n      \"Principal\": {\n        \"Federated\": \"arn:aws:iam::534312973966:oidc-provider/token.actions.githubusercontent.com\"\n      },\n      \"Condition\": {\n        \"StringEquals\": {\n          \"token.actions.githubusercontent.com:aud\": \"sts.amazonaws.com\"\n        },\n        \"StringLike\": {\n          \"token.actions.githubusercontent.com:sub\": \"repo:my_org/my_repo:*\"\n        }\n      }\n    }\n  ]\n}"
│
│ too long
╵
```

# 最後に

- 自作モジュール等で制限にかかりそうなリソースを扱う際に組み込んでおくと便利
- 失敗する前に原因を排除できるようになると、他の失敗に対処する余裕ができる
- ちなみに、もっとも身近なところではリソースの命名規則やタグ付けの使用可能文字や文字数に仕掛けておくとよい
