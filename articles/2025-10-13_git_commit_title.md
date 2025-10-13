---
title: "よいコミットタイトルの書き方の練習方法"
emoji: "☄️"
type: "tech" # tech or idea
topics: ["git", "conventional commit"]
published: true
---

# tldr

- 多くの git log を読む
- conventional commit を使う
- 使う単語を吟味する
- 優先順位を決める
- 自分たちなりの型を作る

# はじめに

- コミットタイトルはコードと同じくらい大事
- 同僚氏がよいコミットタイトルの書き方を知りたがっていた
- 自分もいまだ修行中だけど、とりあえず少しマシになる方法を共有してみる

# 練習方法

## 多くの git log を読む

- `git log --oneline`
- GitHub でお気に入りのリポジトリを見つけて、ひたすら log を読む
- もしくは自分たちのリポジトリの log を読むでもかまわない
- コミットタイトルだけでどのような内容なのかを推測する
- 内容が推測どおりのコミットはよいコミットのはずなので、なぜよいのかを考える
- 内容が推測できないコミットタイトルはよくないコミットのはずなので、なぜよくないのかを考える

:::message info
手直しするとしたらどのように書くかを考える
:::

## conventional commit を使う

@[card](https://www.conventionalcommits.org/)

- [Conventional Commit の TYPE 選択フロー](https://zenn.dev/raki/articles/2025-07-25_conventional_commit)
- 手癖でこの型で書けるようにする
- 自動化による振り分けを理解すると取捨選択が容易になると思う
- [conventional-changelog](https://github.com/conventional-changelog/conventional-changelog)
- 反論について後述しているので参考までに見ておきましょう
- 個人的な好き嫌いと仕事での協業は別ものだと理解しないと平行線をたどるしかないので注意する

## 使う単語を吟味する

- 荒療治的に、以下の単語を使わないことにする

  - add
  - update
  - change
  - delete

- 人によって説明的にするために動詞を書きたがる人もいるので要調整
- リポジトリを変更する（git log を作る）ということは、追加・変更・削除のいずれかである
- 追加するなら `feat:` で伝わる → `add` は不要
- 変更するなら `fix:` や `refactor:` で伝わる → `update` や `change` は不要。そもそも変更するためにコミットしているのだ
- 削除するなら `refactor` でいいと思うが `feat: remove` か `fix: remove` でもわかりやすい
- コミットタイプとして `rm:` か `remove:` を作ってもよい（conventional commit は独自の型を制限していない）
- 極力ムダな動詞を省くことで、本当に書くべきことを書けるようになる（文字数的に）
- 単語ではないけど、日本語を使うのをやめる（本文は構わない）癖をつけておくとよい
- 同様に、一時期流行った絵文字を使うのもやめる（遊びでは構わないが実際ただのノイズである）

:::message
余談 delete vs remove

- ファイルの削除の場合に `delete` が、文字や行の削除の場合に `remove` が使われるとされてきた（ぐぐってみよう）
- 使い分けがしっかりできていれば問題ないが、曖昧に使うと検索時に邪魔になるので、統一してあると楽
- 純粋な Windows ユーザーは `del` かもしれないが、Linux や macOS ユーザーは `rm` のほうが伝わる
- git も削除コマンドは rm であることから、`remove` を使うことにしておくと統一しやすい
- ちなみに個人的には `fix: rm FILENAME` や `fix: rm FUNCTIONNAME` のようにしている
- 同様に、移動の場合は `mv` を使うことにしている
  :::

## 優先順位を決める

- コミットの粒度や規模によって異なることは充分に意識する
- 前述のとおり、タイトルだけで内容が推測できるのがよいコミットタイトルである
- つまり変更内容の要約がタイトルになっているのが望ましい
- とはいえ長すぎるタイトルは読みにくい
- コミットタイトルに何を残して、何を削るか、の優先順位を決めておく

  - まず削れるのが前述の動詞。何をしたかを書けという説明は動詞を書けという意味ではないことに注意
  - 次になぜやるか（本文に書けば済む）を削る
  - 次にどうやるか（本文に書けば済む）を削る

- すると、何をどうしたのか、が残る（はず）
- これは、何がどうなるのか、とほぼ同じ意味（英語の文献ではこれがもっとも推される）
- チケット番号を入れるルールにするところも多いのでそれも残る

## 自分たちなりの型を作る

- ここまでの内容を踏まえて、自分たちなりの型を作る。基本はだいたいこう

```txt
TYPE(SCOPE): #TICKET explain what happens
```

- 代替案的な例

```txt
# update README 代替案
docs: #12345 link to zenn top page

# 一般的に chore のコミットの中身は精査しない（検索時にスルーする）ものとして扱う
chore(README): link to zenn top page

# add function 代替案
feat(subA): verify_email() to login steps（ファイル名が入るとなお可）

# fix settings 代替案
fix: max_retry 1 to 5 for network errors
fix: innodb_buffer_pool_size 128M to 256M
```

- コミットタイトルは何をしたいのかの事実を書くとわかりやすい
- なぜそうしたのか、指示元はどこか、などはコミット本文やコードコメントに書く
- ちなみに、コミットタイトルと PR タイトルは異なるものであり、複数のコミットをまとめた PR （ブランチ）タイトルがこれまでの例に合致するとは限らないので注意する
- 同様に、コミットはタイトルだけちゃんとしておいて、PR 本文で必要な情報を記載するのも構わない（はず）

# よくある反論

- conventional commits がすべてではない
- 短いタイトルだけがよいわけでもない
- [Conventional Commits considered harmful](https://larr.net/p/cc.html)
- [I hate Conventional Commits — musicmatzes blog](https://beyermatthias.de/i-hate-conventional-commits)
- [Conventional Commits が悪いアイデアだと思う理由 | /dev/jasmin](https://jasminchen.dev/articles/2022/why-conventional-commits-are-a-bad-idea/)
- など、反対の意見を表明する人たちもいる
- 中には自動化された changelog に価値を感じないという意見もあって、それはそれでユースケースのひとつではあると思う
- もっとも、初学者・チーム・ガイドライン・自動化における要件を満たす完全な代案は見たことがない

# まとめ

- よいコミットタイトルは定義からして難しい
- あるべき形や期待値、読みやすさ等の好みや価値観が人によって違うから
- だからこそ、自分が納得する形にする必要があり、ひとつひとつのコミットを大事にする必要がある
- よくできたコミットは（自分なりに納得した）コミットタイトルからと心得よう

:::message
コミットにふさわしいアイコンが決めきれなかったので comet にしたのはただの typo だと思っていただければｗ
:::
