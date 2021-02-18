//
//  JobOrderError.swift
//  JobOrder.Domain
//
//  Created by 藤井一暢 on 2020/12/28.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import JobOrder_API

public enum JobOrderError: Error {
    /// 認証エラーの理由
    public enum AuthenticationFailureReason {
        /// IDまたはパスワードが正しくない
        case incorrectUsernameOrPassword(error: Error)
        /// idToken is null.
        case idTokenIsNull
        /// Configurationファイル取得エラー
        case failedToGetConfiguration(error: Error?)
        /// Configurationファイルが不正
        case configurationDataIsNotCorrect
        /// DataStoreの初期化エラー
        case initializeFailed(error: Error)
        /// その他
        case unknown(error: Error)
    }

    /// サーバ接続エラーの理由
    public enum ConnectionFailureReason {
        /// Fail to Disconnect.
        case failToDisconnect
        /// 想定しないレスポンス形式
        case invalidResponseFormat
        /// 処理できないレスポンス
        case unacceptableResponse
        /// サービス利用不可
        case serviceUnavailable(code: String?, description: String?, error: Error)
        /// ネットワーク利用不可
        case networkUnavailable(error: URLError)
    }

    /// 入力エラーの理由
    public enum InputValidationErrorReason {
        /// PostData is Nil
        case postDataIsNil
    }

    /// 認証エラー
    case authenticationFailed(reason: AuthenticationFailureReason)
    /// 接続エラー
    case connectionFailed(reason: ConnectionFailureReason)
    /// 入力エラー
    case inputValidationFailed(reason: InputValidationErrorReason)
    /// その他の内部エラー
    case internalError(error: Error?)

    public init(from error: Error?) {
        switch error {
        case let e as Self:
            self = e
            return
        case let e as JobOrder_API.APIError:
            self.init(from: e)
            return
        case let e as JobOrder_API.AWSError:
            self.init(from: e)
            return
        case let e as URLError:
            self = .connectionFailed(reason: .networkUnavailable(error: e))
            return
        default: break
        }
        self = .internalError(error: error)
    }

    public init(from error: JobOrder_API.APIError) {
        switch error {
        case let .invalidStatus(code: _, reason: reason):
            switch reason {
            case let .lambdaFunctionError(response: response):
                self = .connectionFailed(reason: .serviceUnavailable(code: response.errorCode, description: response.errorDescription, error: error))
                return
            default: break
            }
        default: break
        }
        self = .connectionFailed(reason: .serviceUnavailable(code: nil, description: nil, error: error))
    }

    public init(from error: JobOrder_API.AWSError) {
        switch error {
        case let .authenticationFailed(reason: reason):
            switch reason {
            case let .awsMobileClientFailed(error: e):
                switch e {
                case .notAuthorized:
                    self = .authenticationFailed(reason: .incorrectUsernameOrPassword(error: error))
                    return
                default: break
                }
            default: break
            }
        default: break
        }
        self = .connectionFailed(reason: .serviceUnavailable(code: nil, description: nil, error: error))
    }
}
