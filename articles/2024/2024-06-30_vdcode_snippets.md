---
title: "VS Code で今日の日付を入れるコードスニペットとおまけのサイコロ"
emoji: "🎲"
type: "tech"  # tech or idea
topics: ["vscode"]
published: true
---

# tl;dr

- VS Code で今日の日付をしゅっと入力したくなった（そんなに高頻度ではない）
- 機能拡張がいろいろあるが、多機能は必要ないのでコードスニペットで処理することにした（今後他の要件でも使うだろうし）
- ついでなので簡単にサイコロを振れるようにした

# 機能拡張

日本語ではこれが有名？

@[card](https://marketplace.visualstudio.com/items?itemName=jsynowiec.vscode-insertdatestring)

date で検索しても大差ないか

@[card](https://marketplace.visualstudio.com/search?term=date&target=VSCode&category=Snippets&sortBy=Relevance)

ぶっちゃけ自分でコードスニペットを管理すれば済むのを機能拡張に委ねるのはちょっと。。。

# コードスニペット

- ファイル － ユーザー設定 － ユーザースニペットの構成
- またはコマンドパレット `ctrl + shift + p` から
- 管理の好みが割れると思うけど、個人用と業務用（仕事先別）でワークスペースを分離しているので、スニペットもワークスペース単位にしている

## 今日の日付

- `date -I` は ISO 8601 形式でデフォルトは date only（YYYY-MM-DD）で、その他の形式に比べて誤解が少ないため一番使用している（からそういう名前にした）
- エディターでの入力中に自動でサジェストされるか、`ctrl + space` でサジェストさせるかすれば動作する
- 末尾に半角スペースをいれていて、変換後に煩わしくないようにしている（trail space は別で実行しているのでとくに問題ない）
- 日付の後ろにスペースを入れないケースって曜日や他の日付形式の時だけだと思うのでそれ用のスニペットを書けば問題ないはず

```:personal.code-snippets
{
    "date -I": {
        "prefix": ["date", "today", "今日"],
        "body": ["$CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE "],
        "description": "date -I"
    }
}
```

## サイコロを振らせてみる

- 日付入れるだけとか面白くないのでサイコロでも振らせてみようかなと
- 外部プログラム呼び出しは邪道（呼べない環境では使えないからね）
- 別解お待ちしています

```:personal.code-snippets
{
	"dice": {
        "prefix": ["die", "dice", "random", "サイコロ"],
        "body": ["${RANDOM/.*([1-6]{1}).*/${1:-🎲}/} "],
        "description": "roll a die."
        // ランダム数字列から1-6があれば1つだけ抽出。なければサイコロの絵文字を表示する
        // $RANDOMは6桁のランダムな数字なので、000000や777777以上の数の場合は（サイコロとして）不適切なのでエラー代わりの絵文字ということ
        // 英語だと単一のサイコロは die（名詞）で2つ以上は dice らしいんだけど、日本人的には dice って書きたいよね。die（死）って縁起悪いし
    }
}
```

# まとめ

- 機能拡張は便利だけど、必要ないものまで機能拡張に頼るのはいまいち
- コードスニペット（code snippets）が必要になるような定型作業はあんまり持ってないんだけど、いざって時に使えるように準備
- 使いこなしを確認するためにも、おまけで何かを書いてみるのは大事
- 小ネタだしキーボードショートカットは設定しなかった。Trigger Suggest または IntelliSense で十分（ちなみにキーボードショートカットのPDFは Trigger Suggest だね）
- 他に何か変わり種のスニペットがあったら教えてください
