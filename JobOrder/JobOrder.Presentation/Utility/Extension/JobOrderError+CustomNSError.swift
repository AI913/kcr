//
//  JobOrderError+CustomNSError.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/12/28.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import JobOrder_Domain

extension JobOrder_Domain.JobOrderError: CustomNSError {
    public var errorUserInfo: [String: Any] {
        switch self {
        case .authenticationFailed:
            return ["__type": "認証エラー"]
        default:
            return [:]
        }
    }
}
