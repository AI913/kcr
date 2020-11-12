//
//  OrderEntryConfirmPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class OrderEntryConfirmPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let stub = PresentationTestsStub()
    @Published private var processing: Bool = false
    private let vc = OrderEntryConfirmViewControllerProtocolMock()
    private let mqtt = JobOrder_Domain.MQTTUseCaseProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let viewData = OrderEntryViewData(nil, nil)
    private lazy var presenter = OrderEntryConfirmPresenter(mqttUseCase: mqtt,
                                                            dataUseCase: data,
                                                            vc: vc,
                                                            viewData: viewData)

    override func setUpWithError() throws {
        mqtt.processingPublisher = $processing
    }

    override func tearDownWithError() throws {}

    func test_job() {
        let param = "test1"
        XCTContext.runActivity(named: "指定のJobが見つからなかった場合") { _ in
            presenter.data.form.jobId = param
            XCTAssertNil(presenter.job, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "指定のJobが見つかった場合") { _ in
            presenter.data.form.jobId = param
            data.jobs = stub.jobs
            XCTAssertEqual(presenter.job, param, "正常に値が設定されていない")
        }
    }

    func test_robots() {

        XCTContext.runActivity(named: "指定のRobotがnilの場合") { _ in
            presenter.data.form.robotIds = nil
            XCTAssertNil(presenter.robots, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "指定のJobが見つかった場合") { _ in
            presenter.data.form.robotIds = ["test1", "test2"]
            data.robots = stub.robots
            XCTAssertEqual(presenter.robots, "test1\ntest2", "正常に値が設定されていない")
        }
    }

    func test_startCondition() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.data.form.startCondition = nil
            XCTAssertNil(presenter.startCondition, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "設定済みの場合") { _ in
            presenter.data.form.startCondition = OrderEntryViewData.Form.StartCondition(key: "Immediately")
            XCTAssertEqual(presenter.startCondition, "Immediately", "正常に値が設定されていない")
        }

        XCTContext.runActivity(named: "想定外の値が設定されていた場合") { _ in
            presenter.data.form.startCondition = OrderEntryViewData.Form.StartCondition(key: "test")
            XCTAssertEqual(presenter.startCondition, "Unknown", "正常に値が設定されていない")
        }
    }

    func test_exitCondition() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.data.form.exitCondition = nil
            XCTAssertNil(presenter.exitCondition, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "設定済みの場合") { _ in
            presenter.data.form.exitCondition = OrderEntryViewData.Form.ExitCondition(key: "Specified number of times")
            XCTAssertEqual(presenter.exitCondition, "Specified number of times", "正常に値が設定されていない")
        }

        XCTContext.runActivity(named: "想定外の値が設定されていた場合") { _ in
            presenter.data.form.exitCondition = OrderEntryViewData.Form.ExitCondition(key: "test")
            XCTAssertEqual(presenter.exitCondition, "Unknown", "正常に値が設定されていない")
        }
    }

    func test_numberOfRuns() {
        let param = 1

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertEqual(presenter.numberOfRuns, "0", "デフォルト値が取得できていない")
        }

        XCTContext.runActivity(named: "設定済みの場合") { _ in
            presenter.data.form.numberOfRuns = param
            XCTAssertEqual(presenter.numberOfRuns, "\(param)", "正しい値が取得できていない: \(param)")
        }
    }

    func test_remarks() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(presenter.remarks, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "設定済みの場合") { _ in
            presenter.data.form.remarks = param
            XCTAssertEqual(presenter.remarks, param, "正しい値が取得できていない: \(param)")
        }
    }

    func test_tapSendButton() {

        JobOrder_Domain.MQTTModel.Output.CreateJobState.allCases.forEach { state in
            let handlerExpectation = expectation(description: "handler \(state)")
            let completionExpectation = expectation(description: "completion \(state)")
            completionExpectation.isInverted = true

            mqtt.createJobHandler = { targets, jobId, form in
                return Future<JobOrder_Domain.MQTTModel.Output.CreateJobState, Error> { promise in
                    promise(.success(state))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            presenter.data.form.robotIds = ["test1", "test2"]
            data.robots = stub.robots
            presenter.tapSendButton()

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

            switch state {
            case .completed:
                XCTAssertEqual(vc.transitionToCompleteScreenCallCount, 1, "ViewControllerのメソッドが呼ばれない")
            default: break
            // TODO: エラーケース
            }
        }
    }

    func test_tapSendButtonNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        handlerExpectation.isInverted = true
        completionExpectation.isInverted = true

        mqtt.createJobHandler = { targets, jobId, form in
            return Future<JobOrder_Domain.MQTTModel.Output.CreateJobState, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.data.form.robotIds = nil
        data.robots = nil
        presenter.tapSendButton()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(mqtt.createJobCallCount, 0, "MQTTUseCaseのメソッドが呼ばれてしまう")
    }

    func test_tapSendButtonError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mqtt.createJobHandler = { targets, jobId, form in
            return Future<JobOrder_Domain.MQTTModel.Output.CreateJobState, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.data.form.robotIds = ["test1", "test2"]
        data.robots = stub.robots
        presenter.tapSendButton()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_subscribeUseCaseProcessing() {
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        // 初期化時に登録
        presenter = OrderEntryConfirmPresenter(mqttUseCase: mqtt,
                                               dataUseCase: data,
                                               vc: vc,
                                               viewData: viewData)

        wait(for: [completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.changedProcessingCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }
}
