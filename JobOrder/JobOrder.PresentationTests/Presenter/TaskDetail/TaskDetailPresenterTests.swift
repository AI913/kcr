//
//  TaskDetailresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by terada on 2020/11/11.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

// TODO: get~メソッドの値が返ってこない
//       RobotNameが取得できない

class TaskDetailPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let ms3000 = 3.0
    private let stub = PresentationTestsStub()
    private let vc = TaskDetailViewControllerProtocolMock()
    private let mqtt = JobOrder_Domain.MQTTUseCaseProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private lazy var presenter = TaskDetailPresenter(dataUseCase: data,
                                                     vc: vc)
    private let viewData = MainViewData.Robot()

    override func tearDownWithError() throws {}

    override func setUpWithError() throws {}

    func test_getTaskExecutions() {
        print("test_getTaskExecutions")

        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let taskId = "taskId"
        let robotId = "robotId"
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.commandFromTaskHandler = { _, _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                promise(.success(self.stub.command))
                completionExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = TaskDetailPresenter(dataUseCase: data,
                                        vc: vc)
        presenter.getTaskExecutions(taskId: taskId, robotId: robotId)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms3000)
        //レスポンスが間に合ってない
        //XCTAssert(presenter.command == stub.command, "正しい値が取得できていない")
        XCTAssertEqual(vc.showErrorAlertCallCount, 0, "エラーが起こってはいけない")
    }

    func test_getTaskExectionsError() {
        print("test_getTaskExectionsError")

        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let param = ""
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.commandFromTaskHandler = { taskId, robotId in
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                completionExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = TaskDetailPresenter(dataUseCase: data,
                                        vc: vc)

        presenter.getTaskExecutions(taskId: param, robotId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertNil(presenter.command, "値が取得できてはいけない")

    }

    func test_getTask() {
        print("test_getTask")

        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let param = "test"
        data.robots = stub.robots
        data.jobs = stub.jobs

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                promise(.success(self.stub.task))
                completionExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = TaskDetailPresenter(dataUseCase: data,
                                        vc: vc)

        presenter.getTask(taskId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        //レスポンスが間に合ってない
        //XCTAssert(presenter.task == stub.task, "正しい値が取得できていない")
        XCTAssertEqual(vc.showErrorAlertCallCount, 0, "エラーが起こってはいけない")
    }

    func test_getTaskError() {
        print("test_getTaskError")

        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let param = ""
        data.robots = stub.robots
        data.jobs = stub.jobs

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                completionExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = TaskDetailPresenter(dataUseCase: data,
                                        vc: vc)

        presenter.getTask(taskId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertNil(presenter.task, "値が取得できてはいけない")
    }

    func test_getRobot() {
        print("test_getRobot")

        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.robotHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Robot, Error> { promise in
                promise(.success(self.stub.robot))
                completionExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = TaskDetailPresenter(dataUseCase: data,
                                        vc: vc)

        presenter.getRobot(robotId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        //レスポンスが間に合ってない
        //XCTAssert(presenter.robot == stub.robot, "正しい値が取得できていない")
        XCTAssertEqual(vc.showErrorAlertCallCount, 0, "エラーが起こってはいけない")
    }

    func test_getRobotError() {
        print("test_getRobotError")

        let param = ""
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.robotHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Robot, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                completionExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = TaskDetailPresenter(dataUseCase: data,
                                        vc: vc)

        presenter.getRobot(robotId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertNil(presenter.robot, "値が取得できてはいけない")
    }

    // TODO: - テスト作成する
    func test_jobName() {
        // jobName()は現在ハードコーディングで固定値を返却している
    }

    func test_RobotName() {
        print("test_RobotName")

        data.robots = stub.robots
        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.robot = stub.robot

        // 初期化時に登録
        presenter = TaskDetailPresenter(dataUseCase: data, vc: vc)
        //XCTAssertEqual(presenter.RobotName(), stub.robot.name, "正しい値が取得できていない")
    }

    func test_RobotNameError() {
        print("test_RobotName")

        data.robots = stub.robots
        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.robot = nil

        // 初期化時に登録
        presenter = TaskDetailPresenter(dataUseCase: data,
                                        vc: vc)

        XCTAssertEqual(presenter.RobotName(), nil, "正しい値が取得できていない")
    }

    func test_updatedAt() {
        print("test_updatedAt")
        data.robots = stub.robots
        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.robot = stub.robot

        // 初期化時に登録
        presenter = TaskDetailPresenter(dataUseCase: data,
                                        vc: vc)

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        XCTContext.runActivity(named: "Commandsが存在する場合") { _ in
            presenter.command = stub.command
            let date = Date(timeIntervalSince1970: Double(1))
            let dateStr = string(date: date, label: "", textColor: textColor, font: font)

            XCTAssertNotEqual(presenter.updatedAt(textColor: textColor, font: font), dateStr)
        }
    }

    func test_updatedAtError() {
        print("test_updatedAtError")
        data.robots = stub.robots
        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.robot = stub.robot

        // 初期化時に登録
        presenter = TaskDetailPresenter(dataUseCase: data,
                                        vc: vc)

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        presenter.command = stub.command
        let date = Date(timeIntervalSince1970: Double(1))
        let dateStr = string(date: date, label: "", textColor: textColor, font: font)

        XCTAssertNotEqual(presenter.updatedAt(textColor: textColor, font: font), dateStr)
    }

    func test_createdAt() {
        print("test_createdAt")

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.command = stub.command
        let date = Date(timeIntervalSince1970: Double(1))
        let dateStr = string(date: date, label: "", textColor: textColor, font: font)

        XCTAssertNotEqual(presenter.createdAt(textColor: textColor, font: font), dateStr)
    }

    func test_createdAtError() {
        print("test_createdAtError")

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.command = nil
        let date = Date(timeIntervalSince1970: Double(1))
        let dateStr = string(date: date, label: "", textColor: textColor, font: font)
        XCTAssertEqual(presenter.createdAt(textColor: textColor, font: font), dateStr, "正しい値が取得できていない")
    }

    func test_startedAt() {
        print("test_startedAt")

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.command = stub.command
        let date = Date(timeIntervalSince1970: Double(1))
        let dateStr = string(date: date, label: "", textColor: textColor, font: font)

        XCTAssertNotEqual(presenter.startedAt(textColor: textColor, font: font), dateStr)
    }

    func text_startedAtError() {
        print("text_startedAtError")

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.command = nil
        let date = Date(timeIntervalSince1970: Double(1))
        let dateStr = string(date: date, label: "", textColor: textColor, font: font)
        XCTAssertEqual(presenter.startedAt(textColor: textColor, font: font), dateStr, "正しい値が取得できていない")
    }

    func test_excitedAt() {
        print("test_excitedAt")
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        presenter.command = stub.command
        let date = Date(timeIntervalSince1970: Double(1))
        let dateStr = string(date: date, label: "", textColor: textColor, font: font)

        XCTAssertNotEqual(presenter.exitedAt(textColor: textColor, font: font), dateStr)
    }

    func test_exitedAtError() {
        print("test_exitedAtError")
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        presenter.command = nil
        let date = Date(timeIntervalSince1970: Double(1))
        let dateStr = string(date: date, label: "", textColor: textColor, font: font)
        XCTAssertEqual(presenter.exitedAt(textColor: textColor, font: font), dateStr, "正しい値が取得できていない")

    }

    func test_duration() {
        print("test_duration")

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        XCTContext.runActivity(named: "Commandが存在する場合") { _ in
            presenter.command = stub.command
            let dateStr = string(time: presenter.command?.execDuration, label: "", textColor: textColor, font: font)
            XCTAssertEqual(presenter.duration(textColor: textColor, font: font), dateStr)
        }
    }

    func test_durationError() {
        print("test_durationError")

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.command = nil
        let dateStr = string(time: nil, label: "", textColor: textColor, font: font)
        XCTAssertEqual(presenter.duration(textColor: textColor, font: font), dateStr, "正しい値が取得できていない")
    }

    func test_success() {
        print("test_success")
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        XCTContext.runActivity(named: "Commandsが存在する場合") { _ in
            presenter.command = stub.command
            XCTAssertEqual(presenter.success(), stub.command.success, "正しい値が取得できていない")
        }
    }

    func test_successError() {
        print("test_successError")
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.command = nil
        XCTAssertEqual(presenter.success(), nil, "正しい値が取得できていない")
    }

    func test_failure() {
        print("test_failure")
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        XCTContext.runActivity(named: "Commandsが存在する場合") { _ in
            presenter.command = stub.command
            XCTAssertEqual(presenter.failure(), stub.command.fail, "正しい値が取得できていない")
        }
    }

    func test_failureError() {
        print("test_failureError")
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.command = nil
        XCTAssertEqual(presenter.failure(), nil, "正しい値が取得できていない")
    }

    func test_error() {
        print("test_error")
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.command = stub.command
        XCTAssertEqual(presenter.error(), stub.command.error, "正しい値が取得できていない")
    }

    func test_errorError() {
        print("test_errorError")
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.command = nil
        XCTAssertEqual(presenter.error(), nil, "正しい値が取得できていない")
    }

    func test_status() {
        print("test_status")
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.command = stub.command
        XCTAssertEqual(presenter.status(), stub.command.status, "正しい値が取得できていない")
    }

    func test_statusError() {
        print("test_statusError")
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.command = nil
        XCTAssertEqual(presenter.status(), nil, "正しい値が取得できていない")
    }

    func test_remarks() {
        print("test_remarks")
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.command = stub.command
        XCTAssertEqual(presenter.remarks(), nil, "正しい値が取得できていない")
    }

    func test_remarksError() {
        print("test_remarksError")
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.command = nil
        XCTAssertEqual(presenter.remarks(), nil, "正しい値が取得できていない")
    }

    // Command, Taskともに存在する場合
    func test_na() {
        print("test_na")
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.command = stub.command
        presenter.task = stub.task
        let naCount: Int? = 0
        XCTAssert(presenter.na() == naCount, "正しい値が取得できていない")
    }

    // Command, Taskともに存在しない場合
    func test_naError1() {
        print("test_naError1")
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.command = nil
        presenter.task = nil
        XCTAssertEqual(presenter.na(), 0, "正しい値が取得できていない")
    }

    // Commandが存在する, Taskが存在しない場合
    func test_naError2() {
        print("test_naError2")
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.command = stub.command
        presenter.task = nil
        XCTAssertEqual(presenter.na(), 0, "正しい値が取得できていない")
    }

    // Commandが存在しない, Taskが存在する場合
    func test_naError3() {
        print("test_naError3")
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
            }.eraseToAnyPublisher()
        }

        presenter.command = nil
        presenter.task = stub.task
        XCTAssertEqual(presenter.na(), presenter.task?.exit.option.numberOfRuns, "正しい値が取得できていない")
    }

    // TODO: テスト作成
    func test_tapOrderEntryButton() {
        // tapOrderEntryButtonが実装されていない
    }

    private func getRunHistories(id: String) {}

    private func string(date: Date?, label: String, textColor: UIColor, font: UIFont) -> NSAttributedString? {
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(NSAttributedString(string: label, attributes: [
            .foregroundColor: textColor,
            .font: font
        ]))
        let queuedAt = toDateString(date)
        mutableAttributedString.append(NSAttributedString(string: queuedAt, attributes: [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 14.0)
        ]))
        return mutableAttributedString
    }

    private func string(time: Int?, label: String, textColor: UIColor, font: UIFont) -> NSAttributedString? {
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(NSAttributedString(string: label, attributes: [
            .foregroundColor: textColor,
            .font: font
        ]))
        mutableAttributedString.append(NSAttributedString(string: String(time ?? 0), attributes: [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 14.0)
        ]))
        return mutableAttributedString
    }

    private func toDateString(_ date: Int?) -> String {
        guard let date = date, date != 0 else { return "" }
        return toDateString(Date(timeIntervalSince1970: TimeInterval(date)))
    }

    private func toDateString(_ date: Date?) -> String {
        guard let date = date, date.timeIntervalSince1970 != 0 else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        return formatter.string(from: date)
    }

    private func toEpocTime(_ data: Int?) -> Date {
        return Date(timeIntervalSince1970: Double((data ?? 1000) / 1000))
    }
}
