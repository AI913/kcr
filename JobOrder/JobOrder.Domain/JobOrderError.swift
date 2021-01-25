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
        /// その他
        case unknown(error: Error)
    }

    /// サーバ接続エラーの理由
    public enum ConnectionFailureReason {
        /// Fail to Disconnect.
        case failToDisconnect(error: Error?)
        /// API Resuponse is null
        case apiResuponseIsNull
    }

    /// 入力エラーの理由
    public enum InputValidationErrorReason {
        /// PostData is Nil
        case postDataIsNil
    }

    case authenticationFailed(reason: AuthenticationFailureReason)
    case connectionFailed(reason: ConnectionFailureReason)
    case inputValidationFailed(reason: InputValidationErrorReason)
    case internalError(error: Error?)

    public init(from error: Error?) {
        switch error {
        case let e as Self:
            self = e
            return
        case let e as JobOrder_API.AWSError:
            self.init(from: e)
            return
        default: break
        }
        self = .internalError(error: error)
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
                default:
                    self = .authenticationFailed(reason: .unknown(error: error))
                }
            default: break
            }
        default: break
        }
        self = .internalError(error: error)
    }
}
