//
//  AnalyticsUseCaseTests.swift
//  JobOrder.DomainTests
//
//  Created by Yu Suzuki on 2020/08/07.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_API
@testable import JobOrder_Domain

class AnalyticsUseCaseTests: XCTestCase {

    private let mock = JobOrder_API.AnalyticsServiceRepositoryMock()
    private lazy var useCase = AnalyticsUseCase(analyticsServiceRepository: mock)

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_endpointId() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(useCase.endpointId, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            mock.endpointId = param
            XCTAssertEqual(useCase.endpointId, param, "正しい値が取得できていない: \(param)")
        }
    }

    func test_setDisplayAppearance() {
        let param = "test"

        XCTContext.runActivity(named: "\(param)を設定した場合") { _ in
            useCase.setDisplayAppearance(param)
            XCTAssertEqual(mock.updateEndpointProfileCallCount, 1, "AnalyticsRepositoryのメソッドが呼ばれない")
        }
    }

    func test_setUserName() {
        let param = "test"

        XCTContext.runActivity(named: "\(param)を設定した場合") { _ in
            useCase.setUserName(param)
            XCTAssertEqual(mock.updateEndpointProfileCallCount, 1, "AnalyticsRepositoryのメソッドが呼ばれない")
        }
    }

    func test_setBiometricsSetting() {
        var param = true

        XCTContext.runActivity(named: "\(param)を設定した場合") { _ in
            useCase.setBiometricsSetting(param)
            XCTAssertEqual(mock.updateEndpointProfileCallCount, 1, "AnalyticsRepositoryのメソッドが呼ばれない")
        }

        param = false
        XCTContext.runActivity(named: "\(param)を設定した場合") { _ in
            useCase.setBiometricsSetting(param)
            XCTAssertEqual(mock.updateEndpointProfileCallCount, 2, "AnalyticsRepositoryのメソッドが呼ばれない")
        }
    }

    func test_recordEventButton() {
        let param1 = "test", param2 = "test"

        XCTContext.runActivity(named: "\(param1), \(param2)を設定した場合") { _ in
            useCase.recordEventButton(name: param1, view: param2)
            XCTAssertEqual(mock.recordEventCallCount, 1, "AnalyticsRepositoryのメソッドが呼ばれない")
        }
    }

    func test_recordEventSwitch() {
        let param1 = "test", param2 = "test"
        var isOn = true

        XCTContext.runActivity(named: "name: \(param1), view: \(param2), isOn: \(isOn)を設定した場合") { _ in
            useCase.recordEventSwitch(name: param1, view: param2, isOn: isOn)
            XCTAssertEqual(mock.recordEventCallCount, 1, "AnalyticsRepositoryのメソッドが呼ばれない")
        }

        isOn = false
        XCTContext.runActivity(named: "name: \(param1), view: \(param2), isOn: \(isOn)を設定した場合") { _ in
            useCase.recordEventSwitch(name: param1, view: param2, isOn: isOn)
            XCTAssertEqual(mock.recordEventCallCount, 2, "AnalyticsRepositoryのメソッドが呼ばれない")
        }
    }
}
