# PHP A

本リポジトリは aws の CodeBuild を使用し、  
他リポジトリの内容を composer で取得しながらビルドをするサンプルです

[PHP B](https://github.com/opst-ezaki/php-b) と共同で使用することを想定しています。

## 操作手順

こちらでは PHP A のイメージを作成する手順までの解説を記載しています。

PHP A と PHP B の連携は [PHP B](https://github.com/opst-ezaki/php-b) の readme を参照してください。

1. [ECS](https://ap-northeast-1.console.aws.amazon.com/ecs/home?region=ap-northeast-1#/repositories) の左メニュー `リポジトリ` から
    - `リポジトリの作成` ボタンクリック
    - リポジトリ名 `php-a` 入力
    - `次のステップ` ボタンクリック
    - `完了` ボタンクリック
  と進むみ、リポジトリを作成する。
  ページ上部に表示される `リポジトリの URI` の値をコピーしておく（後ほど使用する）

1. [CodeBuild](https://ap-northeast-1.console.aws.amazon.com/codebuild/home?region=ap-northeast-1#/projects) のページから`プロジェクトの作成` ボタンクリックし作成スタート

1. 設定画面にて
    - プロジェクトの設定
        - プロジェクト名: `php-a`
        - 説明: なし
    - ソース：ビルドの対象
        - プロバイダ: `Github`
        - リポジトリ: `パブリックのリポジトリの使用`
        - リポジトリの URL : `https://github.com/opst-ezaki/php-a`
        - Webhook: オフ
    - 環境：ビルド方法
        - 環境イメージ: `AWS CodeBuild によって管理されたイメージの使用`
        - オペレーティングシステム: `Ubuntu`
        - ランタイム: `Docker`
        - バージョン: `aws/codebuild/docker:1.12.1`
        - ビルド仕様: `ソースコードのルートディレクトリの buildspec.yml` を使用
        - buildspec 名: buildspec.yml (変更なし)
    - アーティファクト: 子のビルドプレジェクトからアーティファクトを配置する場所
        - タイプ: `アーティファクトなし`
    - サービスロール
        - `アカウントでサービスロールを作成`
        - ロール名: `codebuild-php-a-service-role`
    - 詳細設定
        - 環境変数: 名前: `REPO_URI`, 値: `{ECS で作成したリポジトリの URI}`, タイプ: `プレーンテキスト`
    以上を設定し、 `続行` -> `保存` をクリック
1. [IAM](https://console.aws.amazon.com/iam/home?region=ap-northeast-1#/roles) 画面を開き、
    - 左側メニューより `ロール` を選択
    - 一覧より `codebuild-php-a-service-role` を選択
    - アタッチされているポリシー `CodeBuildPolicy-php-a-{number}` を選択
    - `ポリシーの編集` を選択
    - 以下の内容をポリシーへ追加
        ```
                {
                    "Action": [
                        "ecr:BatchCheckLayerAvailability",
                        "ecr:CompleteLayerUpload",
                        "ecr:GetAuthorizationToken",
                        "ecr:InitiateLayerUpload",
                        "ecr:PutImage",
                        "ecr:UploadLayerPart"
                    ],
                    "Resource": "*",
                    "Effect": "Allow"
                }
        ```
    - `ポリシーの検証` をクリックし、 `このポリシーは有効です。` と表示されることを確認
    - `保存` をクリック

1. [CodeBuild の php-a プロジェクト](https://ap-northeast-1.console.aws.amazon.com/codebuild/home?region=ap-northeast-1#/projects/php-a/view)へ移動し、 `ビルド履歴` から `ビルドの開始` -> `ビルドの開始` をクリック

1. ビルドが正常に終了し、[ECS のリポジトリ php-a](https://ap-northeast-1.console.aws.amazon.com/ecs/home?region=ap-northeast-1#/repositories/php-a#images;tagStatus=ALL) に作成されたイメージが追加されていることを確認する

以降は [PHP B](https://github.com/opst-ezaki/php-b) の readme に従って操作してください。