---
title: "editorconfig とその設定"
emoji: "📝"
type: "tech" # tech or idea
topics: ["editorconfig"]
published: true
---

# tl;dr

- editorconfig について
- 近縁の設定について
- こんな設定しているぜをください

# editorconfig

@[card](https://editorconfig.org/)

- コーディングスタイルの一貫性を維持するための設定
- IDE 等で設定すれば自動的に適用される
- 設定に過ぎないので、ルールを共有しているだけ、とも受け取れる（強要はしていない）

## 個人的に使っている設定

```text:.editorconfig
root = true

[*]
charset = utf-8
end_of_line = lf
indent_size = 2
indent_style = space
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
max_line_length = 160
```

- 面倒なので最初に全部設定しておく
- Windows でも utf-8, lf に設定しておくと面倒が少ない
- `spelling_language` は別のツールで設定しているので書いていない
- 項目でソートしておくと見やすい（VS Code なら行を選択して `ctrl+shift+p` から `Sort Lines Ascending`）
- 必要に応じてファイルタイプ別に設定を変更することでわかりやすくしている
- 本家ドキュメントでは次のように書かれているので逆走している自覚はある
- （世界規模で独裁は無理だけどチーム内やプライベートは問題ないと思っている）

> It is acceptable and often preferred to leave certain EditorConfig properties unspecified.
> For example, tab_width need not be specified unless it differs from the value of indent_size.
> Also, when indent_style is set to tab, it may be desirable to leave indent_size unspecified
> so readers may view the file using their preferred indentation width.
> Additionally, if a property is not standardized in your project (end_of_line for example),
> it may be best to leave it blank.

## 個人的に使わない設定

- 基本的にユニバーサル以外は使わない（max_line_length はテスト的に使用している）
- ドメイン固有プロパティはそれぞれで必要な場所で設定すればいいと思っている
- ドメイン固有の設定はそれぞれ設定ファイルを持っている（はずな）ので、両方で設定する必要はないという判断
- 言語やフレームワークの設定で宗教戦争するのがめんどくさいだけ

# 近縁の設定

- prettier は editorconfig の設定も読める（そしてそれ以上のフォーマットもしてくれる）
- VS Code にも同様の設定をするフラグがある（ないものもあるけどコマンドでできたりする）
- pre-commit で使えるフックにも同様の設定をする機能がある
- 言語やフレームワーク特有のフォーマットやルールはそれぞれ適用すればいいと思います

## 基本的にはどれかではなく全部使うのがいい

- editorconfig は仕様の説明（共通のルールなので変更については git 上で議論可）
- prettier はローカルでの設定（他のツールで代替しても構わない。リポジトリに設定を置くのはやめて欲しいけど）
- pre-commit はローカルおよびリモート側でのチェック（最悪ローカルでは何もしなくても CI で PR 時にチェック可）
- のように役割分担と代替可能性を有している

# 設定教えてください

- [公式ドキュメントにリンクがある](https://github.com/editorconfig/editorconfig/wiki/Projects-Using-EditorConfig)
- 他所での使われ方とか言語毎の調整とか知りたいので、うちはこうしてるぜ、を教えてほしい
- 言語毎の設定は（使ってないので）書いていないので、変更が必要かもしれない

# おまけ

## Q. チームのリポジトリでこっそり使うには

A. `.git/info/exclude` に追加しておいて様子見するとよし。

## Q. Windows でも lf

A. 基本的に一度も困ったことはないけど、扱うものが違うせいかもしれないので、問題があったらぜひ教えて欲しい

## Q. 複数箇所で設定するのムダじゃない？

A. 基本的にはそのとおり。
たまたま vi や Codespace で書いたり、他所から PR もらったり、うっかりチェック漏れしたりするケースに備えているだけ。
備えあれば憂いなしって言葉があるのに、わざわざ憂いを残して使わないのはもったいない。
