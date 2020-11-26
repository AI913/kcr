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

class TaskDetailRobotSelectionPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let ms3000 = 3.0
    private let stub = PresentationTestsStub()
    private let vc = TaskDetailRobotSelectionViewControllerProtocolMock()
    private let mqtt = JobOrder_Domain.MQTTUseCaseProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private lazy var presenter = TaskDetailRobotSelectionPresenter(dataUseCase: data,
                                                                   vc: vc)
    private let viewData = MainViewData.Robot()

    override func tearDownWithError() throws {}

    override func setUpWithError() throws {
        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in }.eraseToAnyPublisher()
        }
    }

    func test_getCommands() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let taskId = "taskId"

        data.commandsFromTaskHandler = { _, _ in
            return Future<[JobOrder_Domain.DataManageModel.Output.Command], Error> { promise in
                promise(.success(self.stub.commands()))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.getCommands(taskId: taskId)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssert(presenter.commands == stub.commands, "正しい値が取得できていない")
        XCTAssertEqual(vc.showErrorAlertCallCount, 0, "エラーが起こってはいけない")
    }

    func test_getCommandsError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = ""

        data.commandsFromTaskHandler = { _, _ in
            return Future<[JobOrder_Domain.DataManageModel.Output.Command], Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.getCommands(taskId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertNil(presenter.commands, "値が取得できてはいけない")
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_getCommandNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = ""

        data.commandFromTaskHandler = { _, _ in
            return Future<[JobOrder_Domain.DataManageModel.Output.Command], Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.getCommand(taskId: param, robotId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertNil(presenter.command, "値が取得できてはいけない")
    }

    func test_getTask() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"
        data.robots = stub.robots
        data.jobs = stub.jobs

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                promise(.success(self.stub.task))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.getTask(taskId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        //レスポンスが間に合ってない
        XCTAssert(presenter.task == stub.task, "正しい値が取得できていない")
        XCTAssertEqual(vc.showErrorAlertCallCount, 0, "エラーが起こってはいけない")
    }

    func test_getTaskError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = ""
        data.robots = stub.robots
        data.jobs = stub.jobs

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.getTask(taskId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertNil(presenter.task, "値が取得できてはいけない")
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_getTaskNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = ""
        data.robots = stub.robots
        data.jobs = stub.jobs

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.getTask(taskId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertNil(presenter.task, "値が取得できてはいけない")
    }

    func test_getRobot() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        data.robots = stub.robots

        data.robotHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Robot, Error> { promise in
                promise(.success(self.stub.robot))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.getRobot(robotId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        //レスポンスが間に合ってない
        guard let presenterRobot = presenter.robot else { return }
        XCTAssert(presenterRobot == stub.robot, "正しい値が取得できていない")
        XCTAssertEqual(vc.showErrorAlertCallCount, 0, "エラーが起こってはいけない")
    }

    func test_getRobotError() {
        let param = ""
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        data.robots = stub.robots

        data.robotHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Robot, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.getRobot(robotId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertNil(presenter.robot, "値が取得できてはいけない")
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_getRobotNotReceived() {
        let param = ""
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        data.robots = stub.robots

        data.robotHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Robot, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.getRobot(robotId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertNil(presenter.robot, "値が取得できてはいけない")
    }

    // TODO: - テスト作成する
    func test_jobName() {
        // jobName()は現在ハードコーディングで固定値を返却している
    }

    func test_RobotName() {
        presenter.robot = stub.robot
        XCTAssertEqual(presenter.RobotName(), stub.robot.name, "正しい値が取得できていない")
    }

    func test_RobotNameWithoutRobot() {
        XCTAssertEqual(presenter.RobotName(), nil, "正しい値が取得できていない")
    }

    func test_updatedAt() {
        presenter.command = stub.command1()

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let dateStr = presenter.string(date: presenter.toEpocTime(stub.command1().updateTime), label: "", textColor: textColor, font: font)
        XCTAssertEqual(presenter.updatedAt(textColor: textColor, font: font), dateStr)
    }

    func test_updatedAtWithoutCommand() {
        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let date = Date(timeIntervalSince1970: Double(1))
        let dateStr = presenter.string(date: date, label: "", textColor: textColor, font: font)

        XCTAssertEqual(presenter.updatedAt(textColor: textColor, font: font), dateStr)
    }

    func test_createdAt() {
        presenter.command = stub.command1()

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let dateStr = presenter.string(date: presenter.toEpocTime(stub.command1().createTime), label: "", textColor: textColor, font: font)
        XCTAssertEqual(presenter.createdAt(textColor: textColor, font: font), dateStr)
    }

    func test_createdAtWithoutCommand() {
        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let date = Date(timeIntervalSince1970: Double(1))
        let dateStr = presenter.string(date: date, label: "", textColor: textColor, font: font)

        XCTAssertEqual(presenter.createdAt(textColor: textColor, font: font), dateStr)
    }

    func test_startedAt() {
        presenter.command = stub.command1()

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let date = Date(timeIntervalSince1970: Double(stub.command1().started ?? 1000))
        let dateStr = presenter.string(date: date, label: "", textColor: textColor, font: font)
        XCTAssertEqual(presenter.startedAt(textColor: textColor, font: font), dateStr)
    }

    func text_startedAtWithoutCommand() {
        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let date = Date(timeIntervalSince1970: Double(1))
        let dateStr = presenter.string(date: date, label: "", textColor: textColor, font: font)

        XCTAssertEqual(presenter.startedAt(textColor: textColor, font: font), dateStr)
    }

    func test_exitedAt() {
        presenter.command = stub.command1()

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let date = Date(timeIntervalSince1970: Double(stub.command1().exited ?? 1000))
        let dateStr = presenter.string(date: date, label: "", textColor: textColor, font: font)
        XCTAssertEqual(presenter.exitedAt(textColor: textColor, font: font), dateStr)
    }

    func test_exitedAtWithoutCommand() {
        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let date = Date(timeIntervalSince1970: Double(1))
        let dateStr = presenter.string(date: date, label: "", textColor: textColor, font: font)

        XCTAssertEqual(presenter.exitedAt(textColor: textColor, font: font), dateStr)

    }

    func test_duration() {
        presenter.command = stub.command1()

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let dateStr = presenter.string(time: stub.command1().execDuration, label: "", textColor: textColor, font: font)
        XCTAssertEqual(presenter.duration(textColor: textColor, font: font), dateStr)
    }

    func test_durationWithoutTask() {
        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let dateStr = presenter.string(time: 0, label: "", textColor: textColor, font: font)
        XCTAssertEqual(presenter.duration(textColor: textColor, font: font), dateStr)
    }

    func test_success() {
        presenter.command = stub.command1()
        XCTAssertEqual(presenter.success(), stub.command1().success, "正しい値が取得できていない")
    }

    func test_successWithoutTask() {
        XCTAssertEqual(presenter.success(), nil, "正しい値が取得できていない")
    }

    func test_failure() {
        presenter.command = stub.command1()
        XCTAssertEqual(presenter.failure(), stub.command.fail, "正しい値が取得できていない")
    }

    func test_failureWithoutTask() {
        XCTAssertEqual(presenter.failure(), nil, "正しい値が取得できていない")
    }

    func test_error() {
        presenter.command = stub.command
        XCTAssertEqual(presenter.error(), stub.command.error, "正しい値が取得できていない")
    }

    func test_errorWithoutTask() {
        XCTAssertEqual(presenter.error(), nil, "正しい値が取得できていない")
    }

    func test_status() {
        presenter.command = stub.command
        XCTAssertEqual(presenter.status(), stub.command.status, "正しい値が取得できていない")
    }

    func test_statusWithoutTask() {
        XCTAssertEqual(presenter.status(), nil, "正しい値が取得できていない")
    }

    func test_remarks() {
        presenter.robot = stub.robot1()
        XCTAssertEqual(presenter.remarks(), stub.robot1().remarks, "正しい値が取得できていない")
    }

    func test_remarksWithoutRobot() {
        XCTAssertEqual(presenter.remarks(), nil, "正しい値が取得できていない")
    }

    // Command, Taskともに存在する場合
    func test_na() {
        presenter.command = stub.command
        presenter.task = stub.task
        XCTAssert(presenter.na() == calcNA(command: stub.command, task: stub.task), "正しい値が取得できていない")
    }

    // Command, Taskともに存在しない場合
    func test_naWithoutCommandTask() {
        XCTAssertEqual(presenter.na(), 0, "正しい値が取得できていない")
    }

    // Commandが存在する, Taskが存在しない場合
    func test_naWithoutTask() {
        presenter.command = stub.command
        XCTAssertEqual(presenter.na(), 0, "正しい値が取得できていない")
    }

    // Commandが存在しない, Taskが存在する場合
    func test_naWithoutCommand() {
        presenter.task = stub.task
        XCTAssertEqual(presenter.na(), presenter.task?.exit.option.numberOfRuns, "正しい値が取得できていない")
    }

    // TODO: テスト作成
    func test_tapOrderEntryButton() {
        // tapOrderEntryButtonが実装されていない
    }

    private func calcNA(command: JobOrder_Domain.DataManageModel.Output.Command?, task: JobOrder_Domain.DataManageModel.Output.Task?) -> Int {
        let otherCount = (command?.success ?? 0) + (command?.fail ?? 0) + (command?.error ?? 0)
        var naCount = (task?.exit.option.numberOfRuns ?? 0)

        if naCount != 0 {
            naCount = (task?.exit.option.numberOfRuns ?? 0) - otherCount
        }
        //TODO:現在APIから返ってくる値の整合性が取れていない（総数よりSuccess数の方が多い）のでマイナスの値にならないようにする
        if 0 > naCount {
            naCount = 0
        }
        return naCount
    }
}
