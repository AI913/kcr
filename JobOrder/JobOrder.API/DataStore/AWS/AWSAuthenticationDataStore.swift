//
//  AWSAuthenticationDataStore.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/05.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import AWSMobileClient
import JobOrder_Utility

/// AWSMobileClient APIを利用してAmazon Cognitoを操作する
public class AWSAuthenticationDataStore: AuthenticationRepository {

    /// AWSMobileClientProtocol
    var awsMobileClient: AWSMobileClientProtocol = AWSMobileClient.default()

    /// AWS Mobile Clientクラスを初期化する
    public init() {
        awsMobileClient.initialize { (userState, error) in
            if let error = error {
                Logger.error(target: self, "error : \(error.localizedDescription)")
            } else {
                Logger.debug(target: self, "userState : \(userState ?? .unknown)")
            }
        }
    }

    /// AWSから現在のユーザー名を取得
    /// - Returns: ユーザー名
    public var currentUsername: String? {
        return awsMobileClient.username
    }

    /// AWSからサインイン状態を取得
    /// - Returns: サインイン状態
    public var isSignedIn: Bool {
        return awsMobileClient.isSignedIn
    }

    /// サインイン状態通知イベントの登録
    /// - Returns: サインイン状態
    public func registerUserStateChange() -> AnyPublisher<AuthenticationEntity.Output.AuthenticationState, Never> {

        let publisher = PassthroughSubject<AuthenticationEntity.Output.AuthenticationState, Never>()
        awsMobileClient.addUserStateListener(self) { userState, _ in
            let entity = AuthenticationEntity.Output.AuthenticationState(userState)
            // Logger.debug(target: self, "\(entity)")
            publisher.send(entity)
        }
        return publisher.eraseToAnyPublisher()
    }

    /// サインイン状態通知イベントの解除
    public func unregisterUserStateChange() {
        awsMobileClient.removeUserStateListener(self)
    }

    /// AWSへサインイン
    /// - Parameters:
    ///   - username: ユーザー名
    ///   - password: パスワード
    /// - Returns: サインイン結果
    public func signIn(username: String, password: String) -> AnyPublisher<AuthenticationEntity.Output.SignInResult, Error> {
        Logger.info(target: self)

        // ログイン済の場合は一旦ログアウト
        if awsMobileClient.isSignedIn {
            awsMobileClient.signOut()
        }

        return Future<AuthenticationEntity.Output.SignInResult, Error> { promise in
            self.awsMobileClient.signIn(username: username, password: password) { result, error in
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
            self.awsMobileClient.confirmSignIn(challengeResponse: newPassword) { result, error in
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
            self.awsMobileClient.signOut { error in
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
            self.awsMobileClient.getTokens { result, error in
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
            self.awsMobileClient.getUserAttributes { result, error in
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
            self.awsMobileClient.forgotPassword(username: username) { result, error in
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
            self.awsMobileClient.confirmForgotPassword(username: username, newPassword: newPassword, confirmationCode: confirmationCode) { result, error in
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
            self.awsMobileClient.resendSignUpCode(username: username) { result, error in
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

/// @mockable
protocol AWSMobileClientProtocol {
    var username: String? { get }
    var isSignedIn: Bool { get }
    func initialize(_ completionHandler: @escaping (UserState?, Error?) -> Void)
    func addUserStateListener(_ object: AnyObject, _ callback: @escaping UserStateChangeCallback)
    func removeUserStateListener(_ object: AnyObject)
    func signIn(username: String, password: String, completionHandler: @escaping ((SignInResult?, Error?) -> Void))
    func confirmSignIn(challengeResponse: String, completionHandler: @escaping ((SignInResult?, Error?) -> Void))
    func signOut()
    func signOut(completionHandler: @escaping ((Error?) -> Void))
    func getTokens(_ completionHandler: @escaping (Tokens?, Error?) -> Void)
    func getUserAttributes(completionHandler: @escaping (([String: String]?, Error?) -> Void))
    func forgotPassword(username: String, completionHandler: @escaping ((ForgotPasswordResult?, Error?) -> Void))
    func confirmForgotPassword(username: String, newPassword: String, confirmationCode: String, completionHandler: @escaping ((ForgotPasswordResult?, Error?) -> Void))
    func resendSignUpCode(username: String, completionHandler: @escaping ((SignUpResult?, Error?) -> Void))
    func getAWSCredentials(_ completionHandler: @escaping(AWSCredentials?, Error?) -> Void)
    func getIdentityId() -> AWSTask<NSString>
}

extension AWSMobileClient: AWSMobileClientProtocol {
    func resendSignUpCode(username: String, completionHandler: @escaping ((SignUpResult?, Error?) -> Void)) {
        resendSignUpCode(username: username, clientMetaData: [:], completionHandler: completionHandler)
    }

    func signIn(username: String, password: String, completionHandler: @escaping ((SignInResult?, Error?) -> Void)) {
        signIn(username: username, password: password, validationData: nil, completionHandler: completionHandler)
    }
    func confirmSignIn(challengeResponse: String, completionHandler: @escaping ((SignInResult?, Error?) -> Void)) {
        confirmSignIn(challengeResponse: challengeResponse, userAttributes: [:], clientMetaData: [:], completionHandler: completionHandler)
    }
    func signOut(completionHandler: @escaping ((Error?) -> Void)) {
        signOut(options: SignOutOptions(), completionHandler: completionHandler)
    }
    func forgotPassword(username: String, completionHandler: @escaping ((ForgotPasswordResult?, Error?) -> Void)) {
        forgotPassword(username: username, clientMetaData: [:], completionHandler: completionHandler)
    }
    func confirmForgotPassword(username: String, newPassword: String, confirmationCode: String, completionHandler: @escaping ((ForgotPasswordResult?, Error?) -> Void)) {
        confirmForgotPassword(username: username, newPassword: newPassword, confirmationCode: confirmationCode, clientMetaData: [:], completionHandler: completionHandler)
    }
}
