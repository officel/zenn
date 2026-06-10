---
title: "BetterLeaks を pre-commit で使う時の工夫"
emoji: "🛠️"
type: "tech" # tech or idea
topics: ["git", "pre-commit", "prek", "betterleaks", "gitleaks"]
published: true # 公開前に true に直す
---

# tl;dr

- GitLeaks はセキュリティパッチのみの提供になったようです
- 代替は BetterLeaks です
- pre-commit(prek) で使う場合には工夫があるといいです

# GitLeaks

- [gitleaks/gitleaks: Find secrets with Gitleaks 🔑](https://github.com/gitleaks/gitleaks)
- リポジトリにシークレット等が入り込まないようにチェックするツール
- pre-commit などで commit や push 時に実行すると便利

:::message
Gitleaks is feature complete. I'm not merging new features into Gitleaks. Future releases will be security patches only. I'm shifting my focus to Betterleaks
:::

- ということなので、今後は BetterLeaks を使いましょう
- （ってことになってるのに GitLeaks を使うという記事がここ数日多いので書いた）

# BetterLeaks

- [betterleaks/betterleaks: Scan the world (for secrets)](https://github.com/betterleaks/betterleaks)
- 今後はこっちを使う
- pre-commit 的には gitleaks を betterleaks に置き換える（両方書いておいても可）だけ
- いろいろ設定ができるけど、とりあえず設定ファイルなしでチェックするのがよさげ

```yaml:.pre-commit-config.yaml
  - repo: https://github.com/betterleaks/betterleaks
    rev: 40d5cafea2045d16a217c1b70a69d6bba6b892ec  # frozen: v1.4.1
    hooks:
      - id: betterleaks
```

- [&quot;pre-commit run --all-files&quot; does not work · Issue #152 · betterleaks/betterleaks](https://github.com/betterleaks/betterleaks/issues/152)
- この辺ツールによって設定が異なるので仕方ないんだけど、BetterLeaks はデフォルトでは **差分しかチェックしない**
- Issue にも書いたけど

```yaml:.pre-commit-config.yaml
  - repo: https://github.com/betterleaks/betterleaks
    rev: 40d5cafea2045d16a217c1b70a69d6bba6b892ec  # frozen: v1.4.1
    hooks:
      - id: betterleaks
      - id: betterleaks
        entry: betterleaks dir ./ --verbose
        stages: [manual]
```

- こんな感じにしてあげると `pre-commit run -a --hook-stage manual` みたいにすることで全チェックができるようになる
- 表のドキュメントとかに乗せておいてくれてもいいくらいのはまりポイントだと思うんだけども。。。
- `pre-commit run -a` と両方走らせて、`Detect hardcoded secrets` が2回走ってるかどうかで判断つきます

# まとめ

- GitLeaks から BetterLeaks への移行準備をしましょう
- （ツールを変える時は当然だけど）対象の範囲とか結果をちゃんとチェックしましょう
- pre-commit も [j178/prek](https://github.com/j178/prek) に置き換えるといいでしょう
