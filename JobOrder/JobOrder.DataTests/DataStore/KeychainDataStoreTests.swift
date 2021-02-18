//
//  KeychainDataStoreTests.swift
//  JobOrder.DataTests
//
//  Created by Yu Suzuki on 2020/07/20.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Data

class KeychainDataStoreTests: XCTestCase {

    private let mock = KeychainProtocolMock()
    private let dataStore = KeychainDataStore()

    override func setUpWithError() throws {
        dataStore.keychain = mock
    }

    override func tearDownWithError() throws {}

    func test_getString() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            KeychainKey.allCases.forEach {
                XCTAssertNil(dataStore.getString($0), "値を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "値が設定済みの場合") { _ in
            KeychainKey.allCases.forEach {
                mock.subscriptHandler = { key in
                    return "\(key)"
                }
                XCTAssertEqual(dataStore.getString($0), $0.key, "正しい値が取得できていない: \($0.key)")
            }
        }
    }

    func test_getData() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            KeychainKey.allCases.forEach {
                XCTAssertNil(dataStore.getData($0), "値を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "値が設定済みの場合") { _ in
            KeychainKey.allCases.forEach {
                mock.subscriptDataHandler = { key in
                    return Data()
                }
                XCTAssertEqual(dataStore.getData($0), Data(), "正しい値が取得できていない")
            }
        }
    }

    func test_setString() {
        let param = "test"
        var i = 0

        XCTContext.runActivity(named: "\(param)を設定した場合") { _ in
            KeychainKey.allCases.forEach {
                i += 1
                dataStore.set(param, key: $0)
                // TODO: Mockoloのバグ Subscriptのセッターモックが作成されない
                // XCTAssertEqual(mock.subscriptCallCount, i, "設定回数が\(i)回になっていない")
                XCTAssertEqual(mock.subscriptCallCount, 0, "設定回数が\(0)回になっていない")
            }
        }
    }

    func test_setData() {
        let param = Data()
        var i = 0

        XCTContext.runActivity(named: "\(param)を設定した場合") { _ in
            KeychainKey.allCases.forEach {
                i += 1
                dataStore.set(param, key: $0)
                // TODO: Mockoloのバグ Subscriptのセッターモックが作成されない
                // XCTAssertEqual(mock.subscriptCallCount, i, "設定回数が\(i)回になっていない")
                XCTAssertEqual(mock.subscriptCallCount, 0, "設定回数が\(0)回になっていない")
            }
        }
    }
}
