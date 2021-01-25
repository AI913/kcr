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
    private let vc = TaskDetailRobotSelectionViewControllerProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private lazy var presenter = TaskDetailRobotSelectionPresenter(dataUseCase: data,
                                                                   vc: vc, viewData: viewData)
    private let viewData = TaskDetailViewData()

    override func tearDownWithError() throws {}

    override func setUpWithError() throws {
        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in }.eraseToAnyPublisher()
        }
        presenter.commands = nil
        presenter.task = nil
    }

    func test_getCommands() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"
        let task = DataManageModel.Output.Task.arbitrary.generate
        let commands = DataManageModel.Output.Command.arbitrary.sample

        data.commandsFromTaskHandler = { taskId in
            return Future<[JobOrder_Domain.DataManageModel.Output.Command], Error> { promise in
                promise(.success(commands))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                promise(.success(task))
            }.eraseToAnyPublisher()
        }

        presenter.getCommandsAndTask(taskId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssert(presenter.commands == commands, "正しい値が取得できていない")
        XCTAssertEqual(vc.showErrorAlertCallCount, 0, "エラーが起こってはいけない")
    }

    func test_getCommandsError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"
        let task = DataManageModel.Output.Task.arbitrary.generate

        data.commandsFromTaskHandler = { taskId in
            return Future<[JobOrder_Domain.DataManageModel.Output.Command], Error> { promise in
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

        presenter.getCommandsAndTask(taskId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertNil(presenter.commands, "値が取得できてはいけない")
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_getCommandsNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"
        let task = DataManageModel.Output.Task.arbitrary.generate

        data.commandsFromTaskHandler = { taskId in
            return Future<[JobOrder_Domain.DataManageModel.Output.Command], Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                promise(.success(task))
            }.eraseToAnyPublisher()
        }

        presenter.getCommandsAndTask(taskId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertNil(presenter.commands, "値が取得できてはいけない")
    }

    func test_getTask() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"
        let task = DataManageModel.Output.Task.arbitrary.generate
        let commands = DataManageModel.Output.Command.arbitrary.sample
        data.robots = DataManageModel.Output.Robot.arbitrary.sample
        data.jobs = DataManageModel.Output.Job.arbitrary.sample

        data.commandsFromTaskHandler = { taskId in
            return Future<[JobOrder_Domain.DataManageModel.Output.Command], Error> { promise in
                promise(.success(commands))
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                promise(.success(task))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.getCommandsAndTask(taskId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssert(presenter.task == task, "正しい値が取得できていない")
        XCTAssertEqual(vc.showErrorAlertCallCount, 0, "エラーが起こってはいけない")
    }

    func test_getTaskError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"
        let commands = DataManageModel.Output.Command.arbitrary.sample
        data.robots = DataManageModel.Output.Robot.arbitrary.sample
        data.jobs = DataManageModel.Output.Job.arbitrary.sample

        data.commandsFromTaskHandler = { taskId in
            return Future<[JobOrder_Domain.DataManageModel.Output.Command], Error> { promise in
                promise(.success(commands))
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.getCommandsAndTask(taskId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertNil(presenter.task, "値が取得できてはいけない")
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_getTaskNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"
        let commands = DataManageModel.Output.Command.arbitrary.sample
        data.robots = DataManageModel.Output.Robot.arbitrary.sample
        data.jobs = DataManageModel.Output.Job.arbitrary.sample

        data.commandsFromTaskHandler = { taskId in
            return Future<[JobOrder_Domain.DataManageModel.Output.Command], Error> { promise in
                promise(.success(commands))
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.getCommandsAndTask(taskId: param)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertNil(presenter.task, "値が取得できてはいけない")
    }

    func test_image() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        presenter.commands = DataManageModel.Output.Command.arbitrary.sample

        data.robotImageHandler = { id in
            return Future<JobOrder_Domain.DataManageModel.Output.RobotImage, Error> { promise in
                promise(.success(.init(data: Data())))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.image(index: 0, {
            XCTAssertEqual($0, Data(), "正しい値が取得できていない")
            completionExpectation.fulfill()
        })

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_imageError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion error")
        completionExpectation.isInverted = true
        presenter.commands = DataManageModel.Output.Command.arbitrary.sample

        data.robotImageHandler = { id in
            return Future<JobOrder_Domain.DataManageModel.Output.RobotImage, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.image(index: 0, {_ in
            XCTFail("呼ばれてはいけない")
        })

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        // TODO: エラーケース
    }

    func test_imageNoId() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion error")
        handlerExpectation.isInverted = true
        completionExpectation.isInverted = true
        presenter.commands = nil

        data.robotImageHandler = { id in
            return Future<JobOrder_Domain.DataManageModel.Output.RobotImage, Error> { promise in
                XCTFail("呼ばれてはいけない")
            }.eraseToAnyPublisher()
        }

        presenter.image(index: 0, {_ in
            XCTFail("呼ばれてはいけない")
        })

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        // TODO: エラーケース
    }

    func test_jobName() {
        let task = DataManageModel.Output.Task.arbitrary.generate
        presenter.task = task
        XCTAssertEqual(presenter.jobName(), task.job.name, "正しい値が取得できていない")
    }

    func test_jobNameWithoutTask() {
        XCTAssertEqual(presenter.jobName(), nil, "正しい値が取得できていない")
    }

    func test_displayName() {
        let index = 0
        let name = "param"
        let commands = DataManageModel.Output.Command.arbitrary.sample
        var robots = DataManageModel.Output.Robot.arbitrary.sample

        let obj = commands[index]
        let robotId = obj.robotId
        robots.append(DataManageModel.Output.Robot.pattern(id: robotId, name: name).generate)

        presenter.commands = commands
        data.robots = robots

        XCTAssertEqual(presenter.displayName(index), name, "正しい値が取得できていない")
    }

    func test_displayNameWithoutRobot() {
        XCTAssertEqual(presenter.displayName(1), nil, "正しい値が取得できていない")
    }

    func test_type() {
        let index = 0
        let name = "param"
        let commands = DataManageModel.Output.Command.arbitrary.sample
        var robots = DataManageModel.Output.Robot.arbitrary.sample

        let obj = commands[index]
        let robotId = obj.robotId
        let robot = DataManageModel.Output.Robot.pattern(id: robotId, name: name).generate
        robots.append(robot)

        presenter.commands = commands
        data.robots = robots

        XCTAssertEqual(presenter.type(index), robot.type, "正しい値が取得できていない")
    }

    func test_typeWithoutRobot() {
        XCTAssertEqual(presenter.type(1), nil, "正しい値が取得できていない")
    }

    func test_updatedAt() {
        let task = DataManageModel.Output.Task.arbitrary.generate
        presenter.task = task

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let dateStr = presenter.string(date: task.updateTime.toEpocTime, label: "", textColor: textColor, font: font)
        XCTAssertEqual(presenter.updatedAt(textColor: textColor, font: font), dateStr)
    }

    func test_updatedAtWithoutCommand() {
        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)
        let dateStr = presenter.string(date: nil, label: "", textColor: textColor, font: font)

        XCTAssertEqual(presenter.updatedAt(textColor: textColor, font: font), dateStr)
    }

    func test_createdAt() {
        let task = DataManageModel.Output.Task.arbitrary.generate
        presenter.task = task

        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)

        let dateStr = presenter.string(date: task.createTime.toEpocTime, label: "", textColor: textColor, font: font)
        XCTAssertEqual(presenter.createdAt(textColor: textColor, font: font), dateStr)
    }

    func test_createdAtWithoutCommand() {
        let textColor = UIColor.clear
        let font = UIFont.systemFont(ofSize: 12)
        let dateStr = presenter.string(date: nil, label: "", textColor: textColor, font: font)

        XCTAssertEqual(presenter.createdAt(textColor: textColor, font: font), dateStr)
    }

    func test_success() {
        let commands = DataManageModel.Output.Command.arbitrary.sample
        presenter.commands = commands
        XCTAssertEqual(presenter.success(1), commands[1].success, "正しい値が取得できていない")
    }

    func test_successWithoutTask() {
        XCTAssertEqual(presenter.success(1), nil, "正しい値が取得できていない")
    }

    func test_failure() {
        let commands = DataManageModel.Output.Command.arbitrary.sample
        presenter.commands = commands
        XCTAssertEqual(presenter.failure(1), commands[1].fail, "正しい値が取得できていない")
    }

    func test_failureWithoutTask() {
        XCTAssertEqual(presenter.failure(1), nil, "正しい値が取得できていない")
    }

    func test_error() {
        let commands = DataManageModel.Output.Command.arbitrary.sample
        presenter.commands = commands
        XCTAssertEqual(presenter.error(1), commands[1].error, "正しい値が取得できていない")
    }

    func test_errorWithoutTask() {
        XCTAssertEqual(presenter.error(1), nil, "正しい値が取得できていない")
    }

    func test_status() {
        let commands = DataManageModel.Output.Command.arbitrary.sample
        presenter.commands = commands
        XCTAssertEqual(presenter.status(1), commands[1].status, "正しい値が取得できていない")
    }

    func test_statusWithoutTask() {
        XCTAssertEqual(presenter.status(1), nil, "正しい値が取得できていない")
    }

    // Command, Taskともに存在する場合
    func test_na() {
        let commands = DataManageModel.Output.Command.arbitrary.sample
        let task = DataManageModel.Output.Task.arbitrary.generate
        presenter.commands = commands
        presenter.task = task
        XCTAssert(presenter.na(0) == calcNA(command: commands[0], task: task), "正しい値が取得できていない")
    }

    // Command, Taskともに存在しない場合
    func test_naWithoutCommandTask() {
        XCTAssertEqual(presenter.na(1), 0, "正しい値が取得できていない")
    }

    // Commandが存在する, Taskが存在しない場合
    func test_naWithoutTask() {
        presenter.commands = DataManageModel.Output.Command.arbitrary.sample
        XCTAssertEqual(presenter.na(1), 0, "正しい値が取得できていない")
    }

    // Commandが存在しない, Taskが存在する場合
    func test_naWithoutCommand() {
        presenter.task = DataManageModel.Output.Task.pattern(numberOfRuns: 5).generate
        XCTAssertEqual(presenter.na(1), presenter.task?.exit.option.numberOfRuns, "正しい値が取得できていない")
    }

    // TODO: テスト作成
    func test_tapCancelAllTasksButton() {
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
