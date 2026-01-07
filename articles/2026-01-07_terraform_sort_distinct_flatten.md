---
title: "terraform の細かすぎて伝わらない小ネタ list 型には sort distinct flatten"
emoji: "📶"
type: "tech"
topics: ["terraform"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- list 型の output がたびたび差分になるのを観測
- sort して解消した
- `sort(distinct(flatten([])))` こんな感じのイディオム

# 元々

- terraform で user などの大量データを扱った後、ids などを作るケース
- 受け取り側がうまいことやってくれると重複を気にしないで list 型を出力しがち
- リソースA,B,Cのように分割して、それぞれ for_each で作って、後から全部欲しい的な

# 例

```hcl
# 例
resource "example" "list_a"{
  for_each = var.data_a
}
resource "example" "list_b"{
  for_each = var.data_b
}
resource "example" "list_c"{
  for_each = var.data_c
}

output "all_example_ids" {
  description = "どちらかといえば locals で整理してから出力しましょう"
  value       = sort(distinct(flatten([
    [for _, o in example.a : o.id],
    [for _, o in example.b : o.id],
    [for _, o in example.c : o.id],
  ])))
}
```

# 実は

- 昔どっかに書き残してた気がするんだけど手元に見つからなかった
- そろそろ記事書かないとなって思ってたのでちょうどいいかって
- 以前のコードでは `tolist(distinct(flatten([])))` のようにしてて list 型を明示的にするだけでわかりやすいと思ってた
- sort() は list 型が返るってわかりやすいから取っていいかなって
- 内容が固定ではない list 型のデータは `sort(distinct(flatten([])))` で常に整理しておくと便利ですよってことで

# 最後に独り言

- そろそろ小技のまとめがいるかも
- terraform から OpenTofu に主軸を移動してるモジュールがちらほらある？どれとは言わないけど
- Provider エコシステムに限界が近いかも？
- 個人的には宣言的じゃない IaC（要は Pulumi や CDK）には興味がないんだけど、どちらかといえばそっち側のほうが市場として大きくなってきてる気がする
- AI とは無関係ではいられなくなってきていると思うんだけど、相変わらずハルシネーションがひどいし、それを正しく着地させるまでのやりとりが正直めんどいｗ
