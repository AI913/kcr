//
//  JobOrderError+NSErrorTests.swift
//  JobOrderTests
//
//  Created by 藤井一暢 on 2021/01/29.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Domain

class JobOrderError_NSErrorTests: XCTestCase {

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_description() {
        let e = NSError(domain: "Error", code: -1, userInfo: nil)
        XCTContext.runActivity(named: "認証エラーの場合") { _ in
            let error = JobOrderError.authenticationFailed(reason: .incorrectUsernameOrPassword(error: e)) as NSError
            XCTAssertEqual(error.userInfo["__type"] as? String, "認証エラー")
            XCTAssertEqual(error.localizedDescription, "ユーザ名またはパスワードが違います")
        }

        XCTContext.runActivity(named: "RCS接続エラーの場合") { _ in
            let code = FakeFactory.shared.rcsErrorGen.generate
            let description = String.arbitrary.generate
            let error = JobOrderError.connectionFailed(reason: .serviceUnavailable(code: code, description: description, error: e)) as NSError
            XCTAssertEqual(error.userInfo["__type"] as? String, "接続エラー")
            XCTAssertEqual(error.localizedDescription, "\(code): \(description)")
        }

        XCTContext.runActivity(named: "NW接続エラーの場合") { _ in
            let error = JobOrderError.connectionFailed(reason: .networkUnavailable(error: URLError(.notConnectedToInternet))) as NSError
            XCTAssertEqual(error.userInfo["__type"] as? String, "接続エラー")
            XCTAssertEqual(error.localizedDescription, "ネットワーク接続中にエラーが発生しました")
        }

    }
}
