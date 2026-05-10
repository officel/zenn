---
title: "Deep Research で terraform_jp の記事を分析してみた"
emoji: "📰"
type: "tech"
topics: ["terraform", "gemini", "deep research", "ai"]
published: true
publication_name: "terraform_jp"
---

# tl;dr

- 誤解を恐れずにいうと、自分に関係が薄い再現性のないブログ記事っておもしろくないよね
- 自分でも同じようなことをやってみて、自分で再利用できるネタはおもしろいよね（NoteあたりのAI記事のプロンプト類とかね）
- terraform の話題もマンネリ気味だし、記事を書く issue もたまってるし（このブログは GitHub で管理していて、月に2回記事を書くべしって issue を作成するワークフローを定期実行している）ちょっと遊んでみようかな、と思ったってワケ

# ディープリサーチがどのくらい使えるのか、または使えないのか

- AI 無課金勢でも Deep Research を使える [Google Gemini](https://gemini.google.com/app?hl=ja) さん
- terraform-jp を 2019 年に slack に立ち上げて早7年
- zenn のパブリケーションに登録したのが 2024 年
- 全然オフライン活動してないし、名前だけって感じだけれども
- 何をしてきたか、を調べてもらうってのはおもしろそうだなって
- というわけでやってもらうことにした

> https://zenn.dev/p/terraform_jp は terraform に関する日本語話者のためのコミュニティのブログ記事のリストです。
> 特にユーザー raki が書いている記事について読み込み、内容について整理してください。
> 不足している情報、改善提案などを多めにお願いします。

で、出力されたのが以下ってわけ。

:::details Gemini にディープリサーチしてもらった結果

# 日本のTerraformコミュニティにおける自動化プラクティスの進化：ユーザーrakiによる知見と現代的IaCライフサイクル管理の深化

日本のTerraformユーザーコミュニティであるterraform-jp、特にZenn上のPublication（terraform-jp）において共有されている知見は、国内のインフラストラクチャ・アズ・コード（IaC）の実践レベルを底上げする重要なリソースとなっている。
その中でも、ユーザーrakiによる一連の記事は、単なるツールの紹介に留まらず、開発者体験（Developer Experience, DX）の向上、組織的なガバナンスの構築、そしてツール選定における一貫した設計思想を提示している。
本レポートでは、rakiが発信している技術情報の詳細な整理を行い、現代のTerraformエコシステムにおける自動化の潮流を分析した上で、不足している技術要素や、更なる改善に向けた戦略的な提案を網羅的に論じる。

## 日本のTerraformエコシステムとrakiによる技術的貢献の概況

terraform-jpは、日本語話者のエンジニアがTerraformに関する知見を交換するためのプラットフォームであり、SlackやGitHub、各種ソーシャルメディアと連携して活動を展開している 1。
このコミュニティにおいてrakiは、主にTerraformの周辺ツールを用いたCI/CDパイプラインの構築や、リポジトリの運用保守、そして新興ツールへの移行戦略について、実戦的な知見を提供している。
特に「これから始める」シリーズや、特定の課題解決にフォーカスした技術メモは、初学者から中級者までの幅広い層に影響を与えている 2。

rakiの投稿内容の核心にあるのは、インフラ管理における「継続的な品質向上」と「負債の蓄積防止」である。インフラのコード化が進むにつれ、モジュール間の依存関係や、プロバイダーのバージョンアップ、セキュリティ設定の不備といった課題が顕在化する。これらに対して、コミット前の検証（pre-commit）や自動ドキュメント生成、静的解析を組み合わせることで、人間によるレビュー負荷を軽減し、機械的に品質を担保する仕組みを提唱している 2。

## シフトレフト検証フレームワークの構築と最適化

インフラ開発における「シフトレフト」の概念は、rakiの記事において最も頻繁に扱われるテーマの一つである。開発プロセスの初期段階でエラーや脆弱性を検出することは、後の段階で修正を行うよりも圧倒的にコストが低い。rakiは、この目的のために pre-commit-terraform およびその後継・代替ツールとしての prek を中心としたワークフローを構築している。

### pre-commit-terraformの導入と実運用上の課題解決

pre-commit-terraform は、gitのフックを利用してコードのフォーマット、バリデーション、ドキュメント生成、セキュリティスキャンを自動実行するツール群である 2。
rakiは、terraform_fmt、terraform_validate、terraform_trivy、terraform_tflint、terraform_docs といった主要なフックを統合した設定を推奨している。

特に重要な知見として、HCP Terraform（旧Terraform Cloud）のプライベートレジストリを利用している環境でのバリデーション問題が挙げられる 2。
通常、ローカル環境やCI環境で terraform validate を実行する際、プライベートモジュールの参照を解決するためには適切な認証が必要となる。
rakiは、HCP Terraformの組織設定から「Team Token」を発行し、GitHub Actions等のCIツールに HCP_TF_API_TOKEN として設定することで、この認証の壁を突破する方法を具体的に示している 2。

この認証情報の管理において、rakiが提案するトークンの選択基準は、組織的な運用の観点から非常に合理的である。HCP Terraformには複数のトークン種別が存在するが、それらを整理したものが以下の表である。

| トークン種別 | 権限範囲 | CI/CDにおける推奨理由 |
| :---- | :---- | :---- |
| User Token | ユーザー個人に紐づく | 非推奨。個人の離職や権限変更に影響される 2 |
| Team Token | 特定のチームに付与 | 推奨。役割に基づいた権限管理が可能で、安定性が高い 2 |
| Organization Token | 組織全体 | 管理者権限を伴うため、バリデーション目的には過剰 2 |
| Workspace Token | 特定のワークスペース | 最小権限の原則には適するが、複数プロジェクトを横断するCIには不向き |

### 次世代ツールprekへの移行とADR

rakiは、従来のPythonベースの pre-commit フレームワークから、Rust製で依存ゼロの設計を持つ prek への移行についても、Architectural Decision Record (ADR) の形式でその合理性を説明している 3。この選択は、単なるパフォーマンスの追求ではなく、rakiがツール選定において重視する「Unix哲学（一つのことをうまくやる）」や「シングルバイナリによる導入の容易さ」に基づいている。

prek の利点は、Python等のランタイムを必要とせず、単一のバイナリで動作するため、ローカル環境やCI環境でのセットアップ時間が大幅に短縮される点にある 3。また、既存の .pre-commit-config.yaml と互換性を維持しているため、移行コストが低いことも強調されている。これは、大規模なモノレポ運用やマルチワークスペース環境において、イテレーションロスを削減するための戦略的な選択と言える 3。

## CI/CDパイプラインの高度化とオートメーション

rakiの知見はローカル環境に留まらず、GitHub Actionsを用いたCI/CDの自動化においても詳細に記述されている。特に、複数のツール（tflint, terraform-docs, Trivy等）を組み合わせる際のバージョン管理や、効率的な実行順序について、具体的な実装例が示されている 2。

### GitHub Actionsにおけるツールチェーン構成

GitHub Actionsのワークフロー定義において、rakiは ubuntu-latest イメージをベースにしつつ、各ツールのセットアップアクションを適切に配置している。例えば、hashicorp/setup-terraform@v3 を用いてTerraform CLIを構成し、terraform-linters/setup-tflint@v6 で静的解析環境を整えるといった手順である 2。

特筆すべきは、ツールのバージョン指定に対する厳格な姿勢である。rakiの記事では、以下のツールバージョンが具体的に言及されており、これらを固定することでCIの決定論的な動作を担保している。

| 構成要素 | 言及されているバージョン/アクション |
| :---- | :---- |
| Python Runtime | 3.14 2 |
| setup-terraform | v3 2 |
| setup-tflint | v6 2 |
| terraform-docs | v0.21.0 2 |
| Trivy | v0.69.3 2 |
| pre-commit-terraform | v1.105.0 2 |

このような詳細なバージョン指定は、将来的な破壊的変更からパイプラインを守るだけでなく、チーム全体で一貫した開発環境を共有するために不可欠な要素である。

### Dependabotによる自動保守

rakiは、リポジトリの継続的なメンテナンスの重要性についても言及しており、特にDependabotを活用した自動アップデートを推奨している 4。
Terraformプロバイダーや各種GitHub Actionsのバージョンアップは頻繁に行われるため、これを手動で追随することは現実的ではない。
Dependabotの設定を適切に行うことで、常に最新のセキュリティ修正や機能強化を享受できる体制を整えることができる。

## 個別ツールの深掘りとガバナンスへの影響

rakiが紹介している各ツールは、それぞれがTerraform運用における特定の「痛み」を解消する役割を担っている。これらを体系的に整理することで、包括的なIaCガバナンスの全体像が見えてくる。

### tflintによる静的解析の深化

tflint は、Terraform標準のバリデーションでは検知できない、プロバイダー固有の誤設定や非推奨の属性を指摘するツールである。
rakiは「これから始めるtflint」という記事を通じて、その導入ハードルを下げている 2。
tflint の設定ファイルである .tflint.hcl をリポジトリのルートに配置し、CI上で `__GIT_WORKING_DIR__` 変数を用いてパスを指定する手法は、複雑なディレクトリ構造を持つリポジトリにおいても確実にバリデーションを実行するための優れたテクニックである 2。

### TrivyによるIaCセキュリティの統合

セキュリティスキャンツールとしての Trivy の活用も、rakiのワークフローにおける重要な柱である 2。かつてはコンテナイメージのスキャンが主用途であった Trivy は、現在ではTerraformコードの脆弱性診断においても業界標準の一つとなっている。S3バケットの公開設定や、暗号化の欠如、過剰な権限付与といった設定ミスをコミット前に検出することで、インフラ起因のセキュリティ事故を未然に防ぐことが可能になる。

### terraform-docsによる情報の同期

「ドキュメントの形骸化」は多くのプロジェクトが直面する課題である。rakiは terraform-docs を導入し、Terraformのソースコード（variables.tfやoutputs.tf）から自動的にMarkdown形式のREADMEを生成する仕組みを構築している 2。これにより、コードの変更とドキュメントの更新が常にセットで強制されるため、プライベートレジストリ等でモジュールを共有する際の信頼性が飛躍的に向上する。

## Terraform Coreの進化と未活用の新機能に対する洞察

rakiの提供する知見は、2025年から2026年にかけてのTerraform運用において非常に高い完成度を誇っている。しかし、HashiCorpが提供するTerraform Coreの最新バージョン（v1.14およびv1.15）には、rakiがまだ詳細に解説していない、運用のパラダイムを大きく変えうる新機能が複数含まれている。これらの情報を補完し、rakiのワークフローに組み込む提案を行う。

### Terraform 1.14 Actionsによる運用の拡張

Terraform 1.14で導入された「Actions」は、従来のCRUD（作成・読み取り・更新・削除）の枠組みを超えた操作を可能にする画期的な機能である 5。これまでは、CloudFrontのキャッシュ削除やLambda関数の手動実行といった「一度きりの操作」を行うには、local-exec や外部スクリプトを組み合わせる必要があり、これらは冪等性や状態管理の観点で脆さを持っていた。

新機能である action ブロックと action\_trigger を利用することで、これらの操作をTerraformの依存関係グラフの中に組み込み、terraform plan でその実行予定を確認できるようになる 5。rakiのワークフローにこの機能を統合することで、インフラのプロビジョニングと、その後の運用操作を同一の言語（HCL）とツールチェーンで完結させることが可能になる。

### Terraform 1.15におけるガバナンスの強化

2026年半ばにリリースされたTerraform 1.15では、大規模なモジュール開発を支える重要な機能が追加されている。

1. **Deprecated属性の正式採用**: variable および output ブロックにおいて deprecated 属性が使用可能になった 6。これは、モジュール開発者が古いインターフェースの使用に対して公式な警告を出すことを可能にする。rakiが懸念していた「モジュールのガラパゴス化」を防ぎ、計画的な廃止と移行を促すための強力な武器となる。
2. **動的なモジュールソースの利用**: const \= true を設定した変数を用いることで、モジュールの source や version を動的に切り替えることが可能になった 6。これにより、環境（Dev/Prod）ごとに異なるモジュールバージョンを注入するといった柔軟な構成が、より標準的な手法で実現できるようになる。
3. **型変換の厳密化（convert関数）**: 複雑なオブジェクトを特定の型に安全に変換する convert 関数が追加された 6。これにより、tflint等で検知する前の段階で、コード内での型安全性を高めることができる。

## 改善提案：さらなる高度化への戦略的ステップ

rakiが提唱する現在のフレームワークに対して、最新の技術動向とエンタープライズレベルの要求事項を考慮した、以下の5つの改善案を提示する。

### 提案1：ネイティブテストフレームワーク「terraform test」の統合

現在のrakiのワークフローは静的解析に重点を置いているが、Terraform 1.6以降で標準化された terraform test の活用を組み込むべきである。

* **理由**: 静的解析（tflint, Trivy）は「設定が正しいか」をチェックするが、terraform test は「意図した通りのリソースが構成されるか」というロジックの正当性を検証する 7。
* **具体的なアクション**: 1.15で強化されたモック機能（Mock Blocks）を活用し、実際のクラウド資源を作成せずにモジュールの条件分岐や動的ブロックの挙動をテストするコードを作成する 7。これを prek や GitHub Actions の一工程として追加することで、品質保証のレイヤーを一段階深めることができる。

### 提案2：HCP Terraform エフェメラルワークスペースの活用

HCP Terraform で導入されたエフェメラルワークスペース機能は、CI環境でのテストにおいて非常に有用である。

* **理由**: テスト用にプロビジョニングしたインフラを一定時間後に自動削除する設定が可能であり、リソースの消し忘れによるコスト増大を防ぐことができる 9。
* **具体的なアクション**: GitHub Actions で terraform test を実行する際、動的にワークスペースを作成し、テスト完了後に自動破棄される設定をコード化する。

### 提案3：Terraform Enterprise（TFE）移行への対応

組織で自己ホスト型の Terraform Enterprise を利用している場合、2025年から2026年にかけての大規模なアーキテクチャ変更への対応が必要である。

* **理由**: HashiCorpは、従来の Replicated ベースのデプロイ方式を2025年3月に終了し、2026年4月に完全なサポート終了（EOL）を迎えることを発表している 10。
* **具体的なアクション**: 現在 Replicated 方式で TFE を運用している場合、Nomad、Kubernetes (EKS, AKS, GKE)、または Podman への移行プランを策定する必要がある 12。特に内部データベース（PostgreSQL）のバージョンアップ（v14からv16）が必須となるため、これらのアップグレード手順をワークフローの保守項目に追加することを推奨する 11。

### 提案4：状態管理（State）の回復レジリエンス向上

rakiの記事では言及が少ないが、実務において最も困難な課題の一つは、状態ロックの不整合や状態ファイルの破損である。

* **理由**: S3バックエンドにおける DynamoDB ロックのDigest不整合等は、並行実行が多い環境で突発的に発生する 2。
* **具体的なアクション**: terraform state コマンドを用いた安全なロック解除手順や、状態ファイルのバックアップ・リストアの自動化手順を文書化し、緊急時のランブックとして整備する。また、AWSバックエンドにおける最新の認証方式（aws login等）への対応も検討すべきである 8。

### 提案5：コスト予測ツール「Infracost」の導入

IaCのCIパイプラインにおいて、セキュリティと品質に加えて「コスト」の可視化を統合することは、現代的なプラットフォームエンジニアリングの要件である。

* **理由**: インフラの変更が月額コストにどれほど影響するかをプルリクエストの段階で把握することで、予期せぬクラウド破産の回避や FinOps の推進が可能になる 13。
* **具体的なアクション**: pre-commit-terraform のフックとして infracost を追加し、コスト変動のサマリーをプルリクエストのコメントとして自動投稿するフローを構築する。

## 技術的整合性の検証と運用パラダイムの比較

rakiが選択した技術スタックの合理性を再確認するため、他の代替案との比較検証を行う。この比較は、今後のツール選定における基準点として機能する。

### バリデーションツールの比較分析

| ツール | 検証の深さ | 実行速度 | 主な利点 | 欠点 |
| :---- | :---- | :---- | :---- | :---- |
| terraform validate | 浅い（構文とスキーマ） | 高速 | 標準機能、依存ゼロ | ロジックの検証は不可 |
| tflint | 中程度（プロバイダー設定） | 高速 | クラウド固有のエラー検知 2 | プラグイン管理が必要 |
| Trivy / Checkov | 深い（セキュリティ） | 中速 | 脆弱性データベースとの連携 2 | 偽陽性が発生することがある |
| terraform test | 非常に深い（動作検証） | 低速 | 実際のプロビジョニングを模倣 8 | テストコードの記述コスト |

### 認証トークンの管理戦略

rakiが推奨する Team Token の活用をさらに発展させ、最小権限の原則（Least Privilege）を適用した場合の権限マトリクスは以下の通りである。

| 操作内容 | 必要なトークン/権限 | HCP Terraform 設定箇所 |
| :---- | :---- | :---- |
| CI上での validate | Team Token (Read-only) | Organization API Tokens 2 |
| CI上での plan | Workspace Token (Plan-only) | Workspace Settings |
| CD上での apply | Team Token (Manage Workspaces) | Team Access Controls |

## 結論：rakiの知見を土台とした次世代IaCの実践へ

ユーザーrakiが terraform-jp で共有している一連の知見は、日本のTerraformユーザーにとっての「標準的な北極星」として機能している。特に、prek を用いた高速なバリデーション環境や、HCP Terraform との認証連携、各種静的解析ツールの統合といった実践的なアプローチは、多くの現場で即戦力となるものである 2。

しかし、Terraformエコシステムの進化速度は極めて速く、2026年現在の最新機能である「Actions」や「Deprecated属性」、そしてTerraform Enterpriseのアーキテクチャ刷新といった変化を無視することはできない 5。

今後の展望として、rakiが構築した「シフトレフト検証」の強固な基盤の上に、terraform test による「動的な品質保証」と、Actionsによる「ライフサイクル全域の自動化」を積み重ねていくことが求められる。これにより、単にインフラをコード化するだけでなく、ビジネスの変化に対して安全かつ迅速に応答できる、真に「レジリエントなインフラストラクチャ」の実現が可能となる。

本レポートで提示した改善提案と、rakiによる卓越した既存の実践を組み合わせることで、開発者はインフラの複雑性から解放され、より本質的なアプリケーションの価値創造に集中できる環境を手にすることができる。rakiが重視する「Unix哲学」と「OSSへの貢献精神」を継承しつつ、技術の最新潮流を貪欲に取り入れる姿勢こそが、これからのインフラエンジニアに求められる最も重要な資質である。

---

# 補足：rakiの主要記事に関連する技術スタックと構成要素の要約

rakiの記事に基づき、推奨されるリポジトリ構成とツールチェーンを以下の表にまとめる。これは、新規プロジェクトの立ち上げや、既存環境の刷新におけるテンプレートとして利用可能である。

| カテゴリ | 推奨ツール/設定 | 役割・メリット |
| :---- | :---- | :---- |
| **Hook Manager** | prek (pre-commit互換) | シングルバイナリ、Rustによる高速実行 3 |
| **Linter** | tflint | プロバイダー固有の設定ミス検知 2 |
| **Security** | Trivy | IaCの脆弱性および設定不備のスキャン 2 |
| **Documentation** | terraform-docs | README.md の自動生成と同期 2 |
| **CI Platform** | GitHub Actions | ワークフローの自動化と一元管理 2 |
| **Credentials** | HCP\_TF\_API\_TOKEN | プライベートモジュールの認証解決 2 |
| **Package Manager** | aqua | ツール自体のバージョン管理と配布 3 |
| **Maintenance** | Dependabot | 依存関係の自動アップデート通知 4 |

これらの要素を統合的に運用することで、rakiが提唱する「負債を溜めない、洗練されたTerraformリポジトリ」の維持が現実的なものとなる。今後も terraform-jp におけるrakiをはじめとする先駆者たちの発信に注目し、コミュニティ全体で IaC のベストプラクティスを更新し続けていくことが期待される。

## 引用文献

1. terraform-jp | Zenn, 5月 10, 2026にアクセス、 [https://zenn.dev/p/terraform\_jp](https://zenn.dev/p/terraform_jp)
2. HCP Terraform と pre-commit-terraform \- Zenn, 5月 10, 2026にアクセス、 [https://zenn.dev/terraform\_jp/articles/2026-03-07\_terraform\_pre-commit](https://zenn.dev/terraform_jp/articles/2026-03-07_terraform_pre-commit)
3. prek を使ってみる ADR \- alternative pre-commit \- \- Zenn, 5月 10, 2026にアクセス、 [https://zenn.dev/raki/articles/2025-10-19\_prek\_alternative\_pre-commit](https://zenn.dev/raki/articles/2025-10-19_prek_alternative_pre-commit)
4. GitHub Actions と pre-commit-config を SHA pinning \- Zenn, 5月 10, 2026にアクセス、 [https://zenn.dev/raki/articles/2026-03-22\_repos\_cleanup](https://zenn.dev/raki/articles/2026-03-22_repos_cleanup)
5. Terraform Actions: Deep-Dive \- mattias.engineer, 5月 10, 2026にアクセス、 [https://mattias.engineer/blog/2025/terraform-actions-deep-dive/](https://mattias.engineer/blog/2025/terraform-actions-deep-dive/)
6. What's new in Terraform 1.15? \- Daniel Schmidt's Blog, 5月 10, 2026にアクセス、 [https://danielmschmidt.de/posts/2026-04-29-what-s-new-in-terraform-1-15](https://danielmschmidt.de/posts/2026-04-29-what-s-new-in-terraform-1-15)
7. Terraform 1.15 Alpha: Variable and Output Deprecation \- DEV Community, 5月 10, 2026にアクセス、 [https://dev.to/quixoticmonk/terraform-115-alpha-variable-and-output-deprecation-4dol](https://dev.to/quixoticmonk/terraform-115-alpha-variable-and-output-deprecation-4dol)
8. Releases · hashicorp/terraform \- GitHub, 5月 10, 2026にアクセス、 [https://github.com/hashicorp/terraform/releases](https://github.com/hashicorp/terraform/releases)
9. Terraform Documentation \- HashiCorp Developer, 5月 10, 2026にアクセス、 [https://developer.hashicorp.com/terraform/docs](https://developer.hashicorp.com/terraform/docs)
10. Terraform Enterprise v202405-1 (772) \- HashiCorp Developer, 5月 10, 2026にアクセス、 [https://developer.hashicorp.com/terraform/enterprise/releases/2024/v202405-1](https://developer.hashicorp.com/terraform/enterprise/releases/2024/v202405-1)
11. Terraform Enterprise v202406-1 (776) \- HashiCorp Developer, 5月 10, 2026にアクセス、 [https://developer.hashicorp.com/terraform/enterprise/releases/2024/v202406-1](https://developer.hashicorp.com/terraform/enterprise/releases/2024/v202406-1)
12. Terraform Enterprise Releases \- 2025 \- HashiCorp Developer, 5月 10, 2026にアクセス、 [https://developer.hashicorp.com/terraform/enterprise/releases/2025](https://developer.hashicorp.com/terraform/enterprise/releases/2025)
13. Terraform Best Practices: Writing Maintainable Infrastructure Code, 5月 10, 2026にアクセス、 [https://krausen.io/terraform-best-practices-writing-maintainable-infrastructure-code/](https://krausen.io/terraform-best-practices-writing-maintainable-infrastructure-code/)


:::

# 出力について

- pre-commit にひっかかってちょっと整えたけど、ほぼ原文ママ
- よいしょしすぎ感と、いくつか AI らしい文脈のおかしさはあるけど、素人まとめにしては上々かなって
- Gemini から普通にコピーするとベタなテキストになってしまうので、google ドキュメントにエクスポートしてからマークダウン形式でダウンロードした
- Gemini から [共有リンク](https://gemini.google.com/share/431491f8cfc9) を貼っても誰も見ないってゆうか、ちゃんと警告出ると思うんだけど、不用意に AI 共有のリンクを開いたらダメだぞ。何が埋まってるかわからないからね。

# まとめ

- 他人の AI で何かした、みたいな記事って（いろんな意味で）9割おもしろくない（と思ってる）
- 自分にとって再利用性の高い記事ならおもしろいんじゃないか、と思ってやってみた
- 個人的にはおもしろかったし学びもあったし、なにより記事がひとつ書けてよかったと思いますｗ
