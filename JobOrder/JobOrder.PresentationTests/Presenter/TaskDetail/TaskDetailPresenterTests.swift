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
    private let vc = TaskDetailViewControllerProtocolMock()
    private let mqtt = JobOrder_Domain.MQTTUseCaseProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private lazy var presenter = TaskDetailTaskInformationPresenter(dataUseCase: data,
                                                                    vc: vc)
    private let viewData = MainViewData.Robot()

    override func tearDownWithError() throws {}

    override func setUpWithError() throws {
        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in }.eraseToAnyPublisher()
        }
        presenter.command = nil
        presenter.task = nil
    }

    func test_getCommand() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let task = DataManageModel.Output.Task.arbitrary.generate
        let command = DataManageModel.Output.Command.arbitrary.generate
        let param = "test"

        data.commandFromTaskHandler = { _, _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                promise(.success(command))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                promise(.success(task))
            }.eraseToAnyPublisher()
        }

        presenter.getCommandAndTask(taskId: param, robotId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssert(presenter.command == command, "正しい値が取得できていない")
        XCTAssertEqual(vc.showErrorAlertCallCount, 0, "エラーが起こってはいけない")
    }

    func test_getCommandError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let task = DataManageModel.Output.Task.arbitrary.generate
        let param = "test"

        data.commandFromTaskHandler = { _, _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                promise(.success(task))
            }.eraseToAnyPublisher()
        }

        presenter.getCommandAndTask(taskId: param, robotId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertNil(presenter.command, "値が取得できてはいけない")
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_getCommandNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let task = DataManageModel.Output.Task.arbitrary.generate
        let param = "test"

        data.commandFromTaskHandler = { _, _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                promise(.success(task))
            }.eraseToAnyPublisher()
        }

        presenter.getCommandAndTask(taskId: param, robotId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertNil(presenter.command, "値が取得できてはいけない")
    }

    func test_getTask() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"
        data.robots = DataManageModel.Output.Robot.arbitrary.sample
        data.jobs = DataManageModel.Output.Job.arbitrary.sample
        let task = DataManageModel.Output.Task.arbitrary.generate
        let command = DataManageModel.Output.Command.arbitrary.generate

        data.commandFromTaskHandler = { _, _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                promise(.success(command))
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                promise(.success(task))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.getCommandAndTask(taskId: param, robotId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        //レスポンスが間に合ってない
        XCTAssert(presenter.task == task, "正しい値が取得できていない")
        XCTAssertEqual(vc.showErrorAlertCallCount, 0, "エラーが起こってはいけない")
    }

    func test_getTaskError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"
        data.robots = DataManageModel.Output.Robot.arbitrary.sample
        data.jobs = DataManageModel.Output.Job.arbitrary.sample
        let command = DataManageModel.Output.Command.arbitrary.generate

        data.commandFromTaskHandler = { _, _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                promise(.success(command))
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.getCommandAndTask(taskId: param, robotId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertNil(presenter.task, "値が取得できてはいけない")
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_getTaskNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"
        data.robots = DataManageModel.Output.Robot.arbitrary.sample
        data.jobs = DataManageModel.Output.Job.arbitrary.sample
        let command = DataManageModel.Output.Command.arbitrary.generate

        data.commandFromTaskHandler = { _, _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                promise(.success(command))
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.getCommandAndTask(taskId: param, robotId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertNil(presenter.task, "値が取得できてはいけない")
    }

    // TODO: - テスト作成する
    func test_jobName() {
        // jobName()は現在ハードコーディングで固定値を返却している
    }

    func test_RobotName() {
        let command = DataManageModel.Output.Command.arbitrary.generate
        presenter.command = command
        XCTAssertEqual(presenter.RobotName(), command.robot?.name, "正しい値が取得できていない")
    }

    func test_RobotNameWithoutRobot() {
        XCTAssertEqual(presenter.RobotName(), nil, "正しい値が取得できていない")
    }

    func test_updatedAt() {
        let command = DataManageModel.Output.Command.arbitrary.generate
        presenter.command = command

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let dateStr = presenter.string(date: command.updateTime.toEpocTime, label: "", textColor: textColor, font: font)
        XCTAssertEqual(presenter.updatedAt(textColor: textColor, font: font), dateStr)
    }

    func test_updatedAtWithoutCommand() {
        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let dateStr = presenter.string(date: nil, label: "", textColor: textColor, font: font)

        XCTAssertEqual(presenter.updatedAt(textColor: textColor, font: font), dateStr)
    }

    func test_createdAt() {
        let command = DataManageModel.Output.Command.arbitrary.generate
        presenter.command = command

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let dateStr = presenter.string(date: command.createTime.toEpocTime, label: "", textColor: textColor, font: font)
        XCTAssertEqual(presenter.createdAt(textColor: textColor, font: font), dateStr)
    }

    func test_createdAtWithoutCommand() {
        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let dateStr = presenter.string(date: nil, label: "", textColor: textColor, font: font)

        XCTAssertEqual(presenter.createdAt(textColor: textColor, font: font), dateStr)
    }

    func test_startedAt() {
        let command = DataManageModel.Output.Command.arbitrary.suchThat({ $0.started != nil }).generate
        presenter.command = command

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let date = Date(timeIntervalSince1970: Double(command.started! / 1000))
        let dateStr = presenter.string(date: date, label: "", textColor: textColor, font: font)
        XCTAssertEqual(presenter.startedAt(textColor: textColor, font: font), dateStr)
    }

    func test_startedAtWithoutCommand() {
        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let dateStr = presenter.string(date: nil, label: "", textColor: textColor, font: font)

        XCTAssertEqual(presenter.startedAt(textColor: textColor, font: font), dateStr)
    }

    func test_exitedAt() {
        let command = DataManageModel.Output.Command.arbitrary.suchThat({ $0.exited != nil }).generate
        presenter.command = command

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let date = Date(timeIntervalSince1970: Double(command.exited! / 1000))
        let dateStr = presenter.string(date: date, label: "", textColor: textColor, font: font)
        XCTAssertEqual(presenter.exitedAt(textColor: textColor, font: font), dateStr)
    }

    func test_exitedAtWithoutCommand() {
        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let dateStr = presenter.string(date: nil, label: "", textColor: textColor, font: font)

        XCTAssertEqual(presenter.exitedAt(textColor: textColor, font: font), dateStr)

    }

    func test_duration() {
        let command = DataManageModel.Output.Command.arbitrary.suchThat({
            guard let execDuration = $0.execDuration else { return false }
            return execDuration > 0
        }).generate
        presenter.command = command

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let dateStr = presenter.string(time: command.execDuration, label: "", textColor: textColor, font: font)
        XCTAssertEqual(presenter.duration(textColor: textColor, font: font), dateStr)
    }

    func test_durationWithoutTask() {
        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let dateStr = presenter.string(time: 0, label: "", textColor: textColor, font: font)
        XCTAssertEqual(presenter.duration(textColor: textColor, font: font), dateStr)
    }

    func test_success() {
        let command = DataManageModel.Output.Command.arbitrary.generate
        presenter.command = command
        XCTAssertEqual(presenter.success(), command.success, "正しい値が取得できていない")
    }

    func test_successWithoutTask() {
        XCTAssertEqual(presenter.success(), nil, "正しい値が取得できていない")
    }

    func test_failure() {
        let command = DataManageModel.Output.Command.arbitrary.generate
        presenter.command = command
        XCTAssertEqual(presenter.failure(), command.fail, "正しい値が取得できていない")
    }

    func test_failureWithoutTask() {
        XCTAssertEqual(presenter.failure(), nil, "正しい値が取得できていない")
    }

    func test_error() {
        let command = DataManageModel.Output.Command.arbitrary.generate
        presenter.command = command
        XCTAssertEqual(presenter.error(), command.error, "正しい値が取得できていない")
    }

    func test_errorWithoutTask() {
        XCTAssertEqual(presenter.error(), nil, "正しい値が取得できていない")
    }

    func test_status() {
        let command = DataManageModel.Output.Command.arbitrary.generate
        presenter.command = command
        XCTAssertEqual(presenter.status(), command.status, "正しい値が取得できていない")
    }

    func test_statusWithoutTask() {
        XCTAssertEqual(presenter.status(), nil, "正しい値が取得できていない")
    }

    func test_remarks() {
        let robot = DataManageModel.Output.Robot.arbitrary.generate
        presenter.robot = robot
        XCTAssertEqual(presenter.remarks(), robot.remarks, "正しい値が取得できていない")
    }

    func test_remarksWithoutRobot() {
        XCTAssertEqual(presenter.remarks(), nil, "正しい値が取得できていない")
    }

    // Command, Taskともに存在する場合
    func test_na() {
        let command = DataManageModel.Output.Command.arbitrary.suchThat({ $0.success > 0 && $0.fail > 0 && $0.error > 0 }).generate
        let task = DataManageModel.Output.Task.pattern(numberOfRuns: 1).generate
        presenter.command = command
        presenter.task = task
        XCTAssert(presenter.na() == calcNA(command: command, task: task), "正しい値が取得できていない")
    }

    // Command, Taskともに存在しない場合
    func test_naWithoutCommandTask() {
        XCTAssertEqual(presenter.na(), 0, "正しい値が取得できていない")
    }

    // Commandが存在する, Taskが存在しない場合
    func test_naWithoutTask() {
        presenter.command = DataManageModel.Output.Command.arbitrary.generate
        XCTAssertEqual(presenter.na(), 0, "正しい値が取得できていない")
    }

    // Commandが存在しない, Taskが存在する場合
    // TODO: #111 で対策するため一旦コメントアウト
    //func test_naWithoutCommand() {
    //    presenter.task = DataManageModel.Output.Task.arbitrary.generate
    //    XCTAssertEqual(presenter.na(), 0, "正しい値が取得できていない")
    //}

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
