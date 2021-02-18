//
//  StartupUITests.swift
//  JobOrderUITests
//
//  Created by Yu Suzuki on 2021/02/10.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest

class StartupUITests: JobOrderUITests {

    func testToMain() throws {

        XCTContext.runActivity(named: "Main画面へ遷移する") { _ in
            XCTAssertTrue(setSpace().waitForExistence(), "画面遷移できなかった")
        }
    }
}
