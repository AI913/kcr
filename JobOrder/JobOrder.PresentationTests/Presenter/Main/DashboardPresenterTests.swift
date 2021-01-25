//
//  DashboardPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class DashboardPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let vc = DashboardViewControllerProtocolMock()
    private let mqtt = JobOrder_Domain.MQTTUseCaseProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private lazy var presenter = DashboardPresenter(mqttUseCase: mqtt,
                                                    dataUseCase: data,
                                                    vc: vc)
    override func setUpWithError() throws {
        mqtt.registerConnectionStatusChangeHandler = {
            return Future<JobOrder_Domain.MQTTModel.Output.ConnectionStatus, Never> { promise in }.eraseToAnyPublisher()
        }
        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in }.eraseToAnyPublisher()
        }
    }

    override func tearDownWithError() throws {}

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
        presenter = DashboardPresenter(mqttUseCase: mqtt,
                                       dataUseCase: data,
                                       vc: vc)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.updateExecutionChartCallCount, 0, "ViewControllerのメソッドが呼ばれてしまう")
    }

    func test_registerStateChangesReceived() {
        var callCount = 0

        JobOrder_Domain.MQTTModel.Output.ConnectionStatus.allCases.forEach { status in
            let handlerExpectation = expectation(description: "handler \(status)")
            let completionExpectation = expectation(description: "completion \(status)")
            completionExpectation.isInverted = true

            mqtt.registerConnectionStatusChangeHandler = {
                return Future<MQTTModel.Output.ConnectionStatus, Never> { promise in
                    promise(.success(status))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            // 初期化時に登録
            presenter = DashboardPresenter(mqttUseCase: mqtt,
                                           dataUseCase: data,
                                           vc: vc)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

            switch status {
            case .connected: break
            // TODO: Executionは未実装
            default:
                callCount += 1
            }
            XCTAssertEqual(vc.updateExecutionChartCallCount, callCount, "ViewControllerのメソッドが呼ばれない")
        }
    }

    func test_observeRobotsNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        data.robots = DataManageModel.Output.Robot.arbitrary.sample

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = DashboardPresenter(mqttUseCase: mqtt,
                                       dataUseCase: data,
                                       vc: vc)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.updateRobotStatusChartCallCount, 0, "ViewControllerのメソッドが呼ばれてしまう")
    }

    func test_observeRobotsReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let robots = DataManageModel.Output.Robot.arbitrary.sample
        data.robots = robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(robots))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = DashboardPresenter(mqttUseCase: mqtt,
                                       dataUseCase: data,
                                       vc: vc)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.updateRobotStatusChartCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }
}
