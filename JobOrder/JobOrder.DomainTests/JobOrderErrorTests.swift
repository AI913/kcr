//
//  JobOrderErrorTests.swift
//  JobOrderTests
//
//  Created by 藤井一暢 on 2021/01/29.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Domain
@testable import JobOrder_API
@testable import AWSMobileClient

class JobOrderErrorTests: XCTestCase {

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_init() {
        XCTContext.runActivity(named: "自分自身の場合") { _ in
            let error = JobOrderError.internalError(error: nil)

            let actual = JobOrderError(from: error as Error)
            if case let .internalError(error: e) = actual {
                XCTAssertNil(e, "正しい値が取得できていない")
            } else {
                XCTFail("正しい値が取得できていない: \(actual)")
            }
        }

        XCTContext.runActivity(named: "APIErrorの場合") { _ in
            let errors: [APIError] = [.missingContentType, .unacceptableContentType("param"), .unsupportedMediaFormat]

            for error in errors {
                let actual = JobOrderError(from: error as Error)
                if case let .connectionFailed(reason: .serviceUnavailable(code: code, description: description, error: e)) = actual,
                   let err = e as? APIError {
                    XCTAssertNil(code, "正しい値が取得できていない")
                    XCTAssertNil(description, "正しい値が取得できていない")
                    XCTAssertEqual(err, error, "正しい値が取得できていない")
                } else {
                    XCTFail("正しい値が取得できていない: \(actual)")
                }
            }

            XCTContext.runActivity(named: "invalidStatusの場合") { _ in
                XCTContext.runActivity(named: "apiGatewayErrorの場合") { _ in
                    let (errorCode, _) = FakeFactory.shared.httpErrorGen.generate
                    let response = RCSError.APIGatewayErrorResponse.arbitrary.generate
                    let error = APIError.invalidStatus(code: errorCode, reason: .apiGatewayError(response: response))

                    let actual = JobOrderError(from: error as Error)
                    if case let .connectionFailed(reason: .serviceUnavailable(code: code, description: description, error: e)) = actual,
                       let err = e as? APIError {
                        XCTAssertNil(code, "正しい値が取得できていない")
                        XCTAssertNil(description, "正しい値が取得できていない")
                        XCTAssertEqual(err, error, "正しい値が取得できていない")
                    } else {
                        XCTFail("正しい値が取得できていない: \(actual)")
                    }
                }

                XCTContext.runActivity(named: "lambdaFunctionErrorの場合") { _ in
                    let (errorCode, _) = FakeFactory.shared.httpErrorGen.generate
                    let response = RCSError.LamdbaFunctionErrorResponse.arbitrary.suchThat({ !$0.errors.isEmpty }).generate
                    let error = APIError.invalidStatus(code: errorCode, reason: .lambdaFunctionError(response: response))

                    let actual = JobOrderError(from: error as Error)
                    if case let .connectionFailed(reason: .serviceUnavailable(code: code, description: description, error: e)) = actual,
                       let err = e as? APIError {
                        XCTAssertEqual(code, response.errorCode, "正しい値が取得できていない")
                        XCTAssertEqual(description, response.errorDescription, "正しい値が取得できていない")
                        XCTAssertEqual(err, error, "正しい値が取得できていない")
                    } else {
                        XCTFail("正しい値が取得できていない: \(actual)")
                    }
                }

                XCTContext.runActivity(named: "unknownErrorの場合") { _ in
                    let (errorCode, _) = FakeFactory.shared.httpErrorGen.generate
                    let response = String.arbitrary.generate.data(using: .unicode)
                    let error = APIError.invalidStatus(code: errorCode, reason: .unknownError(data: response))

                    let actual = JobOrderError(from: error as Error)
                    if case let .connectionFailed(reason: .serviceUnavailable(code: code, description: description, error: e)) = actual,
                       let err = e as? APIError {
                        XCTAssertNil(code, "正しい値が取得できていない")
                        XCTAssertNil(description, "正しい値が取得できていない")
                        XCTAssertEqual(err, error, "正しい値が取得できていない")
                    } else {
                        XCTFail("正しい値が取得できていない: \(actual)")
                    }
                }

                XCTContext.runActivity(named: "nilの場合") { _ in
                    let (errorCode, _) = FakeFactory.shared.httpErrorGen.generate
                    let error = APIError.invalidStatus(code: errorCode, reason: nil)

                    let actual = JobOrderError(from: error as Error)
                    if case let .connectionFailed(reason: .serviceUnavailable(code: code, description: description, error: e)) = actual,
                       let err = e as? APIError {
                        XCTAssertNil(code, "正しい値が取得できていない")
                        XCTAssertNil(description, "正しい値が取得できていない")
                        XCTAssertEqual(err, error, "正しい値が取得できていない")
                    } else {
                        XCTFail("正しい値が取得できていない: \(actual)")
                    }
                }
            }
        }

        XCTContext.runActivity(named: "AWSErrorの場合") { _ in
            let error = AWSError.s3ControlFailed(error: NSError(domain: "Error", code: -1, userInfo: nil))

            let actual = JobOrderError(from: error as Error)
            if case let .connectionFailed(reason: .serviceUnavailable(code: code, description: description, error: _)) = actual {
                XCTAssertNil(code, "正しい値が取得できていない")
                XCTAssertNil(description, "正しい値が取得できていない")
            } else {
                XCTFail("正しい値が取得できていない: \(actual)")
            }

            XCTContext.runActivity(named: "notAuthorizedの場合") { _ in
                let awsMobileClientError = AWSMobileClientError.notAuthorized(message: "param")
                let error = AWSError.authenticationFailed(reason: .awsMobileClientFailed(error: awsMobileClientError))

                let actual = JobOrderError(from: error as Error)
                if case .authenticationFailed(reason: .incorrectUsernameOrPassword) = actual {} else {
                    XCTFail("正しい値が取得できていない: \(actual)")
                }
            }
        }

        XCTContext.runActivity(named: "URLErrorの場合") { _ in
            let error = URLError(.notConnectedToInternet)

            let actual = JobOrderError(from: error as Error)
            if case let .connectionFailed(reason: .networkUnavailable(error: e)) = actual {
                XCTAssertEqual(e.code, error.code, "正しい値が取得できていない")
            } else {
                XCTFail("正しい値が取得できていない: \(actual)")
            }
        }

        XCTContext.runActivity(named: "nilの場合") { _ in
            let actual = JobOrderError(from: nil)

            if case let .internalError(error: e) = actual {
                XCTAssertNil(e, "正しい値が取得できていない")
            } else {
                XCTFail("正しい値が取得できていない: \(actual)")
            }
        }
    }
}
