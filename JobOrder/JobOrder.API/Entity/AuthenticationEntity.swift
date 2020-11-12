//
//  AuthenticationEntity.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/05.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

/// Authenticationエンティティ
public struct AuthenticationEntity {

    /// Domainへ出力するためのデータ形式
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
            /// ゲスト
            case guest
            /// 不明
            case unknown
        }

        /// サインイン結果
        public struct SignInResult {
            /// サインイン状態
            public let state: State
            /// サインイン状態
            public enum State: CaseIterable {
                /// サインイン済
                case signedIn
                /// 新しいパスワードを要求
                case newPasswordRequired
                /// パスワードを確認
                case passwordVerifier
                /// カスタムチャレンジ
                case customChallenge
                /// 多要素認証
                case smsMFA
                /// デバイスSecure Remote Password認証
                case deviceSRPAuth
                /// デバイスパスワードを確認
                case devicePasswordVerifier
                /// アドミニ認証
                case adminNoSRPAuth
                /// 不明
                case unknown
            }

            static func == (lhs: SignInResult, rhs: SignInResult) -> Bool {
                return lhs.state == rhs.state
            }
        }

        /// サインアウト
        public struct SignOutResult {
            /// サインアウト状態
            public let state: State
            /// サインアウト状態
            public enum State: CaseIterable {
                /// 成功
                case success
                /// 不明
                case unknown
            }
        }

        /// パスワード忘れ結果
        public struct ForgotPasswordResult {
            /// パスワード忘れ状態
            public let state: State
            /// パスワード忘れ状態
            public enum State: CaseIterable {
                /// 設定完了
                case done
                /// 確認コード送信
                case confirmationCodeSent
                /// 不明
                case unknown
            }
        }

        /// サインアップ結果
        public struct SignUpResult {
            /// サインアップ状態
            public let state: ConfirmationState
            /// 確認状態
            public enum ConfirmationState: CaseIterable {
                /// 確認済
                case confirmed
                /// 未確認
                case unconfirmed
                /// 不明
                case unknown
            }
        }

        /// ユーザーセッション
        public struct Tokens {
            /// アクセストークン
            public let accessToken: String?
            /// リフレッシュトークン
            public let refreshToken: String?
            /// IDトークン
            public let idToken: String?
            /// 有効期限
            public let expiration: Date?

            static func == (lhs: Tokens, rhs: Tokens) -> Bool {
                return lhs.accessToken == rhs.accessToken &&
                    lhs.refreshToken == rhs.refreshToken &&
                    lhs.idToken == rhs.idToken &&
                    lhs.expiration == rhs.expiration
            }
        }

        /// アトリビュート
        public struct Attributes {
            /// メールアドレス
            public var email: String?
        }
    }
}
