//
//  JobOrderError+LocalizedError.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/12/28.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import JobOrder_Domain

extension JobOrder_Domain.JobOrderError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .authenticationFailed(reason: .incorrectUsernameOrPassword):
            return "ユーザ名またはパスワードが違います"
        case .authenticationFailed(reason: .failedToGetConfiguration):
            return "サーバーからデータの取得に失敗しました"
        case .authenticationFailed(reason: .configurationDataIsNotCorrect):
            return "サーバーから取得したデータが不正です"
        case .authenticationFailed(reason: .initializeFailed):
            return "サーバーの設定に失敗しました\nアプリを再起動してください"
        case let .connectionFailed(reason: .serviceUnavailable(code: code?, description: description?, error: _)):
            return "\(code): \(description)"
        case .connectionFailed(reason: .networkUnavailable):
            return "ネットワーク接続中にエラーが発生しました"
        default:
            return "予期しないエラーが発生しました"
        }
    }
}
