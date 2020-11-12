//
//  SettingsDataStoreTests.swift
//  JobOrder.DataTests
//
//  Created by Yu Suzuki on 2020/07/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Data

class SettingsDataStoreTests: XCTestCase {

    private let ud = UserDefaultsRepositoryMock()
    private let kc = KeychainRepositoryMock()
    private lazy var dataStore = SettingsDataStore(ud: ud, keychain: kc)

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_getRestoreIdentifier() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(dataStore.restoreIdentifier, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Trueが設定済みの場合") { _ in
            ud.boolHandler = { key in
                return true
            }
            XCTAssertTrue(dataStore.restoreIdentifier, "無効になってはいけない")
        }

        XCTContext.runActivity(named: "Falseが設定済みの場合") { _ in
            ud.boolHandler = { key in
                return false
            }
            XCTAssertFalse(dataStore.restoreIdentifier, "有効になってはいけない")
        }
    }

    func test_getUseBiometricsAuthentication() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(dataStore.useBiometricsAuthentication, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Trueが設定済みの場合") { _ in
            ud.boolHandler = { key in
                return true
            }
            XCTAssertTrue(dataStore.useBiometricsAuthentication, "無効になってはいけない")
        }

        XCTContext.runActivity(named: "Falseが設定済みの場合") { _ in
            ud.boolHandler = { key in
                return false
            }
            XCTAssertFalse(dataStore.useBiometricsAuthentication, "有効になってはいけない")
        }
    }

    func test_getLastSynced() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            let param = 0
            XCTAssertEqual(dataStore.lastSynced, param, "正しい値が取得できていない: \(param)")
        }

        let param = 1
        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            ud.integerHandler = { key in
                return param
            }
            XCTAssertEqual(dataStore.lastSynced, param, "正しい値が取得できていない: \(param)")
        }
    }

    func test_getSpace() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(dataStore.space, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            ud.stringHandler = { key in
                return param
            }
            XCTAssertEqual(dataStore.space, param, "正しい値が取得できていない: \(param)")
        }
    }

    func test_getUseCloudServer() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(dataStore.useCloudServer, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Trueが設定済みの場合") { _ in
            ud.boolHandler = { key in
                return true
            }
            XCTAssertTrue(dataStore.useCloudServer, "無効になってはいけない")
        }

        XCTContext.runActivity(named: "Falseが設定済みの場合") { _ in
            ud.boolHandler = { key in
                return false
            }
            XCTAssertFalse(dataStore.useCloudServer, "有効になってはいけない")
        }
    }

    func test_getServerUrl() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(dataStore.serverUrl, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            ud.stringHandler = { key in
                return param
            }
            XCTAssertEqual(dataStore.serverUrl, param, "正しい値が取得できていない: \(param)")
        }
    }

    func test_getThingName() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(dataStore.thingName, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            kc.getStringHandler = { key in
                return param
            }
            XCTAssertEqual(dataStore.thingName, param, "正しい値が取得できていない: \(param)")
        }
    }

    func test_setRestoreIdentifierWithTrue() {
        dataStore.restoreIdentifier = true
        XCTAssertEqual(ud.setValueCallCount, 1, "UserDefaultsRepositoryのメソッドが呼ばれない")
    }

    func test_setRestoreIdentifierWithFalse() {
        dataStore.restoreIdentifier = false
        XCTAssertEqual(ud.setValueCallCount, 1, "UserDefaultsRepositoryのメソッドが呼ばれない")
    }

    func test_setUseBiometricsAuthenticationWithTrue() {
        dataStore.useBiometricsAuthentication = true
        XCTAssertEqual(ud.setValueCallCount, 1, "UserDefaultsRepositoryのメソッドが呼ばれない")
    }

    func test_setUseBiometricsAuthenticationWithFalse() {
        dataStore.useBiometricsAuthentication = false
        XCTAssertEqual(ud.setValueCallCount, 1, "UserDefaultsRepositoryのメソッドが呼ばれない")
    }

    func test_setSpace() {
        let param = "test"

        XCTContext.runActivity(named: "\(param)を設定した場合") { _ in
            dataStore.space = param
            XCTAssertEqual(ud.setValueForKeyCallCount, 1, "UserDefaultsRepositoryのメソッドが呼ばれない")
        }
    }

    func test_setUseCloudServerWithTrue() {
        dataStore.useCloudServer = true
        XCTAssertEqual(ud.setValueCallCount, 1, "UserDefaultsRepositoryのメソッドが呼ばれない")
    }

    func test_setUseCloudServerWithFalse() {
        dataStore.useCloudServer = false
        XCTAssertEqual(ud.setValueCallCount, 1, "UserDefaultsRepositoryのメソッドが呼ばれない")
    }

    func test_setServerUrl() {
        let param = "test"

        XCTContext.runActivity(named: "\(param)を設定した場合") { _ in
            dataStore.serverUrl = param
            XCTAssertEqual(ud.setValueForKeyCallCount, 1, "UserDefaultsRepositoryのメソッドが呼ばれない")
        }
    }
}
