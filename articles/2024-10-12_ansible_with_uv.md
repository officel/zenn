---
title: "Ansible を uv で管理する環境に移行した"
emoji: "🌞"
type: "tech"  # tech or idea
topics: ["uv","python","ansible"]
published: true
---

# tl;dr

- [astral-sh/uv](https://github.com/astral-sh/uv) で Python 自体を管理可能になったと聞いた
- rye を使いこなせなくて Python 環境が微妙になっていたので乗り換え
- Ansible を綺麗に移行できたのでメモ

# 細けえこたぁいいんだよ（AA略

```bash
cd my-examples-ansible
uv init -p 3.10
uv run hello.py
uv add requests
uv add boto3
uv add ansible
uv sync
source .venv/bin/activate
ansible --version
```

- uv のインストールは各自好きにどうぞ
- 個人的には [aqua](https://github.com/officel/config_aqua/pull/46) を使っている
- `uv init -p` で Python のバージョンを好きにできる（3.12 等は他で遊んだので今回は 3.10 を指定。3.10.15がインストールされた）
- `uv tool` でインストールしてもいけるっぽい（ユーザワイドにインストールされるっぽい）けど、環境用の `pyproject.toml` に記録が残らないのでディレクトリローカルに入れた

# いろいろメモ

## rye を先にアンインストール

```bash
$ rye self uninstall
$ rm -rf ~/.rye
# .bashrc 等から grep して関連する環境変数等を削除
# aqua でインストールしていたので削除
$ aqua rm -m pl rye
```

## 実はよくわかってない（ちゃんと調べてない）

- uv add と tool の違い
- python のランタイムの違い
- python のバージョン差もあんまりよくわかってない
- `pyproject.toml` だけを別ディレクトリにコピーして `uv sync` すると python のバージョンはデフォルトで指定してるものになるっぽい
- `.python-version` を置いて `uv sync` すると指定のバージョンになる
- おもしろいし便利だけど、どこに置いてどうなってるのか見えてなくて不安

# あとがき

- uv でやっと python の仮想環境がわかってきた（システムグローバル育ち。。。）
- rye の時に理解できていれば乗り換えまでは要らなかったの、か？
- uv 単独でできるならそれでいいか
- チームへの展開がまだ課題
- とりあえず動かすのはできているけど、実務のコードでのテストが不十分なので、どんどん使っていく必要がある
- まだ python の環境を用意していなくて、しゅっとやりたい人向けに書いた
