//
//  AWSAuthenticationDataStore.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/05.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Utility

/// AWSMobileClient APIを利用してAmazon Cognitoを操作する
public class AWSAuthenticationDataStore: AuthenticationRepository {

    /// Factory
    let factory = AWSSDKFactory.shared

    /// イニシャライザ
    public init() {}

    /// Configuration を設定し初期化
    /// - Parameter configuration: Configuration データ
    /// - Returns: 結果
    public func initialize(_ configuration: [String: Any]) -> AnyPublisher<AuthenticationEntity.Output.AuthenticationState, Error> {
        self.factory.set(configuration: configuration)

        return Future<AuthenticationEntity.Output.AuthenticationState, Error> { promise in
            self.factory.mobileClient?.initialize { (userState, error) in
                if let error = error {
                    Logger.error(target: self, "error : \(error.localizedDescription)")
                    promise(.failure(AWSError.authenticationFailed(reason: .init(error))))
                } else {
                    guard let state = userState, state != .unknown else {
                        promise(.failure(AWSError.authenticationFailed(reason: .unknown(error: NSError()))))
                        return
                    }
                    Logger.debug(target: self, "userState : \(state)")
                    promise(.success(.init(state)))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// AWSから現在のユーザー名を取得
    /// - Returns: ユーザー名
    public var currentUsername: String? {
        return factory.mobileClient?.username
    }

    /// AWSからサインイン状態を取得
    /// - Returns: サインイン状態
    public var isSignedIn: Bool {
        return factory.mobileClient?.isSignedIn ?? false
    }

    /// サインイン状態通知イベントの登録
    /// - Returns: サインイン状態
    public func registerUserStateChange() -> AnyPublisher<AuthenticationEntity.Output.AuthenticationState, Never> {

        let publisher = PassthroughSubject<AuthenticationEntity.Output.AuthenticationState, Never>()
        factory.mobileClient?.addUserStateListener(self) { userState, _ in
            let entity = AuthenticationEntity.Output.AuthenticationState(userState)
            // Logger.debug(target: self, "\(entity)")
            publisher.send(entity)
        }
        return publisher.eraseToAnyPublisher()
    }

    /// サインイン状態通知イベントの解除
    public func unregisterUserStateChange() {
        factory.mobileClient?.removeUserStateListener(self)
    }

    /// AWSへサインイン
    /// - Parameters:
    ///   - username: ユーザー名
    ///   - password: パスワード
    /// - Returns: サインイン結果
    public func signIn(username: String, password: String) -> AnyPublisher<AuthenticationEntity.Output.SignInResult, Error> {
        Logger.info(target: self)

        // ログイン済の場合は一旦ログアウト
        if factory.mobileClient?.isSignedIn ?? false {
            factory.mobileClient?.signOut()
        }

        return Future<AuthenticationEntity.Output.SignInResult, Error> { promise in
            self.factory.mobileClient?.signIn(username: username, password: password) { result, error in
                if let error = error {
                    promise(.failure(AWSError.authenticationFailed(reason: .init(error))))
                } else {
                    let entity = AuthenticationEntity.Output.SignInResult(result)
                    // Logger.debug(target: self, "\(entity)")
                    promise(.success(entity))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// パスワード再設定付きのサインイン
    /// - Parameter newPassword: 新しいパスワード
    /// - Returns: サインイン結果
    public func confirmSignIn(newPassword: String) -> AnyPublisher<AuthenticationEntity.Output.SignInResult, Error> {
        Logger.info(target: self)

        return Future<AuthenticationEntity.Output.SignInResult, Error> { promise in
            self.factory.mobileClient?.confirmSignIn(challengeResponse: newPassword) { result, error in
                if let error = error {
                    promise(.failure(AWSError.authenticationFailed(reason: .init(error))))
                } else {
                    let entity = AuthenticationEntity.Output.SignInResult(result)
                    // Logger.debug(target: self, "\(entity)")
                    promise(.success(entity))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// AWSからサインアウト
    /// - Returns: サインアウト結果
    public func signOut() -> AnyPublisher<AuthenticationEntity.Output.SignOutResult, Error> {
        Logger.info(target: self)

        return Future<AuthenticationEntity.Output.SignOutResult, Error> { promise in
            self.factory.mobileClient?.signOut { error in
                if let error = error {
                    promise(.failure(AWSError.authenticationFailed(reason: .init(error))))
                } else {
                    let entity = AuthenticationEntity.Output.SignOutResult(state: .success)
                    // Logger.debug(target: self, "\(entity)")
                    promise(.success(entity))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// AWSから認証トークンを取得
    /// - Returns: 認証トークン情報
    public func getTokens() -> AnyPublisher<AuthenticationEntity.Output.Tokens, Error> {
        Logger.info(target: self)

        return Future<AuthenticationEntity.Output.Tokens, Error> { promise in
            self.factory.mobileClient?.getTokens { result, error in
                if let error = error {
                    promise(.failure(AWSError.authenticationFailed(reason: .init(error))))
                } else {
                    let entity = AuthenticationEntity.Output.Tokens(result)
                    // Logger.debug(target: self, "\(entity)")
                    promise(.success(entity))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// AWSからアトリビュートを取得
    /// - Returns: アトリビュートの配列
    public func getAttrlibutes() -> AnyPublisher<AuthenticationEntity.Output.Attributes, Error> {
        Logger.info(target: self)

        return Future<AuthenticationEntity.Output.Attributes, Error> { promise in
            self.factory.mobileClient?.getUserAttributes { result, error in
                if let error = error {
                    promise(.failure(AWSError.authenticationFailed(reason: .init(error))))
                } else {
                    let entity = AuthenticationEntity.Output.Attributes(result)
                    // Logger.debug(target: self, "\(entity)")
                    promise(.success(entity))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// パスワード忘れた旨をAWSへ通知する
    /// - Parameter username: ユーザー名
    /// - Returns: 確認コードの送信結果
    public func forgotPassword(username: String) -> AnyPublisher<AuthenticationEntity.Output.ForgotPasswordResult, Error> {
        Logger.info(target: self)

        return Future<AuthenticationEntity.Output.ForgotPasswordResult, Error> { promise in
            self.factory.mobileClient?.forgotPassword(username: username) { result, error in
                if let error = error {
                    promise(.failure(AWSError.authenticationFailed(reason: .init(error))))
                } else {
                    let entity = AuthenticationEntity.Output.ForgotPasswordResult(result)
                    // Logger.debug(target: self, "\(entity)")
                    promise(.success(entity))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// 新しいパスワードと確認コードをAWSへ通知する
    /// - Parameters:
    ///  - username: ユーザー名
    ///  - newPassword: 新しいパスワード
    ///  - confirmationCode: 確認コード
    /// - Returns: パスワードを忘れた時の再設定結果
    public func confirmForgotPassword(username: String, newPassword: String, confirmationCode: String) -> AnyPublisher<AuthenticationEntity.Output.ForgotPasswordResult, Error> {
        Logger.info(target: self)

        return Future<AuthenticationEntity.Output.ForgotPasswordResult, Error> { promise in
            self.factory.mobileClient?.confirmForgotPassword(username: username, newPassword: newPassword, confirmationCode: confirmationCode) { result, error in
                if let error = error {
                    promise(.failure(AWSError.authenticationFailed(reason: .init(error))))
                } else {
                    let entity = AuthenticationEntity.Output.ForgotPasswordResult(result)
                    // Logger.debug(target: self, "\(entity)")
                    promise(.success(entity))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// 確認コードの再送をAWSへ要求する
    /// - Parameter username: ユーザー名
    /// - Returns: 確認コードの送信結果
    public func resendConfirmationCode(username: String) -> AnyPublisher<AuthenticationEntity.Output.SignUpResult, Error> {
        Logger.info(target: self)

        return Future<AuthenticationEntity.Output.SignUpResult, Error> { promise in
            self.factory.mobileClient?.resendSignUpCode(username: username) { result, error in
                if let error = error {
                    promise(.failure(AWSError.authenticationFailed(reason: .init(error))))
                } else {
                    let entity = AuthenticationEntity.Output.SignUpResult(result)
                    // Logger.debug(target: self, "\(entity)")
                    promise(.success(entity))
                }
            }
        }.eraseToAnyPublisher()
    }
}
