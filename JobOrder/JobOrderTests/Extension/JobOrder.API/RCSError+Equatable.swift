//
//  RCSError+Equatable.swift
//  JobOrderTests
//
//  Created by 藤井一暢 on 2021/02/16.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
@testable import JobOrder_API

extension RCSError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.apiGatewayError(response: lhsResponse), .apiGatewayError(response: rhsResponse)):
            return lhsResponse == rhsResponse
        case let (.lambdaFunctionError(response: lhsResponse), .lambdaFunctionError(response: rhsResponse)):
            return lhsResponse == rhsResponse
        case let (.unknownError(data: lhsData), .unknownError(data: rhsData)):
            return lhsData == rhsData
        default:
            return false
        }
    }
}

extension RCSError.APIGatewayErrorResponse: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.type == rhs.type &&
            lhs.resourcePath == rhs.resourcePath &&
            lhs.message == rhs.message &&
            lhs.details == rhs.details
    }
}

extension RCSError.LamdbaFunctionErrorResponse: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.time == rhs.time && lhs.errors.elementsEqual(rhs.errors)
    }
}

extension RCSError.LamdbaFunctionErrorResponse.ErrorObject: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.code == rhs.code &&
            lhs.field == rhs.field &&
            lhs.value == rhs.value &&
            lhs.description == rhs.description
    }
}
