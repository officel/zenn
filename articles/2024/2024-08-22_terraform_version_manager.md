---
title: "terraform のバージョンマネージャー選び"
emoji: "📌"
type: "tech"
topics: ["terraform", "version manager"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- tfenv を長いこと使っていたけど、最近更新されていないことに気がついた
- 乗り換えるなら何にするか検討してみた

# version manager

- cli などのツールのバージョン管理は大事
- チームや組織で共通のバージョンを使うのは運用上必須
- 特定のバージョンへの変更、固定、最新化が容易であることが望ましい
- 現在進行系で継続的な更新が行われていてほしい

# terraform のバージョンマネージャー

- terraform に限って言えば、tfenv で今後もそんなには困らない
- OpenTofu の件があるので、両方に対応できるといいかもしれない
- CVEなどもあるので、継続的な更新は期待したい（お前がコントリビュートするんだよ）

## tfenv

- [tfutils/tfenv: Terraform version manager](https://github.com/tfutils/tfenv)
- かなり初期の頃からある
- rbenv にインスパイアされている（と書いてある）
- .terraform-version
- [Release v3.0.0 - Major Update · tfutils/tfenv](https://github.com/tfutils/tfenv/releases/tag/v3.0.0) 最新版から2年以上が経過
- ほぼ完成しているツールとはいえ、メンテナンスに不安があるツールを使い続けるのもどうか
- というわけで別のツールを探す旅に出たってワケ

## tofuenv

- [tofuutils/tofuenv: OpenTofu version manager](https://github.com/tofuutils/tofuenv)
- terraform の OSS fork である OpenTofu のバージョンマネージャー
- terraform と OpenTofu の両方が使える tenv ができたのでお役御免になったようだ？（アーカイブはされていない）
- terraform には対応していないので却下

## tenv

- [tofuutils/tenv: OpenTofu / Terraform / Terragrunt and Atmos version manager](https://github.com/tofuutils/tenv)
- terraform, OpenTofu, Terragrunt などが扱える
- 後発組のため、他のツールとの互換性も高い（.terraform-versionが使える）
- 更新頻度も高め？

## tfswitch

- [warrensbox/terraform-switcher: A command line tool to switch between different versions of terraform (install with homebrew and more)](https://github.com/warrensbox/terraform-switcher)
- 古参のツール
- terraform block を含む .tf ファイルを自動で読み込んでくれるので、きっちりバージョン管理をしているコードの場合に有利
- OpenTofu にも対応

## tfvm

- [cbuschka/tfvm: Terraform Version Manager - Always the right terraform version for your project](https://github.com/cbuschka/tfvm)
- 今回の中では一番規模が小さい
- Similar tools に同様のツールがリストされている
- 他もそうだけど、個人レベルのツールでは terraform と OpenTofu に対応するのは大変かと（tfvm は OpenTofu 対応を[していない](https://github.com/cbuschka/tfvm/issues/45)）

## 他に

- [Repository search results](https://github.com/search?q=terraform+version+manager&type=repositories&s=updated&o=desc)
- 規模の小さいのは結構ある
- terragrunt 向けのやつとか
- asdf のプラグインとか
- 結局のところ継続した更新を期待しているので

# 結局のところ

- 急いで変更する必要はない（はず）
- 変更の機会があったら tenv または tfswitch が有力候補
- どちらも `.terraform-version` が使えるので移行には困らないはず
- 後発でこれらを超えるツールを出して継続メンテナンスするのはモチベーションが保てない気がするし難しいよね
- 他にこれだってツールがあれば教えてください
