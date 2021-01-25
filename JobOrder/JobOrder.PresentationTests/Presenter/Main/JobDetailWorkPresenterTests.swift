//
//  JobDetailWorkPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by 藤井一暢 on 2020/11/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class JobDetailWorkPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let vc = JobDetailWorkViewControllerProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let viewData = MainViewData.Job()
    private lazy var presenter = JobDetailWorkPresenter(dataUseCase: data, vc: vc, viewData: viewData)

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_viewWillAppear() {
        let param = "test"
        let taksHandlerExpectation = expectation(description: "task handler")
        let commandHandlerExpectation = expectation(description: "command handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let tasks = DataManageModel.Output.Task.arbitrary.suchThat({ !$0.robotIds.isEmpty }).sample
        let commands = (0..<tasks.count).map({ _ in DataManageModel.Output.Command.arbitrary.generate })
        presenter.data.id = param

        data.tasksFromJobHandler = { id, cursor in
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Task]>, Error> { promise in
                promise(.success(.init(data: tasks, cursor: nil, total: nil)))
                taksHandlerExpectation.fulfill()
                XCTAssertEqual(cursor, PagingModel.Cursor(offset: 0, limit: 10), "先頭10件取得指定になっていない")
            }.eraseToAnyPublisher()
        }

        data.commandFromTaskHandler = { _, _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                let index = self.data.commandFromTaskCallCount - 1
                let command = commands[index]
                promise(.success(command))
                if index >= commands.endIndex - 1 {
                    commandHandlerExpectation.fulfill()
                }
            }.eraseToAnyPublisher()
        }

        presenter.viewWillAppear()
        wait(for: [taksHandlerExpectation, commandHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertNotNil(presenter.tasks, "正しい値が取得できていない")
        XCTAssertEqual(presenter.commands.count, commands.count, "正しい値が取得できていない")
        XCTAssertTrue(tasks.elementsEqual(presenter.tasks!), "正しい値が取得できていない")
        XCTAssertTrue(commands.elementsEqual(presenter.commands), "正しい値が取得できていない")
    }

    func test_viewWillAppearErrorTask() {
        let param = "test"
        let taksHandlerExpectation = expectation(description: "task handler")
        let commandHandlerExpectation = expectation(description: "command handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        commandHandlerExpectation.isInverted = true
        presenter.data.id = param

        data.tasksFromJobHandler = { id, _ in
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Task]>, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                taksHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.commandFromTaskHandler = { _, _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                promise(.success(DataManageModel.Output.Command.arbitrary.generate))
                commandHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.viewWillAppear()
        wait(for: [taksHandlerExpectation, commandHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertNil(presenter.tasks, "値が取得できてはいけない")
        XCTAssertTrue(presenter.commands.isEmpty, "値が取得できてはいけない")
        XCTAssertEqual(data.commandFromTaskCallCount, 0, "呼び出されてはいけない")
    }

    func test_viewWillAppearErrorCommand() {
        let param = "test"
        let taksHandlerExpectation = expectation(description: "task handler")
        let commandHandlerExpectation = expectation(description: "command handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let tasks = DataManageModel.Output.Task.arbitrary.suchThat({ !$0.robotIds.isEmpty }).generate
        presenter.data.id = param

        data.tasksFromJobHandler = { id, _ in
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Task]>, Error> { promise in
                promise(.success(.init(data: [tasks], cursor: nil, total: nil)))
                taksHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.commandFromTaskHandler = { _, _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                commandHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.viewWillAppear()
        wait(for: [taksHandlerExpectation, commandHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertNotNil(presenter.tasks, "値が取得できなければならない")
        XCTAssertTrue(presenter.commands.isEmpty, "値が取得できてはいけない")
        XCTAssertEqual(data.commandFromTaskCallCount, 1, "呼び出されていない")
    }

    func test_viewWillAppearNoId() {
        presenter.data.id = nil
        presenter.viewWillAppear()
        XCTAssertNil(presenter.tasks, "値を取得できてはいけない")
    }

    func test_numberOfSections() {
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.tasks = nil
            XCTAssertEqual(presenter.numberOfSections(in: .task), 0, "正しい値が取得できていない")
        }

        XCTContext.runActivity(named: "Tasksが存在する場合") { _ in
            let tasks = DataManageModel.Output.Task.arbitrary.sample
            presenter.tasks = tasks
            XCTAssertEqual(presenter.numberOfSections(in: .task), tasks.count, "正しい値が取得できていない")
        }
    }

    func test_selectRow() {
        let index = 0
        let indexPath = IndexPath(row: 0, section: index)
        let task = DataManageModel.Output.Task.arbitrary.suchThat({ !$0.robotIds.isEmpty }).generate
        var tasks = DataManageModel.Output.Task.arbitrary.suchThat({ !$0.robotIds.isEmpty }).sample
        tasks.insert(task, at: index)
        presenter.tasks = tasks

        vc.launchTaskDetailHandler = { taskId, robotIds in
            XCTAssertEqual(taskId, task.id, "引数に正しい値が設定されていない")
            XCTAssertEqual(robotIds, task.robotIds, "引数に正しい値が設定されていない")
        }

        presenter.selectRow(in: .task, indexPath: indexPath)

        XCTAssertEqual(vc.launchTaskDetailCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_orderName() {
        let index = 0

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.tasks = nil
            XCTAssertNil(presenter.orderName(in: .task, index: index), "正しい値が取得できていない")
        }
        XCTContext.runActivity(named: "Tasksが存在する場合") { _ in
            let task = DataManageModel.Output.Task.arbitrary.generate
            var tasks = DataManageModel.Output.Task.arbitrary.sample
            tasks.insert(task, at: index)
            presenter.tasks = tasks
            XCTAssertEqual(presenter.orderName(in: .task, index: index), "\(task.createTime.toEpocTime.toMediumDateString)のオーダー", "正しい値が取得できていない")
        }
    }

    func test_assignName() {
        let index = 0
        let robots = DataManageModel.Output.Robot.arbitrary.sample
        let robotIds = robots.map { $0.id }
        let name = robots[index].name!
        data.robots = robots

        XCTContext.runActivity(named: "Tasksが未設定の場合") { _ in
            presenter.tasks = nil
            XCTAssertNil(presenter.assignName(in: .task, index: index), "正しい値が取得できていない")
        }

        XCTContext.runActivity(named: "Tasksが存在する場合") { _ in
            XCTContext.runActivity(named: "Robotsが空の場合") { _ in
                presenter.tasks = DataManageModel.Output.Task.pattern(robotIds: []).sample
                XCTAssertNil(presenter.assignName(in: .task, index: index), "正しい値が取得できていない")
            }
            XCTContext.runActivity(named: "Robotsが1つだけ存在する場合") { _ in
                presenter.tasks = DataManageModel.Output.Task.pattern(robotIds: Array(robotIds.prefix(1))).sample
                XCTAssertEqual(presenter.assignName(in: .task, index: index), name, "正しい値が取得できていない")
            }
            XCTContext.runActivity(named: "Robotsが複数存在する場合") { _ in
                presenter.tasks = DataManageModel.Output.Task.pattern(robotIds: robotIds).sample
                let expected = "\(name) 他\(robotIds.count - 1)台にアサイン"
                XCTAssertEqual(presenter.assignName(in: .task, index: index), expected, "正しい値が取得できていない")
            }
        }
    }

    func test_status() {
        let index = 0
        XCTContext.runActivity(named: "Tasks未設定の場合") { _ in
            presenter.tasks = nil
            presenter.commands.removeAll()
            XCTAssertNil(presenter.status(in: .task, index: index), "正しい値が取得できていない")
        }

        XCTContext.runActivity(named: "Tasksが存在する場合") { _ in
            let robots = DataManageModel.Output.Robot.arbitrary.sample
            let robotIds = robots.map { $0.id }
            let tasks = DataManageModel.Output.Task.pattern(robotIds: robotIds).sample
            let commands = DataManageModel.Output.Command.arbitrary.sample
            presenter.tasks = tasks
            XCTContext.runActivity(named: "Commandsに該当タスクが存在しない場合") { _ in
                presenter.commands = commands
                XCTAssertNil(presenter.status(in: .task, index: index), "正しい値が取得できていない")
            }
            XCTContext.runActivity(named: "Commandsが空の場合") { _ in
                presenter.commands = []
                XCTAssertNil(presenter.status(in: .task, index: index), "正しい値が取得できていない")
            }
            XCTContext.runActivity(named: "Commandsが存在する場合") { _ in
                let obj = tasks[index]
                let command = DataManageModel.Output.Command.pattern(taskId: obj.id).generate
                presenter.commands = commands + [command]
                XCTAssertEqual(presenter.status(in: .task, index: index), command.status, "正しい値が取得できていない")
            }
        }
    }
}
