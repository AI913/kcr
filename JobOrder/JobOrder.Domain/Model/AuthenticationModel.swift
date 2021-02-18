//
//  AuthenticationModel.swift
//  JobOrder.Domain
//
//  Created by Kento Tatsumi on 2020/03/04.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import JobOrder_API

/// Authenticationモデル
public struct AuthenticationModel {

    /// Presentationへ出力するためのデータ形式
    public struct Output {

        /// 認証状態
        public enum AuthenticationState: CaseIterable {
            /// サインイン済
            case signedIn
            /// サインアウト済
            case signedOut
            /// サインアウト済 (フェデレーテッドトークンが無効)
            case signedOutFederatedTokensInvalid
            /// サインアウト済 (ユーザープールトークンが無効)
            case signedOutUserPoolsTokenInvalid
            /// 不明
            case unknown

            /// エンティティ -> モデル変換
            /// - Parameter state: エンティティ
            init(_ state: JobOrder_API.AuthenticationEntity.Output.AuthenticationState?) {
                switch state {
                case .signedIn: self = .signedIn
                case .signedOut: self = .signedOut
                case .signedOutFederatedTokensInvalid: self = .signedOutFederatedTokensInvalid
                case .signedOutUserPoolsTokenInvalid: self = .signedOutUserPoolsTokenInvalid
                default: self = .unknown
                }
            }
        }

        /// 生体認証
        public struct BiometricsAuthentication {
            /// 認証結果
            public let result: Bool
            public let errorDescription: String?
        }

        public struct InitializeServer {
            /// 初期化した結果
            public let result: Bool
        }

        /// サインイン
        public struct SignInResult {
            /// サインイン状態
            public let state: State

            /// イニシャライザ
            /// - Parameter state: サインイン状態
            init(_ state: State) {
                self.state = state
            }

            /// エンティティ -> モデル変換
            init(_ entity: JobOrder_API.AuthenticationEntity.Output.SignInResult?) {
                self.state = State(entity?.state)
            }

            /// サインイン状態
            public enum State: CaseIterable {
                /// サインイン済
                case signedIn
                /// 新しいパスワードを要求
                case newPasswordRequired
                /// 不明
                case unknown

                /// エンティティ -> モデル変換
                init(_ state: JobOrder_API.AuthenticationEntity.Output.SignInResult.State?) {
                    switch state {
                    case .signedIn: self = .signedIn
                    case .newPasswordRequired: self = .newPasswordRequired
                    default: self = .unknown
                    }
                }
            }

            static func == (lhs: SignInResult, rhs: SignInResult) -> Bool {
                return lhs.state == rhs.state
            }
        }

        /// サインアウト
        public struct SignOutResult {
            /// サインアウト状態
            public let state: State

            /// イニシャライザ
            /// - Parameter state: サインアウト状態
            init(_ state: State) {
                self.state = state
            }

            /// エンティティ -> モデル変換
            init(_ entity: JobOrder_API.AuthenticationEntity.Output.SignOutResult?) {
                self.state = State(entity?.state)
            }

            /// サインアウト状態
            public enum State: CaseIterable {
                /// 成功
                case success
                /// 不明
                case unknown

                /// エンティティ -> モデル変換
                init(_ state: JobOrder_API.AuthenticationEntity.Output.SignOutResult.State?) {
                    switch state {
                    case .success: self = .success
                    default: self = .unknown
                    }
                }
            }

            static func == (lhs: SignOutResult, rhs: SignOutResult) -> Bool {
                return lhs.state == rhs.state
            }
        }

        /// パスワード忘れ結果
        public struct ForgotPasswordResult {
            /// パスワード忘れ状態
            public let state: State

            /// イニシャライザ
            /// - Parameter state: パスワード忘れ状態
            init(_ state: State) {
                self.state = state
            }

            /// エンティティ -> モデル変換
            init(_ entity: JobOrder_API.AuthenticationEntity.Output.ForgotPasswordResult?) {
                self.state = State(entity?.state)
            }

            /// パスワード忘れ状態
            public enum State: CaseIterable {
                /// 設定完了
                case done
                /// 確認コード送信
                case confirmationCodeSent
                /// 不明
                case unknown

                /// エンティティ -> モデル変換
                init(_ state: JobOrder_API.AuthenticationEntity.Output.ForgotPasswordResult.State?) {
                    switch state {
                    case .done: self = .done
                    case .confirmationCodeSent: self = .confirmationCodeSent
                    default: self = .unknown
                    }
                }
            }

            static func == (lhs: ForgotPasswordResult, rhs: ForgotPasswordResult) -> Bool {
                return lhs.state == rhs.state
            }
        }

        /// サインアップ結果
        public struct SignUpResult {
            /// サインアップ状態
            public let state: ConfirmationState

            /// イニシャライザ
            /// - Parameter state: 確認状態
            init(_ state: ConfirmationState) {
                self.state = state
            }

            /// エンティティ -> モデル変換
            init(_ entity: JobOrder_API.AuthenticationEntity.Output.SignUpResult?) {
                self.state = ConfirmationState(entity?.state)
            }

            /// 確認状態
            public enum ConfirmationState: CaseIterable {
                /// 確認済
                case confirmed
                /// 未確認
                case unconfirmed
                /// 不明
                case unknown

                /// エンティティ -> モデル変換
                init(_ state: JobOrder_API.AuthenticationEntity.Output.SignUpResult.ConfirmationState?) {
                    guard let state = state else {
                        self = .unknown
                        return
                    }
                    switch state {
                    case .confirmed: self = .confirmed
                    case .unconfirmed: self = .unconfirmed
                    default: self = .unknown
                    }
                }
            }

            static func == (lhs: SignUpResult, rhs: SignUpResult) -> Bool {
                return lhs.state == rhs.state
            }
        }

        /// メール情報
        public struct Email {
            /// メールアドレス
            public var address: String?

            /// イニシャライザ
            /// - Parameter state: サインアウト状態
            init(_ address: String?) {
                self.address = address
            }

            /// エンティティ -> モデル変換
            init(_ entity: JobOrder_API.AuthenticationEntity.Output.Attributes?) {
                self.address = entity?.email
            }

            static func == (lhs: Email, rhs: Email) -> Bool {
                return lhs.address == rhs.address
            }
        }
    }
}
