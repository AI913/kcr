//
//  AuthenticationEntity.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/05.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import AWSMobileClient

extension AuthenticationEntity.Output.AuthenticationState {

    /// AWS -> エンティティ変換
    /// - Parameter state: AWS SDKで保持している認証状態
    init(_ state: UserState) {
        switch state {
        case .signedIn: self = .signedIn
        case .signedOut: self = .signedOut
        case .signedOutFederatedTokensInvalid: self = .signedOutFederatedTokensInvalid
        case .signedOutUserPoolsTokenInvalid: self = .signedOutUserPoolsTokenInvalid
        case .guest: self = .guest
        default: self = .unknown
        }
    }
}

extension AuthenticationEntity.Output.SignInResult {

    /// AWS -> エンティティ変換
    /// - Parameter result: AWS SDKで保持しているサインイン結果
    init(_ result: SignInResult?) {
        self.state = State(result?.signInState)
    }
}

extension AuthenticationEntity.Output.SignInResult.State {

    /// AWS -> エンティティ変換
    /// - Parameter state: AWS SDKで保持しているサインイン状態
    init(_ state: SignInState?) {
        switch state {
        case .signedIn: self = .signedIn
        case .newPasswordRequired: self = .newPasswordRequired
        case .passwordVerifier: self = .passwordVerifier
        case .customChallenge: self = .customChallenge
        case .smsMFA: self = .smsMFA
        case .deviceSRPAuth: self = .deviceSRPAuth
        case .devicePasswordVerifier: self = .devicePasswordVerifier
        case .adminNoSRPAuth: self = .adminNoSRPAuth
        default: self = .unknown
        }
    }
}

extension AuthenticationEntity.Output.ForgotPasswordResult {

    /// AWS -> エンティティ変換
    /// - Parameter result: AWS SDKで保持しているパスワード忘れ結果
    init(_ result: ForgotPasswordResult?) {
        self.state = State(result?.forgotPasswordState)
    }
}

extension AuthenticationEntity.Output.ForgotPasswordResult.State {

    /// AWS -> エンティティ変換
    /// - Parameter state: AWS SDKで保持しているパスワード忘れ状態
    init(_ state: ForgotPasswordState?) {
        switch state {
        case .done: self = .done
        case .confirmationCodeSent: self = .confirmationCodeSent
        default: self = .unknown
        }
    }
}

extension AuthenticationEntity.Output.SignUpResult {

    /// AWS -> エンティティ変換
    /// - Parameter result: AWS SDKで保持しているサインアップ結果
    init(_ result: SignUpResult?) {
        self.state = ConfirmationState(result?.signUpConfirmationState)
    }
}

extension AuthenticationEntity.Output.SignUpResult.ConfirmationState {

    /// AWS -> エンティティ変換
    /// - Parameter state: AWS SDKで保持しているサインアップ確認状態
    init(_ state: SignUpConfirmationState?) {
        switch state {
        case .confirmed: self = .confirmed
        case .unconfirmed: self = .unconfirmed
        case .unknown: self = .unknown
        default: self = .unknown
        }
    }
}

extension AuthenticationEntity.Output.Tokens {

    /// AWS -> エンティティ変換
    /// - Parameter tokens: AWS SDKで保持しているトークン情報
    init(_ tokens: Tokens?) {
        self.accessToken = tokens?.accessToken?.tokenString
        self.refreshToken = tokens?.refreshToken?.tokenString
        self.idToken = tokens?.idToken?.tokenString
        self.expiration = tokens?.expiration
    }
}

extension AuthenticationEntity.Output.Attributes {

    /// AWS -> エンティティ変換
    /// - Parameter attributes: AWS SDKで保持しているアトリビュート情報
    init(_ attributes: [String: String]?) {
        self.email = nil
        attributes?.forEach {
            if $0.key == "email" {
                self.email = $0.value
            }
        }
    }
}
