//
//  SettingsUseCaseTests.swift
//  JobOrder.DomainTests
//
//  Created by Yu Suzuki on 2020/08/07.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import JobOrder_Data
@testable import JobOrder_Domain

class SettingsUseCaseTests: XCTestCase {

    private let mock = JobOrder_Data.SettingsRepositoryMock()
    private lazy var useCase = SettingsUseCase(repository: mock)

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_restoreIdentifier() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(useCase.restoreIdentifier, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Trueが設定済みの場合") { _ in
            mock.restoreIdentifier = true
            XCTAssertTrue(useCase.restoreIdentifier, "無効になってはいけない")
        }

        XCTContext.runActivity(named: "Falseが設定済みの場合") { _ in
            mock.restoreIdentifier = false
            XCTAssertFalse(useCase.restoreIdentifier, "有効になってはいけない")
        }
    }

    func test_restoreIdentifierWithTrue() {
        useCase.restoreIdentifier = true
        XCTAssertEqual(mock.restoreIdentifierSetCallCount, 1, "SettingsRepositoryのメソッドが呼ばれない")
    }

    func test_restoreIdentifierWithFalse() {
        useCase.restoreIdentifier = false
        XCTAssertEqual(mock.restoreIdentifierSetCallCount, 1, "SettingsRepositoryのメソッドが呼ばれない")
    }

    func test_useBiometricsAuthentication() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(useCase.useBiometricsAuthentication, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Trueを設定した場合") { _ in
            useCase.useBiometricsAuthentication = true
            XCTAssertEqual(mock.useBiometricsAuthenticationSetCallCount, 1, "SettingsRepositoryのメソッドが呼ばれない")
        }

        XCTContext.runActivity(named: "Falseが設定済みの場合") { _ in
            mock.useBiometricsAuthentication = false
            XCTAssertFalse(useCase.useBiometricsAuthentication, "有効になってはいけない")
        }
    }

    func test_useBiometricsAuthenticationWithTrue() {
        useCase.useBiometricsAuthentication = true
        XCTAssertEqual(mock.useBiometricsAuthenticationSetCallCount, 1, "SettingsRepositoryのメソッドが呼ばれない")
    }

    func test_useBiometricsAuthenticationWithFalse() {
        useCase.useBiometricsAuthentication = false
        XCTAssertEqual(mock.useBiometricsAuthenticationSetCallCount, 1, "SettingsRepositoryのメソッドが呼ばれない")
    }

    func test_lastSynced() {
        let param = 1

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(useCase.lastSynced, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            mock.lastSynced = param
            XCTAssertEqual(useCase.lastSynced, param, "正しい値が取得できていない: \(param)")
        }
    }

    func test_spaceName() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(useCase.spaceName, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "\(param)を設定した場合") { _ in
            useCase.spaceName = param
            XCTAssertEqual(mock.spaceSetCallCount, 1, "SettingsRepositoryのメソッドが呼ばれない")
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            mock.space = param
            XCTAssertEqual(useCase.spaceName, param, "正しい値が取得できていない: \(param)")
        }
    }

    func test_useCloudServer() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(useCase.useCloudServer, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Trueが設定済みの場合") { _ in
            mock.useCloudServer = true
            XCTAssertTrue(useCase.useCloudServer, "無効になってはいけない")
        }

        XCTContext.runActivity(named: "Falseが設定済みの場合") { _ in
            mock.useCloudServer = false
            XCTAssertFalse(useCase.useCloudServer, "有効になってはいけない")
        }
    }

    func test_useCloudServerWithTrue() {
        useCase.useCloudServer = true
        XCTAssertEqual(mock.useCloudServerSetCallCount, 1, "SettingsRepositoryのメソッドが呼ばれない")
    }

    func test_useCloudServerWithFalse() {
        useCase.useCloudServer = false
        XCTAssertEqual(mock.useCloudServerSetCallCount, 1, "SettingsRepositoryのメソッドが呼ばれない")
    }

    func test_serverUrl() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(useCase.serverUrl, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "\(param)を設定した場合") { _ in
            useCase.serverUrl = param
            XCTAssertEqual(mock.serverUrlSetCallCount, 1, "SettingsRepositoryのメソッドが呼ばれない")
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            mock.serverUrl = param
            XCTAssertEqual(useCase.serverUrl, param, "正しい値が取得できていない: \(param)")
        }
    }

    func test_thingName() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(useCase.thingName, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            mock.thingName = param
            XCTAssertEqual(useCase.thingName, param, "正しい値が取得できていない: \(param)")
        }
    }
}
