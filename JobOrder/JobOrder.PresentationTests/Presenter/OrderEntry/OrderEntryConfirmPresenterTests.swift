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
    @Published private var processing: Bool = false
    private let vc = OrderEntryConfirmViewControllerProtocolMock()
    private let mqtt = JobOrder_Domain.MQTTUseCaseProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let viewData = OrderEntryViewData(nil, nil)
    private lazy var presenter = OrderEntryConfirmPresenter(dataUseCase: data,
                                                            vc: vc,
                                                            viewData: viewData)

    override func setUpWithError() throws {
        data.processingPublisher = $processing
    }

    override func tearDownWithError() throws {}

    func test_job() {
        let jobs = DataManageModel.Output.Job.arbitrary.sample
        let obj = jobs.randomElement()!
        let param = obj.id
        XCTContext.runActivity(named: "指定のJobが見つからなかった場合") { _ in
            presenter.data.form.jobId = param
            XCTAssertNil(presenter.job, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "指定のJobが見つかった場合") { _ in
            presenter.data.form.jobId = param
            data.jobs = jobs
            XCTAssertEqual(presenter.job, obj.name, "正常に値が設定されていない")
        }
    }

    func test_robots() {

        XCTContext.runActivity(named: "指定のRobotがnilの場合") { _ in
            presenter.data.form.robotIds = nil
            XCTAssertNil(presenter.robots, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "指定のJobが見つかった場合") { _ in
            presenter.data.form.robotIds = ["test1", "test2"]
            data.robots = [
                DataManageModel.Output.Robot.pattern(id: "test1", name: "name1").generate,
                DataManageModel.Output.Robot.pattern(id: "test2", name: "name2").generate
            ]
            XCTAssertEqual(presenter.robots, "name1\nname2", "正常に値が設定されていない")
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

        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let task = DataManageModel.Output.Task.arbitrary.generate

        data.postTaskHandler = { postData in
            return Future<DataManageModel.Output.Task, Error> { promise in
                promise(.success(task))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.data.form.jobId = task.jobId
        presenter.data.form.robotIds = task.robotIds
        presenter.data.form.startCondition = OrderEntryViewData.Form.StartCondition.immediately
        presenter.data.form.exitCondition = OrderEntryViewData.Form.ExitCondition.specifiedNumberOfTimes
        presenter.data.form.numberOfRuns = 1

        data.robots = DataManageModel.Output.Robot.arbitrary.sample
        presenter.tapSendButton()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.transitionToCompleteScreenCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_tapSendButtonNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        handlerExpectation.isInverted = true
        completionExpectation.isInverted = true
        let task = DataManageModel.Output.Task.arbitrary.generate

        data.postTaskHandler = { postData in
            return Future<DataManageModel.Output.Task, Error> { promise in
                promise(.success(task))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.data.form.robotIds = nil
        presenter.data.form.jobId = nil
        presenter.data.form.startCondition = nil
        presenter.data.form.exitCondition = nil
        presenter.data.form.numberOfRuns = 0

        data.robots = nil
        presenter.tapSendButton()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(data.postTaskCallCount, 0, "DatabaseUseCaseのメソッドが呼ばれてしまう")
    }

    func test_tapSendButtonError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let task = DataManageModel.Output.Task.arbitrary.generate

        data.postTaskHandler = { postData in
            return Future<DataManageModel.Output.Task, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.data.form.jobId = task.jobId
        presenter.data.form.robotIds = task.robotIds
        presenter.data.form.startCondition = OrderEntryViewData.Form.StartCondition.immediately
        presenter.data.form.exitCondition = OrderEntryViewData.Form.ExitCondition.specifiedNumberOfTimes
        presenter.data.form.numberOfRuns = 1

        data.robots = DataManageModel.Output.Robot.arbitrary.sample
        presenter.tapSendButton()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_subscribeUseCaseProcessing() {
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        // 初期化時に登録
        presenter = OrderEntryConfirmPresenter(dataUseCase: data,
                                               vc: vc,
                                               viewData: viewData)

        wait(for: [completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.changedProcessingCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }
}
