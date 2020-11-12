//
//  OneOffFuncTests.swift
//  JobOrder.UtilityTests
//
//  Created by Yu Suzuki on 2020/08/19.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Utility

class OneOffFuncTests: XCTestCase {

    private let ms1000 = 1.0
    private let oneOffFunc = OneOffFunc()

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_execute() {

        XCTContext.runActivity(named: "1回目") { _ in
            let exp = expectation(description: "execute1")
            var count = 0
            oneOffFunc.execute {
                exp.fulfill()
                count += 1
            }
            wait(for: [exp], timeout: ms1000)
            XCTAssertEqual(count, 1, "実行されなくてはいけない")
        }

        XCTContext.runActivity(named: "2回目") { _ in
            let exp = expectation(description: "execute2")
            exp.isInverted = true
            var count = 0

            oneOffFunc.execute {
                exp.fulfill()
                count += 1
            }
            wait(for: [exp], timeout: ms1000)
            XCTAssertEqual(count, 0, "実行されてはいけない")
        }
    }
}
