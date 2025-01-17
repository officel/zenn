---
title: "Rust 向けのテンプレートエンジン minijinja を使い始めたので"
emoji: "⛩"
type: "tech"  # tech or idea
topics: ["rust","jinja2","template-engine"]
published: true
---

# tl;dr

- [mitsuhiko/minijinja: MiniJinja is a powerful but minimal dependency template engine for Rust compatible with Jinja/Jinja2](https://github.com/mitsuhiko/minijinja)
- 1バイナリで jinja2 互換のテンプレートエンジンを探していた
- 更新頻度の低いものを避けた
- 性能や機能の比較はできていないので、他にいいものがあったら教えて欲しい

# テンプレートエンジンを探す旅

- 仕事用に軽量、簡潔なテンプレートエンジンとして、[{{ mustache }}](https://mustache.github.io/) の [bash版](https://github.com/tests-always-included/mo) を使っていた
- 言語に依存しないツールを選定することにしている（仕事によって言語は変わるし依存したくない）
- ので、bash 実装はチームで利用するには楽だった（インストールしたら教えることがほとんどない）
- それでも複数の言語やツールで採用されている、言わばデファクトなテンプレートを選定したい欲求
- mustache はロジックが書けない（書かない）ので、そろそろ変更したい
- テンプレートエンジン界隈では jinja2 が望ましいと思っている
- 1バイナリで簡単にインストールできるなら他のツールでもよいのではないか

# 気にしたこと

- バージョン差異やインストールの手間が嫌なので、言語環境に依存するツールは不可（LL使用不可）
- できるだけ docker は不可（dockerでやればなんでもいいじゃんを避けたい）
- 今年（2024年）に入って更新されていないツールは不可
- GitHub でのスター数が 1k 以下は不可
- jinja2 互換であること
- CLI がラッパー等でも提供されていること（自作不可）
- 実行環境を選ばないこと（Linux, Mac, できればWindowsも含めて同じように使えること）
- ここまでで概ね Rust か GO で書かれているものに限定される

# GitHub で検索

- [こんな感じ](https://github.com/search?q=template+engine+jinja2+stars%3A%3C10000+pushed%3A%3E2024-01-01&type=Repositories&ref=advsearch&l=&l=&s=stars&o=desc)
- [mitsuhiko/minijinja](https://github.com/mitsuhiko/minijinja) が良さそうに見えた
- 去年更新されているやつまで見るとだいぶ増えるんだけど、更新頻度が低いリポジトリは信頼性に疑問が残るので除外
- [flosch/pongo2: Django-syntax like template-engine for Go](https://github.com/flosch/pongo2) が Go では良さそうに見えるけど更新されてないので除外

# minijinja

- [minijinja-cli](https://github.com/mitsuhiko/minijinja/tree/main/minijinja-cli)
- aqua でインストールできたら楽だったけどまあいいや
- examples にあるコードで十分テスト可

```bash
# インストール（cargo使ってもいい。チームに展開する時に rust の準備しているとは限らないので。）
curl -sSfL https://github.com/mitsuhiko/minijinja/releases/latest/download/minijinja-cli-installer.sh | sh
```

# まとめ

- 技術選定の話のひとつ
- フロントやバックエンドな方々は使用している言語で使えるエンジンを選べばいいと思うよ
- til のテンプレートを新しくしたら別途記事にする予定
- 他にいいテンプレートエンジンがあったら教えてください
