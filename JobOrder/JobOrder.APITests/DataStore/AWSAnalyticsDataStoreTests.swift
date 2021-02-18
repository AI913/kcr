//
//  AWSAnalyticsDataStoreTests.swift
//  JobOrder.APITests
//
//  Created by Yu Suzuki on 2020/08/04.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_API
@testable import AWSPinpoint

class AWSAnalyticsDataStoreTests: XCTestCase {

    private let ms1000 = 1.0
    private let notification = AWSPinpointNotificationManagerProtocolMock()
    private let targetClient = AWSPinpointTargetingClientProtocolMock()
    private let analyticsClient = AWSAnalyticsClientProtocolMock()
    private let dataStore = AWSAnalyticsDataStore()

    override func setUpWithError() throws {
        dataStore.factory.pinpointNotificationManager = notification
        dataStore.factory.pinpointTargetClient = targetClient
        dataStore.factory.analyticsClient = analyticsClient

        targetClient.currentEndpointProfileHandler = { return AWSPinpointEndpointProfile() }
        targetClient.updateEndpointProfileHandler = { return AWSTask() }
        analyticsClient.createEventHandler = { eventType in return AWSPinpointEvent() }
        analyticsClient.recordHandler = { event in return AWSTask() }
        analyticsClient.submitEventsHandler = { return AWSTask() }
    }

    override func tearDownWithError() throws {}

    func test_endpointId () {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertEqual(dataStore.endpointId, "", "空文字を取得できなければいけない")
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            targetClient.currentEndpointProfileHandler = {
                return AWSPinpointEndpointProfile(applicationId: param, endpointId: param)
            }
            XCTAssertEqual(dataStore.endpointId, param, "\(param)を取得できなければいけない")
        }
    }

    func test_registerDevice() {
        dataStore.registerDevice(Data())
        XCTAssertEqual(notification.interceptDidRegisterForRemoteNotificationsCallCount, 1, "AWSPinpointTargetingClientのメソッドが呼ばれなくてはいけない")
    }

    func test_passRemoteNotificationEvent() {
        dataStore.passRemoteNotificationEvent([:])
        XCTAssertEqual(notification.interceptDidReceiveRemoteNotificationCallCount, 1, "AWSPinpointTargetingClientのメソッドが呼ばれなくてはいけない")
    }

    func test_updateEndpointProfile() {
        let param = "test"

        dataStore.updateEndpointProfile(param, value: param)
        XCTAssertEqual(targetClient.addAttributeCallCount, 1, "AWSPinpointTargetingClientのメソッドが呼ばれなくてはいけない")
        XCTAssertEqual(targetClient.updateEndpointProfileCallCount, 1, "AWSPinpointTargetingClientのメソッドが呼ばれなくてはいけない")
    }

    func test_recordEvent() {
        let param = "test"

        dataStore.recordEvent(param, parameters: nil, metrics: nil)
        XCTAssertEqual(analyticsClient.createEventCallCount, 1, "AWSAnalyticsClientのメソッドが呼ばれなくてはいけない")
        XCTAssertEqual(analyticsClient.recordCallCount, 1, "AWSAnalyticsClientのメソッドが呼ばれなくてはいけない")
        XCTAssertEqual(analyticsClient.submitEventsCallCount, 1, "AWSAnalyticsClientのメソッドが呼ばれなくてはいけない")
    }
}
