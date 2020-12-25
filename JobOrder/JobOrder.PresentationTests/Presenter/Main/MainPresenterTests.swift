//
//  MainPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class MainPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let vc = MainTabBarControllerProtocolMock()
    private let auth = JobOrder_Domain.AuthenticationUseCaseProtocolMock()
    private let mqtt = JobOrder_Domain.MQTTUseCaseProtocolMock()
    private let settings = JobOrder_Domain.SettingsUseCaseProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let analytics = JobOrder_Domain.AnalyticsUseCaseProtocolMock()
    private lazy var presenter = MainPresenter(authUseCase: auth,
                                               mqttUseCase: mqtt,
                                               settingsUseCase: settings,
                                               dataUseCase: data,
                                               analyticsUseCase: analytics,
                                               vc: vc)
    override func setUpWithError() throws {
        auth.registerAuthenticationStateChangeHandler = {
            return Future<JobOrder_Domain.AuthenticationModel.Output.AuthenticationState, Never> { promise in }.eraseToAnyPublisher()
        }
        mqtt.registerConnectionStatusChangeHandler = {
            return Future<JobOrder_Domain.MQTTModel.Output.ConnectionStatus, Never> { promise in }.eraseToAnyPublisher()
        }
        mqtt.connectHandler = {
            return Future<MQTTModel.Output.Connect, Error> { promise in }.eraseToAnyPublisher()
        }
        data.syncDataHandler = {
            return Future<DataManageModel.Output.SyncData, Error> { promise in }.eraseToAnyPublisher()
        }
    }

    override func tearDownWithError() throws {}

    func test_setAnalyticsEndpointProfiles() {
        let param = "test"

        XCTContext.runActivity(named: "Usernameが未設定の場合") { _ in
            presenter.setAnalyticsEndpointProfiles(displayAppearance: param)
            XCTAssertEqual(analytics.setDisplayAppearanceCallCount, 1, "AnalyticsUseCaseのメソッドが呼ばれない")
            XCTAssertEqual(analytics.setBiometricsSettingCallCount, 1, "AnalyticsUseCaseのメソッドが呼ばれない")
            XCTAssertEqual(analytics.setUserNameCallCount, 0, "ViewControllerのメソッドが呼ばれてしまう")
        }

        XCTContext.runActivity(named: "Usernameが設定済みの場合") { _ in
            auth.currentUsername = "test"
            presenter.setAnalyticsEndpointProfiles(displayAppearance: param)
            XCTAssertEqual(analytics.setDisplayAppearanceCallCount, 2, "AnalyticsUseCaseのメソッドが呼ばれない")
            XCTAssertEqual(analytics.setBiometricsSettingCallCount, 2, "AnalyticsUseCaseのメソッドが呼ばれない")
            XCTAssertEqual(analytics.setUserNameCallCount, 1, "ViewControllerのメソッドが呼ばれない")
        }
    }

    func test_viewDidAppear() {

        XCTContext.runActivity(named: "初回") { _ in
            presenter.viewDidAppear()
            XCTAssertEqual(vc.launchPasswordAuthenticationCallCount, 1, "ViewControllerのメソッドが呼ばれない")
        }

        XCTContext.runActivity(named: "2回目以降") { _ in
            presenter.viewDidAppear()
            XCTAssertEqual(vc.launchPasswordAuthenticationCallCount, 1, "ViewControllerのメソッドが呼ばれてしまう")
        }
    }

    func test_tapConnectionStatusButton() {
        presenter.tapConnectionStatusButton()
        XCTAssertEqual(vc.showAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_registerStateChangesNotReceivedAuthenticationState() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.registerAuthenticationStateChangeHandler = {
            return Future<AuthenticationModel.Output.AuthenticationState, Never> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = MainPresenter(authUseCase: auth,
                                  mqttUseCase: mqtt,
                                  settingsUseCase: settings,
                                  dataUseCase: data,
                                  analyticsUseCase: analytics,
                                  vc: vc)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.launchPasswordAuthenticationCallCount, 0, "ViewControllerのメソッドが呼ばれてしまう")
        XCTAssertEqual(mqtt.connectCallCount, 0, "MQTTUseCaseのメソッドが呼ばれてしまう")
        XCTAssertEqual(data.syncDataCallCount, 0, "DataManageUseCaseのメソッドが呼ばれてしまう")
    }

    func test_registerStateChangesReceivedAuthenticationState() {
        var signedInCallCount = 0
        var signedOutCallCount = 0

        JobOrder_Domain.AuthenticationModel.Output.AuthenticationState.allCases.forEach { state in
            let handlerExpectation = expectation(description: "handler \(state)")
            let completionExpectation = expectation(description: "completion \(state)")
            completionExpectation.isInverted = true

            auth.registerAuthenticationStateChangeHandler = {
                return Future<AuthenticationModel.Output.AuthenticationState, Never> { promise in
                    promise(.success(state))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            // 初期化時に登録
            presenter = MainPresenter(authUseCase: auth,
                                      mqttUseCase: mqtt,
                                      settingsUseCase: settings,
                                      dataUseCase: data,
                                      analyticsUseCase: analytics,
                                      vc: vc)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

            switch state {
            case .signedIn:
                signedInCallCount += 1
            case .signedOut, .signedOutUserPoolsTokenInvalid, .signedOutFederatedTokensInvalid:
                signedOutCallCount += 1
            default: break
            }
            XCTAssertEqual(vc.launchPasswordAuthenticationCallCount, signedOutCallCount, "ViewControllerのメソッドが呼ばれない")
            XCTAssertEqual(mqtt.connectCallCount, signedInCallCount, "MQTTUseCaseのメソッドが呼ばれない")
            XCTAssertEqual(data.syncDataCallCount, signedInCallCount, "DataManageUseCaseのメソッドが呼ばれない")
        }
    }

    func test_registerStateChangesNotReceivedConnectionStatus() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mqtt.registerConnectionStatusChangeHandler = {
            return Future<MQTTModel.Output.ConnectionStatus, Never> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = MainPresenter(authUseCase: auth,
                                  mqttUseCase: mqtt,
                                  settingsUseCase: settings,
                                  dataUseCase: data,
                                  analyticsUseCase: analytics,
                                  vc: vc)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.updateConnectionStatusButtonCallCount, 0, "ViewControllerのメソッドが呼ばれてしまう")
    }

    func test_registerStateChangesReceivedConnectionStatus() {
        var callCount = 0
        JobOrder_Domain.MQTTModel.Output.ConnectionStatus.allCases.forEach { status in
            let handlerExpectation = expectation(description: "handler \(status)")
            let completionExpectation = expectation(description: "completion \(status)")
            completionExpectation.isInverted = true
            callCount += 1

            mqtt.registerConnectionStatusChangeHandler = {
                return Future<MQTTModel.Output.ConnectionStatus, Never> { promise in
                    promise(.success(status))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            // 初期化時に登録
            presenter = MainPresenter(authUseCase: auth,
                                      mqttUseCase: mqtt,
                                      settingsUseCase: settings,
                                      dataUseCase: data,
                                      analyticsUseCase: analytics,
                                      vc: vc)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            XCTAssertEqual(vc.updateConnectionStatusButtonCallCount, callCount, "ViewControllerのメソッドが呼ばれない")
        }
    }

    func test_connectToIotClient() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion success")
        completionExpectation.isInverted = true
        presenter.data = MainViewData.ConnectionInfo(.disconnected)
        mqtt.processing = false

        mqtt.connectHandler = {
            return Future<JobOrder_Domain.MQTTModel.Output.Connect, Error> { promise in
                promise(.success(.init(result: false)))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.connectToIotClient()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        // 何もしない
    }

    func test_connectToIotClientWithConnectingCheck() {
        var callCount = 0

        JobOrder_Domain.MQTTModel.Output.ConnectionStatus.allCases.forEach { status in
            let completionExpectation = expectation(description: "connect \(status)")
            completionExpectation.isInverted = true
            presenter.data = MainViewData.ConnectionInfo(status)
            mqtt.processing = false

            presenter.connectToIotClient()

            wait(for: [completionExpectation], timeout: ms1000)

            switch status {
            case .connected, .connecting: break
            default:
                callCount += 1
            }
            XCTAssertEqual(mqtt.connectCallCount, callCount, "MQTTUseCaseのメソッドが呼ばれない")
        }
    }

    func test_connectToIotClientWithProcessing() {
        let completionExpectation = expectation(description: "completion connect processing")
        completionExpectation.isInverted = true
        presenter.data = MainViewData.ConnectionInfo(.disconnected)
        mqtt.processing = true

        presenter.connectToIotClient()

        wait(for: [completionExpectation], timeout: ms1000)
        XCTAssertEqual(mqtt.connectCallCount, 0, "MQTTUseCaseのメソッドが呼ばれてしまう")
    }

    func test_connectToIotClientWithoutProcessing() {
        let completionExpectation = expectation(description: "connect not processing")
        completionExpectation.isInverted = true
        presenter.data = MainViewData.ConnectionInfo(.disconnected)
        mqtt.processing = false

        presenter.connectToIotClient()

        wait(for: [completionExpectation], timeout: ms1000)
        XCTAssertEqual(mqtt.connectCallCount, 1, "MQTTUseCaseのメソッドが呼ばれない")
    }

    func test_connectToIotClientError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion error")
        completionExpectation.isInverted = true
        presenter.data = MainViewData.ConnectionInfo(.disconnected)
        mqtt.processing = false

        mqtt.connectHandler = {
            return Future<JobOrder_Domain.MQTTModel.Output.Connect, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.connectToIotClient()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_connectToIotClientFailed() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion failed")
        completionExpectation.isInverted = true
        presenter.data = MainViewData.ConnectionInfo(.disconnected)
        mqtt.processing = false

        mqtt.connectHandler = {
            return Future<JobOrder_Domain.MQTTModel.Output.Connect, Error> { promise in
                promise(.success(.init(result: false)))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.connectToIotClient()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        // TODO: エラーケース
    }

    func test_sync() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        data.syncDataHandler = {
            return Future<JobOrder_Domain.DataManageModel.Output.SyncData, Error> { promise in
                let model = JobOrder_Domain.DataManageModel.Output.SyncData(jobEntities: [],
                                                                            robotEntities: [],
                                                                            actionLibraryEntities: [],
                                                                            aiLibraryEntities: [])
                promise(.success(model))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.sync()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(mqtt.subscribeRobotsCallCount, 1, "MQTTUseCaseのメソッドが呼ばれない")
    }

    func test_syncError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion error")
        completionExpectation.isInverted = true

        data.syncDataHandler = {
            return Future<JobOrder_Domain.DataManageModel.Output.SyncData, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.sync()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }
}
