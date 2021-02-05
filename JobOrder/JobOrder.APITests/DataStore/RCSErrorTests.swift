//
//  RCSErrorTests.swift
//  JobOrderTests
//
//  Created by 藤井一暢 on 2021/01/26.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest
import SwiftCheck
@testable import JobOrder_API

class RCSErrorTests: XCTestCase {

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_init() {

        property("API Gatewayエラーの場合") <- forAll { (response: RCSError.APIGatewayErrorResponse) in
            let data = try! JSONEncoder().encode(response)
            let error = RCSError(from: data)
            guard case let .apiGatewayError(response: actual) = error else { return false }
            return actual == response
        }

        property("Lambda Functionエラーの場合") <- forAll { (response: RCSError.LamdbaFunctionErrorResponse) in
            let data = try! JSONEncoder().encode(response)
            let error = RCSError(from: data)
            guard case let .lambdaFunctionError(response: actual) = error else { return false }
            return actual == response
        }

        property("不明なレスポンスの場合") <- forAll { (str: String) in
            let data = str.data(using: .unicode)!
            let error = RCSError(from: data)
            guard case let .unknownError(data: actual) = error else { return false }
            return actual == data
        }

    }
}

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
