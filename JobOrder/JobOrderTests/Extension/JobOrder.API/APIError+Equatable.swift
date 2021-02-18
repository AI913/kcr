//
//  APIError+Equatable.swift
//  JobOrderTests
//
//  Created by 藤井一暢 on 2021/02/16.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
@testable import JobOrder_API

extension APIError: Equatable {
    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case let (.invalidStatus(code: lhsCode, reason: lhsReason), .invalidStatus(code: rhsCode, reason: rhsReason)):
            return lhsCode == rhsCode && lhsReason == rhsReason
        case (.missingContentType, .missingContentType):
            return true
        case let (.unacceptableContentType(lhsType), .unacceptableContentType(rhsType)):
            return lhsType == rhsType
        case (.unsupportedMediaFormat, .unsupportedMediaFormat):
            return true
        default:
            return false
        }
    }
}
