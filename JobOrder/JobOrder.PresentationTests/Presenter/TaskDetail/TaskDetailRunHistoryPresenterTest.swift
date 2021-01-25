//
//  TaskDetailRunHistoryPresenterTest.swift
//  JobOrder.PresentationTests
//
//  Created by 藤井一暢 on 2020/12/08.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class TaskDetailRunHistoryPresenterTest: XCTestCase {

    private let ms1000 = 1.0
    private let vc = TaskDetailRunHistoryViewControllerProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let viewData = MainViewData.Job()
    private lazy var presenter = TaskDetailRunHistoryPresenter(dataUseCase: data, vc: vc, jobData: viewData)

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_viewWillAppear() {
        let param = "test"

        let expectedCursor = PagingModel.Cursor(offset: 0, limit: 20)
        let expectedTotal = 123

        let taksHandlerExpectation = expectation(description: "task handler")
        let commandHandlerExpectation = expectation(description: "command handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let tasks = DataManageModel.Output.Task.arbitrary.suchThat({ !$0.robotIds.isEmpty }).sample
        let commands = (0..<tasks.count).map({ _ in DataManageModel.Output.Command.arbitrary.generate })
        presenter.jobData = MainViewData.Job(id: param)

        data.tasksFromJobHandler = { id, cursor in
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Task]>, Error> { promise in
                promise(.success(.init(data: tasks, cursor: expectedCursor, total: expectedTotal)))
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

        XCTAssertEqual(presenter.commands.count, commands.count, "正しい値が取得できていない")
        XCTAssertTrue(tasks.elementsEqual(presenter.tasks), "正しい値が取得できていない")
        XCTAssertTrue(commands.elementsEqual(presenter.commands), "正しい値が取得できていない")
        XCTAssertEqual(presenter.cursor, expectedCursor, "正しい値が取得できていない")
        XCTAssertEqual(presenter.totalItems, expectedTotal, "正しい値が取得できていない")
        XCTAssertEqual(vc.reloadTableCallCount, 1, "画面が更新されない")
    }

    func test_viewWillAppearErrorTask() {
        let param = "test"
        let taksHandlerExpectation = expectation(description: "task handler")
        let commandHandlerExpectation = expectation(description: "command handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        commandHandlerExpectation.isInverted = true
        presenter.jobData = MainViewData.Job(id: param)

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

        XCTAssertTrue(presenter.tasks.isEmpty, "値が取得できてはいけない")
        XCTAssertTrue(presenter.commands.isEmpty, "値が取得できてはいけない")
        XCTAssertEqual(data.commandFromTaskCallCount, 0, "呼び出されてはいけない")
    }

    func test_viewWillAppearErrorCommand() {
        let param = "test"
        let taksHandlerExpectation = expectation(description: "task handler")
        let commandHandlerExpectation = expectation(description: "command handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let task = DataManageModel.Output.Task.arbitrary.generate
        presenter.jobData = MainViewData.Job(id: param)

        data.tasksFromJobHandler = { id, _ in
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Task]>, Error> { promise in
                promise(.success(.init(data: [task], cursor: nil, total: nil)))
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

        XCTAssertFalse(presenter.tasks.isEmpty, "値が取得できなければならない")
        XCTAssertTrue(presenter.commands.isEmpty, "値が取得できてはいけない")
        XCTAssertEqual(data.commandFromTaskCallCount, 1, "呼び出されていない")
    }

    func test_viewWillAppearViaRobotData() {
        let param = "test"

        let robotData = MainViewData.Robot(id: param)
        let presenter = TaskDetailRunHistoryPresenter(dataUseCase: data, vc: vc, robotData: robotData)

        let expectedCursor = PagingModel.Cursor(offset: 0, limit: 20)
        let expectedTotal = 123

        let taksHandlerExpectation = expectation(description: "task handler")
        let commandHandlerExpectation = expectation(description: "command handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let commands = DataManageModel.Output.Command.arbitrary.sample
        let tasks = (0..<commands.count).map({ _ in DataManageModel.Output.Task.arbitrary.generate })
        presenter.robotData = robotData

        data.commandFromRobotHandler = { _, _, cursor in
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Command]>, Error> { promise in
                promise(.success(.init(data: commands, cursor: expectedCursor, total: expectedTotal)))
                commandHandlerExpectation.fulfill()
                XCTAssertEqual(cursor, PagingModel.Cursor(offset: 0, limit: 10), "先頭10件取得指定になっていない")
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                let index = self.data.taskCallCount - 1
                let task = tasks[index]
                promise(.success(task))
                if index >= tasks.endIndex - 1 {
                    taksHandlerExpectation.fulfill()
                }
            }.eraseToAnyPublisher()
        }

        presenter.viewWillAppear()
        wait(for: [taksHandlerExpectation, commandHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertEqual(presenter.commands.count, commands.count, "正しい値が取得できていない")
        XCTAssertTrue(tasks.elementsEqual(presenter.tasks), "正しい値が取得できていない")
        XCTAssertTrue(commands.elementsEqual(presenter.commands), "正しい値が取得できていない")
        XCTAssertEqual(presenter.cursor, expectedCursor, "正しい値が取得できていない")
        XCTAssertEqual(presenter.totalItems, expectedTotal, "正しい値が取得できていない")
        XCTAssertEqual(vc.reloadTableCallCount, 1, "画面が更新されない")
    }

    func test_viewWillAppearViaRobotDataErrorCommand() {
        let param = "test"

        let robotData = MainViewData.Robot(id: param)
        let presenter = TaskDetailRunHistoryPresenter(dataUseCase: data, vc: vc, robotData: robotData)

        let taksHandlerExpectation = expectation(description: "task handler")
        let commandHandlerExpectation = expectation(description: "command handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        taksHandlerExpectation.isInverted = true
        let tasks = DataManageModel.Output.Task.arbitrary.sample
        presenter.robotData = robotData

        data.commandFromRobotHandler = { _, _, _ in
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Command]>, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                commandHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                let index = self.data.taskCallCount
                let task = tasks[index]
                promise(.success(task))
                if index >= tasks.endIndex - 1 {
                    taksHandlerExpectation.fulfill()
                }
            }.eraseToAnyPublisher()
        }

        presenter.viewWillAppear()
        wait(for: [taksHandlerExpectation, commandHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertTrue(presenter.tasks.isEmpty, "値が取得できてはいけない")
        XCTAssertTrue(presenter.commands.isEmpty, "値が取得できてはいけない")
        XCTAssertEqual(data.taskCallCount, 0, "呼び出されてはいけない")
    }

    func test_viewWillAppearViaRobotDataErrorTask() {
        let param = "test"

        let robotData = MainViewData.Robot(id: param)
        let presenter = TaskDetailRunHistoryPresenter(dataUseCase: data, vc: vc, robotData: robotData)

        let taksHandlerExpectation = expectation(description: "task handler")
        let commandHandlerExpectation = expectation(description: "command handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        presenter.robotData = robotData

        data.commandFromRobotHandler = { _, _, _ in
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Command]>, Error> { promise in
                promise(.success(.init(data: [DataManageModel.Output.Command.arbitrary.generate], cursor: nil, total: nil)))
                commandHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                taksHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.viewWillAppear()
        wait(for: [taksHandlerExpectation, commandHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertTrue(presenter.tasks.isEmpty, "値が取得できてはいけない")
        XCTAssertFalse(presenter.commands.isEmpty, "値が取得できなければならない")
        XCTAssertEqual(data.taskCallCount, 1, "呼び出されていない")
    }

    func test_viewWillAppearNoId() {

        XCTContext.runActivity(named: "Task取得後にCommand取得の場合") { _ in
            let taksHandlerExpectation = expectation(description: "task handler")
            let commandHandlerExpectation = expectation(description: "command handler")
            let completionExpectation = expectation(description: "completion")
            taksHandlerExpectation.isInverted = true
            commandHandlerExpectation.isInverted = true
            completionExpectation.isInverted = true

            presenter.jobData = MainViewData.Job()
            presenter.method = .tasksEachCommands

            data.commandFromRobotHandler = { _, _, _ in
                return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Command]>, Error> { promise in
                    commandHandlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            data.taskHandler = { _ in
                return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                    taksHandlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            presenter.viewWillAppear()
            wait(for: [taksHandlerExpectation, commandHandlerExpectation, completionExpectation], timeout: ms1000)

            XCTAssertTrue(presenter.tasks.isEmpty, "値を取得できてはいけない")
            XCTAssertTrue(presenter.commands.isEmpty, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Command取得後にTask取得の場合") { _ in
            let taksHandlerExpectation = expectation(description: "task handler")
            let commandHandlerExpectation = expectation(description: "command handler")
            let completionExpectation = expectation(description: "completion")
            taksHandlerExpectation.isInverted = true
            commandHandlerExpectation.isInverted = true
            completionExpectation.isInverted = true

            presenter.jobData = MainViewData.Job()
            presenter.method = .tasksEachCommands

            data.commandFromRobotHandler = { _, _, _ in
                return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Command]>, Error> { promise in
                    commandHandlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            data.taskHandler = { _ in
                return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                    taksHandlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            presenter.robotData = MainViewData.Robot()
            presenter.method = .commandsEachTasks

            presenter.viewWillAppear()
            wait(for: [taksHandlerExpectation, commandHandlerExpectation, completionExpectation], timeout: ms1000)

            XCTAssertTrue(presenter.tasks.isEmpty, "値を取得できてはいけない")
            XCTAssertTrue(presenter.commands.isEmpty, "値を取得できてはいけない")
        }

    }

    func test_numberOfSections() {

        XCTContext.runActivity(named: "Task一覧の場合") { _ in
            presenter.browsing = .tasks
            XCTContext.runActivity(named: "未設定の場合") { _ in
                presenter.tasks.removeAll()
                XCTAssertEqual(presenter.numberOfSections(), 0, "正しい値が取得できていない")
            }

            XCTContext.runActivity(named: "Tasksが存在する場合") { _ in
                let tasks = DataManageModel.Output.Task.arbitrary.sample
                presenter.tasks = tasks
                XCTAssertEqual(presenter.numberOfSections(), tasks.count, "正しい値が取得できていない")
            }
        }

        XCTContext.runActivity(named: "Command一覧の場合") { _ in
            presenter.browsing = .commands
            XCTContext.runActivity(named: "未設定の場合") { _ in
                presenter.commands.removeAll()
                XCTAssertEqual(presenter.numberOfSections(), 0, "正しい値が取得できていない")
            }

            XCTContext.runActivity(named: "Tasksが存在する場合") { _ in
                let commands = DataManageModel.Output.Command.arbitrary.sample
                presenter.commands = commands
                XCTAssertEqual(presenter.numberOfSections(), commands.count, "正しい値が取得できていない")
            }
        }

    }

    func test_selectRow() {
        let task0 = DataManageModel.Output.Task.pattern(robotIds: ["test1", "test2"]).generate
        let task1 = DataManageModel.Output.Task.pattern(robotIds: ["test3"]).generate
        let tasks = [task0, task1]
        XCTContext.runActivity(named: "Task一覧の場合") { _ in
            presenter.tasks = tasks
            presenter.browsing = .tasks

            XCTContext.runActivity(named: "TaskInformation画面に遷移する場合") { _ in
                let index = 1
                let indexPath = IndexPath(row: 0, section: index)
                let completionExpectation = expectation(description: "completion")

                vc.launchTaskDetailTaskInformationHandler = { jobId, robotId in
                    XCTAssertEqual(jobId, task1.jobId, "引数に正しい値が設定されていない")
                    XCTAssertEqual(robotId, "test3", "引数に正しい値が設定されていない")
                    completionExpectation.fulfill()
                }

                presenter.selectRow(indexPath: indexPath)
                wait(for: [completionExpectation], timeout: ms1000)
            }

            XCTContext.runActivity(named: "RobotSelection画面に遷移する場合") { _ in
                let index = 0
                let indexPath = IndexPath(row: 0, section: index)
                let completionExpectation = expectation(description: "completion")

                vc.launchTaskDetailRobotSelectionHandler = { taskId in
                    XCTAssertEqual(taskId, task0.id, "引数に正しい値が設定されていない")
                    completionExpectation.fulfill()
                }

                presenter.selectRow(indexPath: indexPath)
                wait(for: [completionExpectation], timeout: ms1000)
            }
        }

        XCTContext.runActivity(named: "Command一覧の場合") { _ in
            let index = 0
            let indexPath = IndexPath(row: 0, section: index)
            let completionExpectation = expectation(description: "completion")
            let command = DataManageModel.Output.Command.pattern(taskId: task0.id).generate
            var commands = DataManageModel.Output.Command.arbitrary.sample
            commands.insert(command, at: index)
            presenter.commands = commands
            presenter.browsing = .commands

            vc.launchTaskDetailTaskInformationHandler = { jobId, robotId in
                XCTAssertEqual(jobId, task0.jobId, "引数に正しい値が設定されていない")
                XCTAssertEqual(robotId, command.robotId, "引数に正しい値が設定されていない")
                completionExpectation.fulfill()
            }

            presenter.selectRow(indexPath: indexPath)
            wait(for: [completionExpectation], timeout: ms1000)
        }

    }

    func test_orderName() {
        let index = 0
        let task = DataManageModel.Output.Task.arbitrary.generate
        var tasks = DataManageModel.Output.Task.arbitrary.sample
        tasks.insert(task, at: index)

        presenter.tasks = tasks
        XCTAssertEqual(presenter.orderName(index: index), "\(task.createTime.toEpocTime.toMediumDateString)のオーダー", "正しい値が取得できていない")
    }

    func test_assignName() {
        let index = 0
        let robots = DataManageModel.Output.Robot.arbitrary.sample
        let robotIds = robots.map { $0.id }
        let name = robots[index].name!
        data.robots = robots

        XCTContext.runActivity(named: "Robotsが空の場合") { _ in
            presenter.tasks = DataManageModel.Output.Task.pattern(robotIds: []).sample
            XCTAssertNil(presenter.assignName(index: index), "正しい値が取得できていない")
        }
        XCTContext.runActivity(named: "Robotsが1つだけ存在する場合") { _ in
            presenter.tasks = DataManageModel.Output.Task.pattern(robotIds: Array(robotIds.prefix(1))).sample
            XCTAssertEqual(presenter.assignName(index: index), name, "正しい値が取得できていない")
        }
        XCTContext.runActivity(named: "Robotsが複数存在する場合") { _ in
            presenter.tasks = DataManageModel.Output.Task.pattern(robotIds: robotIds).sample
            let expected = "\(name) 他\(robotIds.count - 1)台にアサイン"
            XCTAssertEqual(presenter.assignName(index: index), expected, "正しい値が取得できていない")
        }
    }

    func test_taskStatus() {
        let index = 0
        let task = DataManageModel.Output.Task.arbitrary.generate
        var tasks = DataManageModel.Output.Task.arbitrary.sample
        tasks.insert(task, at: index)
        presenter.tasks = tasks
        XCTContext.runActivity(named: "Commandsに該当タスクが存在しない場合") { _ in
            presenter.commands = DataManageModel.Output.Command.arbitrary.sample
            XCTAssertNil(presenter.taskStatus(index: index), "正しい値が取得できていない")
        }
        XCTContext.runActivity(named: "Commandsが空の場合") { _ in
            presenter.commands = []
            XCTAssertNil(presenter.taskStatus(index: index), "正しい値が取得できていない")
        }
        XCTContext.runActivity(named: "Commandsが存在する場合") { _ in
            let command = DataManageModel.Output.Command.pattern(taskId: task.id).generate
            var commands = DataManageModel.Output.Command.arbitrary.sample
            commands.insert(command, at: index)
            presenter.commands = commands
            XCTAssertEqual(presenter.taskStatus(index: index), command.status, "正しい値が取得できていない")
        }
    }

    func test_jobName() {
        let index = 0
        let task = DataManageModel.Output.Task.arbitrary.generate
        var tasks = DataManageModel.Output.Task.arbitrary.sample
        tasks.insert(task, at: index)
        let command = DataManageModel.Output.Command.pattern(taskId: task.id).generate
        var commands = DataManageModel.Output.Command.arbitrary.sample
        commands.insert(command, at: index)
        presenter.commands = commands
        XCTContext.runActivity(named: "Tasksに当該コマンドが存在しない場合") { _ in
            presenter.tasks = DataManageModel.Output.Task.arbitrary.sample
            XCTAssertEqual(presenter.jobName(index: index), "N/A", "正しい値が取得できていない")
        }
        XCTContext.runActivity(named: "Tasksが空の場合") { _ in
            presenter.tasks.removeAll()
            XCTAssertEqual(presenter.jobName(index: index), "N/A", "正しい値が取得できていない")
        }
        XCTContext.runActivity(named: "Tasksに当該コマンドが存在する場合") { _ in
            presenter.tasks = tasks
            XCTAssertEqual(presenter.jobName(index: index), task.job.name, "正しい値が取得できていない")
        }
    }

    func test_createdAt() {
        let index = 0
        let commands = DataManageModel.Output.Command.arbitrary.sample
        let obj = commands[index]
        presenter.commands = commands

        XCTAssertEqual(presenter.createdAt(index: index), "Created at: " + obj.createTime.toEpocTime.toDateString, "正しい値が取得できていない")
    }

    func test_result() {
        let index = 0
        let commands = DataManageModel.Output.Command.arbitrary.sample
        let obj = commands[index]
        presenter.commands = commands

        XCTAssertEqual(presenter.result(index: index), "Success \(obj.success) / Fail \(obj.fail) / Error \(obj.error)", "正しい値が取得できていない")
    }

    func test_commandStatus() {
        let index = 0
        let commands = DataManageModel.Output.Command.arbitrary.sample
        let obj = commands[0]
        presenter.commands = commands

        XCTAssertEqual(presenter.commandStatus(index: index), obj.status, "正しい値が取得できていない")
    }

    func test_canGoPrev() {
        XCTContext.runActivity(named: "カーソル未設定の場合") { _ in
            presenter.cursor = nil
            XCTAssertFalse(presenter.canGoPrev(), "前のページに遷移できてしまう")
        }
        XCTContext.runActivity(named: "カーソルが先頭の場合") { _ in
            presenter.cursor = PagingModel.Cursor(offset: 0, limit: 10)
            XCTAssertFalse(presenter.canGoPrev(), "前のページに遷移できてしまう")
        }
        XCTContext.runActivity(named: "カーソルが2ページ目の場合") { _ in
            presenter.cursor = PagingModel.Cursor(offset: 20, limit: 10)
            XCTAssertTrue(presenter.canGoPrev(), "前のページに遷移できない")
        }
    }

    func test_canGoNext() {
        let total = 30
        let first = PagingModel.Cursor(offset: 0, limit: 10)
        let middle = PagingModel.Cursor(offset: 10, limit: 10)
        let last = PagingModel.Cursor(offset: 20, limit: 10)
        XCTContext.runActivity(named: "カーソルとトータルが未設定の場合") { _ in
            presenter.cursor = nil
            presenter.totalItems = nil
            XCTAssertFalse(presenter.canGoNext(), "次のページに遷移できてしまう")
        }
        XCTContext.runActivity(named: "カーソルが未設定の場合") { _ in
            presenter.cursor = nil
            presenter.totalItems = total
            XCTAssertFalse(presenter.canGoNext(), "次のページに遷移できてしまう")
        }
        XCTContext.runActivity(named: "トータルが未設定の場合") { _ in
            presenter.cursor = first
            presenter.totalItems = nil
            XCTAssertFalse(presenter.canGoNext(), "次のページに遷移できてしまう")
        }
        XCTContext.runActivity(named: "カーソルが先頭の場合") { _ in
            presenter.cursor = first
            presenter.totalItems = total
            XCTAssertTrue(presenter.canGoNext(), "次のページに遷移できない")
        }
        XCTContext.runActivity(named: "カーソルが中央の場合") { _ in
            presenter.cursor = middle
            presenter.totalItems = total
            XCTAssertTrue(presenter.canGoNext(), "次のページに遷移できない")
        }
        XCTContext.runActivity(named: "カーソルが末尾の場合") { _ in
            presenter.cursor = last
            presenter.totalItems = total
            XCTAssertFalse(presenter.canGoNext(), "次のページに遷移できてしまう")
        }
    }

    func test_totalItems() {
        let total = 30
        let first = PagingModel.Cursor(offset: 0, limit: 10)
        let middle = PagingModel.Cursor(offset: 10, limit: 10)
        let last = PagingModel.Cursor(offset: 20, limit: 10)
        XCTContext.runActivity(named: "カーソルとトータルが未設定の場合") { _ in
            presenter.cursor = nil
            presenter.totalItems = nil
            XCTAssertNil(presenter.pageText(), "ページネーションの状態が取得できてしまう")
        }
        XCTContext.runActivity(named: "カーソルが未設定の場合") { _ in
            presenter.cursor = nil
            presenter.totalItems = total
            XCTAssertNil(presenter.pageText(), "ページネーションの状態が取得できてしまう")
        }
        XCTContext.runActivity(named: "トータルが未設定の場合") { _ in
            presenter.cursor = first
            presenter.totalItems = nil
            XCTAssertNil(presenter.pageText(), "ページネーションの状態が取得できてしまう")
        }
        XCTContext.runActivity(named: "カーソルが先頭の場合") { _ in
            presenter.cursor = first
            presenter.totalItems = total
            XCTAssertEqual(presenter.pageText(), "1 / 3")
        }
        XCTContext.runActivity(named: "カーソルが中央の場合") { _ in
            presenter.cursor = middle
            presenter.totalItems = total
            XCTAssertEqual(presenter.pageText(), "2 / 3")
        }
        XCTContext.runActivity(named: "カーソルが末尾の場合") { _ in
            presenter.cursor = last
            presenter.totalItems = total
            XCTAssertEqual(presenter.pageText(), "3 / 3")
        }
    }

    func test_viewPrevPage() {
        let param = "test"
        let currentCursor = PagingModel.Cursor(offset: 10, limit: 10)
        let total = 123

        let expectedCursor = PagingModel.Cursor(offset: 0, limit: 10)

        let taksHandlerExpectation = expectation(description: "task handler")
        let commandHandlerExpectation = expectation(description: "command handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        presenter.jobData = MainViewData.Job(id: param)
        presenter.cursor = currentCursor
        presenter.totalItems = total

        data.tasksFromJobHandler = { _, cursor in
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Task]>, Error> { promise in
                promise(.success(.init(data: [DataManageModel.Output.Task.arbitrary.generate], cursor: nil, total: nil)))
                taksHandlerExpectation.fulfill()
                XCTAssertEqual(cursor, expectedCursor, "前ページ取得指定になっていない")
            }.eraseToAnyPublisher()
        }

        data.commandFromTaskHandler = { _, _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                promise(.success(DataManageModel.Output.Command.arbitrary.generate))
                commandHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.viewPrevPage()
        wait(for: [taksHandlerExpectation, commandHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertEqual(vc.reloadTableCallCount, 1, "画面が更新されない")
    }

    func test_viewNextPage() {
        let param = "test"
        let currentCursor = PagingModel.Cursor(offset: 10, limit: 10)
        let total = 123

        let expectedCursor = PagingModel.Cursor(offset: 20, limit: 10)

        let taksHandlerExpectation = expectation(description: "task handler")
        let commandHandlerExpectation = expectation(description: "command handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        presenter.jobData = MainViewData.Job(id: param)
        presenter.cursor = currentCursor
        presenter.totalItems = total

        data.tasksFromJobHandler = { _, cursor in
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Task]>, Error> { promise in
                promise(.success(.init(data: [DataManageModel.Output.Task.arbitrary.generate], cursor: nil, total: nil)))
                taksHandlerExpectation.fulfill()
                XCTAssertEqual(cursor, expectedCursor, "次ページ取得指定になっていない")
            }.eraseToAnyPublisher()
        }

        data.commandFromTaskHandler = { _, _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                promise(.success(DataManageModel.Output.Command.arbitrary.generate))
                commandHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.viewNextPage()
        wait(for: [taksHandlerExpectation, commandHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertEqual(vc.reloadTableCallCount, 1, "画面が更新されない")
    }

}
