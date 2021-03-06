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
