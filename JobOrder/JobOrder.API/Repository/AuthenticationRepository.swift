//
//  AuthenticationRepository.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/05.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

/// クラウドに対してユーザー認証を行うためのプロトコル
/// @mockable
public protocol AuthenticationRepository {
    /// 現在のユーザー名を取得
    var currentUsername: String? { get }
    /// サインイン状態を取得
    var isSignedIn: Bool { get }
    /// サインイン状態通知イベントの登録
    func registerUserStateChange() -> AnyPublisher<AuthenticationEntity.Output.AuthenticationState, Never>
    /// サインイン状態通知イベントの解除
    func unregisterUserStateChange()
    /// サインイン
    /// - Parameters:
    ///   - username: ユーザー名
    ///   - password: パスワード
    func signIn(username: String, password: String) -> AnyPublisher<AuthenticationEntity.Output.SignInResult, Error>
    /// パスワード再設定付きのサインイン
    /// - Parameter newPassword: 新しいパスワード
    func confirmSignIn(newPassword: String) -> AnyPublisher<AuthenticationEntity.Output.SignInResult, Error>
    /// サインアウト
    func signOut() -> AnyPublisher<AuthenticationEntity.Output.SignOutResult, Error>
    /// 認証トークンを取得
    func getTokens() -> AnyPublisher<AuthenticationEntity.Output.Tokens, Error>
    /// アトリビュートを取得
    func getAttrlibutes() -> AnyPublisher<AuthenticationEntity.Output.Attributes, Error>
    /// パスワード忘れた旨を通知
    /// - Parameter username: ユーザー名
    func forgotPassword(username: String) -> AnyPublisher<AuthenticationEntity.Output.ForgotPasswordResult, Error>
    /// 新しいパスワードと確認コードを通知
    /// - Parameters:
    ///   - username: ユーザー名
    ///   - newPassword: 新しいパスワード
    ///   - confirmationCode: 確認コード
    func confirmForgotPassword(username: String, newPassword: String, confirmationCode: String) -> AnyPublisher<AuthenticationEntity.Output.ForgotPasswordResult, Error>
    /// 確認コードの再送を要求
    /// - Parameter username: ユーザー名
    func resendConfirmationCode(username: String) -> AnyPublisher<AuthenticationEntity.Output.SignUpResult, Error>
}
