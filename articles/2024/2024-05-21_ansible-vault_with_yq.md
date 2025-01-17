---
title: "yq で ansible-vault の暗号化された文字列を復号すると楽だった"
emoji: "🔐"
type: "tech"
topics: ["ansible-vault","yq"]
published: true
---

# tl;dr

- ansible-vault で暗号化された文字列があって復号する必要があった
- echo とか tr とか面倒くさい
- yq を使うと楽だったのでメモ
- `yq '.password' secret.yml | ansible-vault decrypt`
- 個人的にはファイルで暗号化して欲しい

# 経緯

職場で、ansible の playbook が読み込んでいる古い role があって、 ansible-vault で暗号化された文字列を使っていた。
値を変更したいので確認してみると vars に登録してあって、個別の変数になっていた。

要はこういうやつ。
[Encrypting content with Ansible Vault — Ansible Community Documentation](https://docs.ansible.com/ansible/latest/vault_guide/vault_encrypting_content.html)

```yaml
the_secret: !vault |
      $ANSIBLE_VAULT;1.1;AES256
      62313365396662343061393464336163383764373764613633653634306231386433626436623361
      6134333665353966363534333632666535333761666131620a663537646436643839616531643561
      63396265333966386166373632626539326166353965363262633030333630313338646335303630
      3438626666666137650a353638643435666633633964366338633066623234616432373231333331
      6564
※リンクにあるサンプルのコピーです
```

# yq でやろう

コピーして echo して tr してってやってもいいんだけど、面倒くさい。
で、yq を使うことにした。
ちなみに、yq って無茶苦茶ググラビリティが悪いってゆうか、

pip で入る [kislyuk/yq: Command-line YAML, XML, TOML processor - jq wrapper for YAML/XML/TOML documents](https://github.com/kislyuk/yq)（brew では python-yq）

brew や aqua で入る [mikefarah/yq: yq is a portable command-line YAML, JSON, XML, CSV, TOML and properties processor](https://github.com/mikefarah/yq)（こっちが yq）

があって、どっちを使ってるかわからないと、ときどきはまるので注意する。今回の使い方だとどっちを使ってても同じだけど。

というわけで、secret.yml に入っている password という名前の暗号化された文字列をしゅっと復号。

```bash
yq '.password' secret.yml | ansible-vault decrypt
```

- `ANSIBLE_VAULT_PASSWORD_FILE` 環境変数でパスワードが登録してある（なければ対話形式で聞いてくるから問題ない）
- 他にもたくさん暗号化された文字列があって、同じファイルに入っている
- ひとつずつ復号するの面倒くさい（今回は1つしか対象にしてないので問題なかった）
- パスワード漏えいした時にローテさせるの本当に面倒くさいなって

# 雑記

- ansible-vault は口伝のパスワードで暗号化しておけて git 管理化におけるので便利
- ファイルごと暗号化したいお気持ち vs 個別暗号化の（俺の知らない）他のメリット？
- 他のシークレットマネージャーとの使い分けを考えたい
- みたいなことを考えてたんだけど、コメントで意見ください
