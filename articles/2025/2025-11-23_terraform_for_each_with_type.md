---
title: "terraform の細かすぎて伝わらない小ネタ for_each と型"
emoji: "➿"
type: "tech"
topics: ["terraform"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- terraform でよくお世話になる meta-argument の for_each の変数の渡し方
- `for_each = var.xxx != null ? var.xxx : {}` みたいに書くのが嫌だなって
- `for_each = tomap(coalesce(var.type_map, {}))` というイディオムでどうか

# for_each = var.xxx != null ? var.xxx : {} の嫌なところ

- null エラーを回避するために三項演算子を使用している
- 変数を 2 回書いている
- 変数名が長いと読みにくい
- for_each には map か set が渡せるが、このコードでは判断しにくい
- （そもそも判断が必要かどうかは置いておく）

# for_each への変数の渡し方

- 今回は直接 variable を渡すようなケースだけ

```hcl
# null が入った時にエラーで死ぬので却下
for_each = var.type_map
for_each = var.type_set

# 三項演算子は冗長で、型がわかりにくい（から今回の記事を書いた）
for_each = var.type_map != null ? var.type_map : {}
for_each = var.type_set != null ? var.type_set : []

# coalesce() でいけるが空の型 `{} / []` は必要なのが気になる
for_each = coalesce(var.type_map, {})
for_each = coalesce(var.type_set, [])

# 明確な表現
for_each = tomap(coalesce(var.type_map, {}))
for_each = toset(coalesce(var.type_set, []))

# tomap() は null を受け付けないが merge() は空の map として扱える
for_each = tomap(merge(var.type_map))
# 残念ながら set 型では同様に null をスルーできる単独の function がないみたい？
```

# テスト用のコード

- このまま適当な空ディレクトリに突っ込んでテスト可

```hcl
variable "type_map" {
  type = map(object({
    name = string
    age  = number
  }))
  default = {
    user1 = {
      name = "Alice"
      age  = 30
    }
    user2 = {
      name = "Bob"
      age  = 25
    }
  }
  description = "map 型のテスト変数"
}

# resource "terraform_data" "type_map_no_good" {
#   for_each = var.type_map
#   input    = join("_", [each.key, each.value.name, each.value.age])
# }

resource "terraform_data" "type_map_good" {
  # 三項演算子は冗長で、型がわかりにくい
  for_each = var.type_map != null ? var.type_map : {}
  input    = join("_", [each.key, each.value.name, each.value.age])
}

resource "terraform_data" "type_map_better" {
  # coalesce() でいけるが空の型 `{}` は必要
  for_each = coalesce(var.type_map, {})
  input    = join("_", [each.key, each.value.name, each.value.age])
}

resource "terraform_data" "type_map_best" {
  # set 型と差異の少ない明確な表現
  for_each = tomap(coalesce(var.type_map, {}))
  input    = join("_", [each.key, each.value.name, each.value.age])
}

resource "terraform_data" "type_map_other" {
  # tomap() は null を受け付けないが merge() は空の map として扱える
  for_each = tomap(merge(var.type_map))
  input    = join("_", [each.key, each.value.name, each.value.age])
}


variable "type_set" {
  type = set(string)
  default = [
    "Alice",
    "Bob",
    "Charlie"
  ]
  description = "set 型のテスト変数"
}

# resource "terraform_data" "type_set_no_good" {
#   for_each = var.type_set
#   input    = each.key
#   # ちなみに set 型の each.value は each.key と同じ値になる（どっちも使える）
# }

resource "terraform_data" "type_set_good" {
  # var をニ回書くの嫌じゃない？
  for_each = var.type_set != null ? var.type_set : []
  input    = each.value
}

resource "terraform_data" "type_set_better" {
  # coalesce() でいけるが空の型 `[]` は必要
  for_each = coalesce(var.type_set, [])
  input    = each.key
}

resource "terraform_data" "type_set_best" {
  # map 型と差異の少ない明確な表現
  for_each = toset(coalesce(var.type_set, []))
  input    = each.key
}

```

- tfvars や -var で値を変更してテストしてみて

# 考察

- map の場合は merge だけで抜ける
- set には同様に null を考慮しないでいい関数がない
- イディオムとしては coalesce() を使用しつつ型変換関数を明示するのがわかりやすいかなと
- 少なくても変数を 2 回書くよりはいいはず
