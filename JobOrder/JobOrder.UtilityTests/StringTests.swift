//
//  StringTests.swift
//  JobOrder.UtilityTests
//
//  Created by Yu Suzuki on 2020/08/19.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Utility

class StringTests: XCTestCase {

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_crypto() {

        let param = "test"
        XCTAssertEqual(param.sha1, "a94a8fe5ccb19ba61c4c0873d391e987982fbbd3", "正しい値が取得できていない: \(param.sha1)")
        XCTAssertEqual(param.sha224, "90a3ed9e32b2aaf4c61c410eb925426119e1a9dc53d4286ade99a809", "正しい値が取得できていない: \(param.sha224)")
        XCTAssertEqual(param.sha256, "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08", "正しい値が取得できていない: \(param.sha256)")
        XCTAssertEqual(param.sha384, "768412320f7b0aa5812fce428dc4706b3cae50e02a64caa16a782249bfe8efc4b7ef1ccb126255d196047dfedf17a0a9", "正しい値が取得できていない: \(param.sha384)")
        XCTAssertEqual(param.sha512, "ee26b0dd4af7e749aa1a8ee3c10ae9923f618980772e473f8819a5d4940e0db27ac185f8a0e1d5f84f88bc887fd67b143732c304cc5fa9ad8e6f57f50028a8ff", "正しい値が取得できていない: \(param.sha512)")
    }
}
