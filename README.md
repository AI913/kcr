# Job Order App for iOS
> This app can tell a robot what to do, just like to tell a person what to do.

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
[![Bitrise][bitrise]][bitrise-url]

## Overview
ロボットの作業内容を定義し、ロボットに対して指示することができるアプリ。  
京セラロボティクスでは従来の複雑なティーチング手法と比べ、ロボットにAIを用いて自律化することでより簡単で抽象的な指示ができる。このアプリは抽象的な指示を行うためのインターフェースとしての役割を持つ。

### Features
- [x] ダッシュボード - ロボットの稼働状況表示
- [x] ロボット一覧 & 状態表示
- [x] ジョブ（作業定義）の作成・管理
- [x] タスク（作業指示）の作成・管理
- [x] ユニバーサルアプリ（iPhone & iPad）

### Requisites
- iOS 13.2+

## Getting Started with Development

### Prerequisites
- Xcode 12.0.1

### Set up the environment
最初の一度だけ行う必要がある操作。  
ビルドに必要なツールやライブラリ等をMacにインストールする。

#### 1. Clone the project
[Gitリポジトリ](https://gitlab.com/kc_develop/app/prod-1/app/job-order-app/repo-ios.git)をクローン。

#### 2. Setting up a development environment
```
$ cd {クローン先のディレクトリ}/JobOrder
$ make config
```

### Installing
レポジトリをクローンした後に必ず行なう操作。  
ビルドに必要なライブラリをセットアップする。
```
$ cd {クローン先のディレクトリ}/JobOrder
$ make setup
```

### Running the tests

#### Local testing
ターミナルで下記コマンドを実行する。
```bash
$ cd {クローン先のディレクトリ}/JobOrder
$ make test
```

##### How to check the test results
クローン先のディレクトリ > JobOrder > build > output > ResultBundle.xcresult  
テスト結果としては`✗`がないことを確認する。

#### CI testing
GitLab へのイベントをきっかけに、Bitriseで自動的に行われる。

##### Trigger to the testing
- 開発ブランチからstagingブランチへマージリクエスト
- stagingブランチから開発ブランチへマージリクエスト
- stagingブランチからmasterブランチへマージリクエスト

##### How to check the test environment
[Bitrise](https://app.bitrise.io/dashboard/builds) > APPS欄の repo-ios > workflow > Stack

##### How to check the test results
[Bitrise](https://app.bitrise.io/dashboard/builds) > 対象のビルドを選択 > APPS & ARTIFACTSタブを選択 > xcresult.zipを解凍し中身を確認

##### Bitrise user registration
@yu-kyocera へ登録依頼をする

## Deployment
T.B.D

## Document

##### How to create documents
ターミナルで下記コマンドを実行する。
```bash
$ cd {クローン先のディレクトリ}/JobOrder
$ make generate-documents
```

##### How to check the documents
クローン先のディレクトリ > JobOrder > docs > 確認したいモジュール > index.html

## License
このプロダクトはプロプライエタリ・ソフトウェアです。  
詳細は [LICENSE.md](LICENSE.md) をご覧ください。

[swift-image]: https://img.shields.io/badge/swift-5.1-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/license-proprietary-black.svg?style=flat-square
[license-url]: LICENSE.md
[bitrise]: https://app.bitrise.io/app/4f5f745c2b821581/status.svg?token=vE5gnH7WsKK2vd1oW_QCcg&branch=master
[bitrise-url]: https://app.bitrise.io/app/4f5f745c2b821581#
