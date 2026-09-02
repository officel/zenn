---
title: "ローカルブランチレス運用 2026"
emoji: "🎁"
type: "tech" # tech or idea
topics: ["git", "github"]
published: true # 公開前に true に直す
---

# tl;dr

- git 自体はある程度使える新メンバーにデタッチ運用を説明することになった
- 過去にブログも書いてるけど散らばってるし古くなってるしってことで新しくした
- もちろん AI をフル活用しつつちょっとだけ手で書いた

# 「detached HEAD」とエイリアスによるローカルブランチレスGit開発手順

- git に慣れたらローカルにブランチを切らなくても運用できる
- checkout は古いから switch を、みたいなのは放置。むしろ pull と switch が不要（branch もめったに使わない）
- 常にデタッチして運用することでより git への理解が深まる（というか必要不可欠になる）

:::message
本記事では、ローカルブランチを作成せず、`detached HEAD` とエイリアスを組み合わせて行うGitの開発手順を解説します。
（そういえば zenn って相変わらず青いインフォメーション出せないんだね）
:::

# ローカルディレクトリ構成

- 以前 [git リポジトリの命名規則とディレクトリ構成](https://zenn.dev/raki/articles/2024-09-24_directory_for_repos) を書いた
- ほぼ変わっていないので詳細は省略

```text
repos/                      # すべてのリポジトリをまとめるルート
├── dev.azure.com           # ホスティングサービス別に分ける
└── github.com
    ├── ORG_NAME            # 組織やチームアカウント
    └── PERSONAL_USER       # 個人アカウント
        ├── my-examples-go  # プライベートな勉強用
        ├── my-private      # その他プライベート用
        └── public-repo     # パブリックなリポジトリは適切な命名を
```

- **メリット**: リポジトリの散逸を防ぎ、一括バックアップやワークスペースの管理を容易にする
- **命名規則**: プライベートリポジトリには `my-`、動作検証用には `examples-` などの一貫したプレフィックスをつける
- GitHub EMU: GitHub EMU などを使用している場合、`github.xxx` のように別ディレクトリにしておくと ssh 設定等も楽（個人用と会社用のアカウントを分けて管理する際にシームレスにできる）

# エイリアスの設定

- 有名どころ [GitAlias/gitalias: Git alias commands for faster easier version control](https://github.com/GitAlias/gitalias)
- 使わない alias には意味がないので、自分で育てましょう
- 他人の dotfiles リポジトリの [git/config](https://github.com/officel/dotfiles/blob/main/git/config) や [bash_aliases](https://github.com/officel/dotfiles/blob/main/bash/bash_aliases) を参考にして勉強するとよい

## Git alias 設定

```ini
[alias]
# グラフによるログ表示
plog = log --pretty=format:'%C(yellow)%h %C(green)%cd %C(reset)%s %C(red)%d %C(cyan)[%an]' --date=format-local:'%t%Y-%m-%d %H:%M' --all --graph

# 簡易チェックアウト
co = checkout

# 現在の HEAD から直接リモートブランチとしてPushする
pr = "!git push origin HEAD:refs/heads/$1 #"
```

- `~/.git/config` あたりに書く
- `git plog`: 履歴ツリーを視覚的に把握するためのログ表示。

## シェルエイリアスの設定（Bash Alias）

```bash
alias aliasg='alias | grep git'
alias cr='cd "$(git rev-parse --show-toplevel)"'
alias g='git'
alias ga='git add'
alias gau='git add -u'
alias gb='git branch'
alias gcv='git commit -v'
alias gdc='git diff --cached'
alias gdi='git diff'
alias gfo='git branch --all --sort=-refname | grep -v -e HEAD | fzf | xargs git checkout '
alias gp='git plog -10'
alias gpr='git pr'
alias gr='git fetch --prune --all && git checkout origin/HEAD && git plog --all -10 && git status'
alias gst='git status --short --branch'
```

- **`aliasg` (Alias Grep)**: 現在設定されているエイリアスのうち、Gitに関連するものを絞り込んで一覧表示します。数多くのエイリアスを設定して名前やコマンドを忘れてしまった場合でも、一瞬で検索・確認できるため、エイリアス運用の利便性が向上します。
- **`cr` (Cd Root)**: Gitリポジトリの最上位ディレクトリに直接移動します。
- **`gfo` (Git Fuzzy Checkout)**: `fzf` を用いて、リモートを含めた全ブランチからあいまい検索し、選択したブランチの最新コミットを detached HEAD でチェックアウトします。他者のPRレビューや動作検証の際に手元を汚さず移動できます。
- **`gpr <branch_name>` (Git Push Remote)**: 現在浮いているHEAD（コミット）から、リモートに対して直接指定のブランチ名でPushします。ローカルブランチを介さずに、HEADから直接PR用のブランチを送信できます。
- **`gr` (Git Reset/Refresh)**: リモートの最新情報を取得し、デフォルトリモートブランチ（通常は `origin/main`）の最新コミットを detached HEAD 状態としてチェックアウトします。作業開始時に実行して手元を最新状態にします。
- 他のシェルでも大差ないはず。PowerShell の場合は `Set-Alias`
- 小ネタ的にはソートして記録しておくとわかりやすいのと、`aliasg` のような設定のために alias コマンド中ではコマンドを省略しないで書くと便利

# 一連の流れ

- 以前 [git の HEAD がわかるとローカルブランチはなくてもどうにでもできる話](https://zenn.dev/raki/articles/2024-08-03_git_head) を書いた
- 思ったより不評だった？のと、内容がちょっと古くなったので今回新しくしたってワケ

## 検証環境（ローカルでの遊び場）の用意

```bash
# どこでもいいので後でごっそり削除できるディレクトリを用意
mkdir -p ~/git-sandbox && cd ~/git-sandbox

# ベアリポジトリを作成（GitHub上のリポジトリもコレと同じようなもの）
g init --bare remote-repo.git

# もちろん clone する（git@やhttpsでやるのと同じ）
g clone remote-repo.git local-work

# ベアリポジトリの中を勉強するのはまた今度
cd local-work
```

## 最初のコミット

```bash
echo "Hello Git" > README.md
ga README.md
gcv -m "feat: 1st commit"
gpr main
gp
```

## `origin/HEAD` の設定とローカルブランチの削除

```bash
# origin/HEAD に origin/main を紐付ける
git remote set-head origin main

# 最新状態を取得し、detached HEADに移行
gr

# 不要になったローカルの main ブランチを削除
gb -d main
```

:::message
これで detached HEAD になりました。コマンドの都度 `gp` でログを見てみるとわかりやすいかもしれません
:::

## 基本的な開発サイクル

```bash
# 最新状態の取得（作業開始時や何かを始める時に使うクセをつける）
gr

# なんらかの作業
echo "Implementing feature..." >> README.md
gau
gcv -m "feat: implement cool feature"

# ブランチを push（ローカルにブランチは作成されないが、リモートにはこの名前でブランチができる）
gpr feat/my-cool-feature

# 任意：必要に応じてリポジトリのルートに戻る
cr

# 最初に戻る
gr
```

- git pull -> git switch -c feat/xxx -> git add -> git commit -> git push より断然スマート
- エイリアスの組み合わせに過ぎないので、デタッチさせる理由はスマートさだけではないところにある
- スカッシュ運用をしていると、ローカルブランチの削除が手間（grするだけで解決）
- 他人の作業を確認しにくい（チームメンバーの分も含めてチェック可能）
- git は分散型なんですわ

## 複数コミットと Squash Merge

```bash
# 複数コミットしてみる
echo "Part 1" >> README.md
gau && gcv -m "feat: part 1"

echo "Part 2" >> README.md
gau && gcv -m "feat: part 2"

gpr feat/multi-commits

# PR を作ったテイで最初に戻る
gr

# Squashマージを実行（差分のみを作業ツリーに反映）
git merge --squash origin/feat/multi-commits

# 1つのコミットにまとめて作成
gcv -m "feat: completed feature with multi-commits (Squash)"

# mainにPush
gpr main

# gr した後で gdi でコミット間の差分を確認してみる
gdi
```

# トラブルシューティング

## ブランチ名を間違えた

```bash
# 間違ったブランチ名で push した
gpr wrong-name

# 慌てず騒がずリモートブランチを削除
g push origin :wrong-name

# 正しい名前で再 Push
gpr feat/correct-name
```

## コミットハッシュを見失った

```bash
g reflog
g co <コミットハッシュ>
```

# まとめ

- `gb -d main` しても問題ない（どうしても戻りたいなら `g switch main` で元通り）
- エイリアスを組み合わせて短いタイプ数でさくさく進める
- `gr` エイリアスで常にリポジトリの更新を拾っておくと他の人の作業の様子がわかる
- ローカルブランチを作らないことのメリットは、正直どうでもいいものばかりなので好みでどうぞ

# あわせて読みたい

@[card](https://zenn.dev/raki/articles/2024-08-03_git_head)

@[card](https://zenn.dev/raki/articles/2024-06-15_git_infrequency)

@[card](https://zenn.dev/raki/articles/2024-05-17_this_week_article)
