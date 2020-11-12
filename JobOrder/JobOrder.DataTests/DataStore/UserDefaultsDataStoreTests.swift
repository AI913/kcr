//
//  UserDefaultsDataStoreTests.swift
//  JobOrder.DataTests
//
//  Created by Yu Suzuki on 2020/07/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Data

class UserDefaultsDataStoreTests: XCTestCase {

    private let mock = UserDefaultsProtocolMock()
    private let dataStore = UserDefaultsDataStore()

    override func setUpWithError() throws {
        dataStore.userDefaults = mock
    }

    override func tearDownWithError() throws {}

    func test_getBoolFromUserDefaults() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            UserDefaultsKey.allCases.forEach {
                if $0.isBool() {
                    XCTAssertFalse(dataStore.bool(forKey: $0), "有効になってはいけない")
                }
            }
        }

        XCTContext.runActivity(named: "Trueが設定済みの場合") { _ in
            mock.boolHandler = { key in
                return true
            }
            UserDefaultsKey.allCases.forEach {
                if $0.isBool() {
                    XCTAssertTrue(dataStore.bool(forKey: $0), "無効になってはいけない")
                }
            }
        }

        XCTContext.runActivity(named: "Falseが設定済みの場合") { _ in
            mock.boolHandler = { key in
                return false
            }
            UserDefaultsKey.allCases.forEach {
                if $0.isBool() {
                    XCTAssertFalse(dataStore.bool(forKey: $0), "有効になってはいけない")
                }
            }
        }
    }

    func test_getStringFromUserDefaults() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            UserDefaultsKey.allCases.forEach {
                if $0.isString() {
                    XCTAssertNil(dataStore.string(forKey: $0), "値を取得できてはいけない")
                }
            }
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            mock.stringHandler = { key in
                return param
            }
            UserDefaultsKey.allCases.forEach {
                if $0.isString() {
                    XCTAssertEqual(dataStore.string(forKey: $0), param, "正しい値が取得できていない: \(param)")
                }
            }
        }
    }

    func test_getIntegerFromUserDefaults() {
        let param = 1

        XCTContext.runActivity(named: "未設定の場合") { _ in
            UserDefaultsKey.allCases.forEach {
                if $0.isInteger() {
                    XCTAssertEqual(dataStore.integer(forKey: $0), 0, "値を取得できてはいけない")
                }
            }
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            mock.integerHandler = { key in
                return param
            }
            UserDefaultsKey.allCases.forEach {
                if $0.isString() {
                    XCTAssertEqual(dataStore.integer(forKey: $0), param, "正しい値が取得できていない: \(param)")
                }
            }
        }
    }

    func test_setBoolToUserDefaults() {
        var i = 0

        XCTContext.runActivity(named: "Trueを設定した場合") { _ in
            UserDefaultsKey.allCases.forEach {
                if $0.isBool() {
                    i += 1
                    dataStore.set(true, forKey: $0)
                    XCTAssertEqual(mock.setValueCallCount, i, "設定回数が\(i)回になっていない")
                }
            }
        }

        XCTContext.runActivity(named: "Falseを設定した場合") { _ in
            UserDefaultsKey.allCases.forEach {
                if $0.isBool() {
                    i += 1
                    dataStore.set(false, forKey: $0)
                    XCTAssertEqual(mock.setValueCallCount, i, "設定回数が\(i)回になっていない")
                }
            }
        }
    }

    func test_setStringToUserDefaults() {
        var i = 0
        let param = "test"

        XCTContext.runActivity(named: "\(param)を設定した場合") { _ in
            UserDefaultsKey.allCases.forEach {
                if $0.isString() {
                    i += 1
                    dataStore.set(param, forKey: $0)
                    XCTAssertEqual(mock.setValueForKeyCallCount, i, "設定回数が\(i)回になっていない")
                }
            }
        }
    }

    func test_setIntegerToUserDefaults() {
        var i = 0
        let param = 1

        XCTContext.runActivity(named: "\(param)を設定した場合") { _ in
            UserDefaultsKey.allCases.forEach {
                if $0.isInteger() {
                    i += 1
                    dataStore.set(param, forKey: $0)
                    XCTAssertEqual(mock.setCallCount, i, "設定回数が\(i)回になっていない")
                }
            }
        }
    }
}
