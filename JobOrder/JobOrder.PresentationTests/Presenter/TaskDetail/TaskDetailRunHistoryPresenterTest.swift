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
    private let stub = PresentationTestsStub()
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
        presenter.jobData = MainViewData.Job(id: param)

        data.tasksFromJobHandler = { id, cursor in
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Task]>, Error> { promise in
                promise(.success(.init(data: self.stub.tasks5, cursor: expectedCursor, total: expectedTotal)))
                taksHandlerExpectation.fulfill()
                XCTAssertEqual(cursor, PagingModel.Cursor(offset: 0, limit: 10), "先頭10件取得指定になっていない")
            }.eraseToAnyPublisher()
        }

        data.commandFromTaskHandler = { _, _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                switch self.data.commandFromTaskCallCount {
                case 1:
                    promise(.success(self.stub.command1()))
                case 2:
                    promise(.success(self.stub.command2()))
                default:
                    promise(.success(self.stub.command3()))
                    commandHandlerExpectation.fulfill()
                }
            }.eraseToAnyPublisher()
        }

        presenter.viewWillAppear()
        wait(for: [taksHandlerExpectation, commandHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertEqual(presenter.commands.count, 3, "正しい値が取得できていない")
        XCTAssertTrue(stub.tasks5.elementsEqual(presenter.tasks), "正しい値が取得できていない")
        XCTAssertTrue([stub.command1(), stub.command2(), stub.command3()].elementsEqual(presenter.commands), "正しい値が取得できていない")
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
                promise(.success(self.stub.command1()))
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
        presenter.jobData = MainViewData.Job(id: param)

        data.tasksFromJobHandler = { id, _ in
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Task]>, Error> { promise in
                promise(.success(.init(data: self.stub.tasks, cursor: nil, total: nil)))
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
        presenter.robotData = robotData

        data.commandFromRobotHandler = { _, _, cursor in
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Command]>, Error> { promise in
                promise(.success(.init(data: self.stub.commands6, cursor: expectedCursor, total: expectedTotal)))
                commandHandlerExpectation.fulfill()
                XCTAssertEqual(cursor, PagingModel.Cursor(offset: 0, limit: 10), "先頭10件取得指定になっていない")
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                switch self.data.taskCallCount {
                case 1:
                    promise(.success(self.stub.task(id: "test1")))
                case 2:
                    promise(.success(self.stub.task(id: "test2")))
                default:
                    promise(.success(self.stub.task(id: "test3")))
                    taksHandlerExpectation.fulfill()
                }
            }.eraseToAnyPublisher()
        }

        presenter.viewWillAppear()
        wait(for: [taksHandlerExpectation, commandHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertEqual(presenter.commands.count, 3, "正しい値が取得できていない")
        XCTAssertTrue(stub.tasks5.elementsEqual(presenter.tasks), "正しい値が取得できていない")
        XCTAssertTrue([stub.command1(), stub.command2(), stub.command3()].elementsEqual(presenter.commands), "正しい値が取得できていない")
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
                switch self.data.taskCallCount {
                case 1:
                    promise(.success(self.stub.task(id: "test1")))
                case 2:
                    promise(.success(self.stub.task(id: "test2")))
                default:
                    promise(.success(self.stub.task(id: "test3")))
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
                promise(.success(.init(data: self.stub.commands3, cursor: nil, total: nil)))
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
                presenter.tasks = stub.tasks
                XCTAssertEqual(presenter.numberOfSections(), stub.tasks.count, "正しい値が取得できていない")
            }
        }

        XCTContext.runActivity(named: "Command一覧の場合") { _ in
            presenter.browsing = .commands
            XCTContext.runActivity(named: "未設定の場合") { _ in
                presenter.commands.removeAll()
                XCTAssertEqual(presenter.numberOfSections(), 0, "正しい値が取得できていない")
            }

            XCTContext.runActivity(named: "Tasksが存在する場合") { _ in
                presenter.commands = stub.commands
                XCTAssertEqual(presenter.numberOfSections(), stub.commands.count, "正しい値が取得できていない")
            }
        }

    }

    func test_selectRow() {

        XCTContext.runActivity(named: "Task一覧の場合") { _ in
            presenter.tasks = stub.tasks6
            presenter.browsing = .tasks

            XCTContext.runActivity(named: "TaskInformation画面に遷移する場合") { _ in
                let index = 1
                let indexPath = IndexPath(row: 0, section: index)

                vc.launchTaskDetailTaskInformationHandler = { jobId, robotId in
                    XCTAssertEqual(jobId, self.stub.tasks6[index].jobId, "引数に正しい値が設定されていない")
                    XCTAssertEqual(robotId, self.stub.tasks6[index].robotIds.first, "引数に正しい値が設定されていない")
                }

                presenter.selectRow(indexPath: indexPath)

                XCTAssertEqual(vc.launchTaskDetailTaskInformationCallCount, 1, "ViewControllerのメソッドが呼ばれない")
            }

            XCTContext.runActivity(named: "RobotSelection画面に遷移する場合") { _ in
                let index = 0
                let indexPath = IndexPath(row: 0, section: index)

                vc.launchTaskDetailRobotSelectionHandler = { taskId in
                    XCTAssertEqual(taskId, self.stub.tasks6[index].id, "引数に正しい値が設定されていない")
                }

                presenter.selectRow(indexPath: indexPath)

                XCTAssertEqual(vc.launchTaskDetailRobotSelectionCallCount, 1, "ViewControllerのメソッドが呼ばれない")
            }
        }

        XCTContext.runActivity(named: "Command一覧の場合") { _ in
            let index = 0
            let indexPath = IndexPath(row: 0, section: index)

            presenter.commands = stub.commands3
            presenter.tasks = stub.tasks
            presenter.browsing = .tasks

            vc.launchTaskDetailTaskInformationHandler = { jobId, robotId in
                XCTAssertEqual(jobId, self.stub.tasks[index].jobId, "引数に正しい値が設定されていない")
                XCTAssertEqual(robotId, self.stub.commands[index].robotId, "引数に正しい値が設定されていない")
            }

            presenter.selectRow(indexPath: indexPath)

            XCTAssertEqual(vc.launchTaskDetailTaskInformationCallCount, 1, "ViewControllerのメソッドが呼ばれない")
        }

    }

    func test_orderName() {
        let index = 0

        presenter.tasks = stub.tasks
        XCTAssertEqual(presenter.orderName(index: index), "Sep 27, 2020のオーダー", "正しい値が取得できていない")
    }

    func test_assignName() {
        let index = 0
        data.robots = stub.robots

        XCTContext.runActivity(named: "Robotsが空の場合") { _ in
            presenter.tasks = stub.tasks2
            XCTAssertNil(presenter.assignName(index: index), "正しい値が取得できていない")
        }
        XCTContext.runActivity(named: "Robotsが1つだけ存在する場合") { _ in
            presenter.tasks = stub.tasks3
            XCTAssertEqual(presenter.assignName(index: index), "test1", "正しい値が取得できていない")
        }
        XCTContext.runActivity(named: "Robotsが複数存在する場合") { _ in
            presenter.tasks = stub.tasks4
            XCTAssertEqual(presenter.assignName(index: index), "test1 他2台にアサイン", "正しい値が取得できていない")
        }
    }

    func test_taskStatus() {
        let index = 0
        presenter.tasks = stub.tasks4
        XCTContext.runActivity(named: "Commandsに該当タスクが存在しない場合") { _ in
            presenter.commands = stub.commands
            XCTAssertNil(presenter.taskStatus(index: index), "正しい値が取得できていない")
        }
        XCTContext.runActivity(named: "Commandsが空の場合") { _ in
            presenter.commands = stub.commands2
            XCTAssertNil(presenter.taskStatus(index: index), "正しい値が取得できていない")
        }
        XCTContext.runActivity(named: "Commandsが存在する場合") { _ in
            presenter.commands = stub.commands3
            XCTAssertEqual(presenter.taskStatus(index: index), "queued", "正しい値が取得できていない")
        }
    }

    func test_jobName() {
        let index = 0
        presenter.commands = stub.commands3
        XCTContext.runActivity(named: "Tasksに当該コマンドが存在しない場合") { _ in
            presenter.tasks = stub.tasks5
            XCTAssertEqual(presenter.jobName(index: index), "N/A", "正しい値が取得できていない")
        }
        XCTContext.runActivity(named: "Tasksが空の場合") { _ in
            presenter.tasks.removeAll()
            XCTAssertEqual(presenter.jobName(index: index), "N/A", "正しい値が取得できていない")
        }
        XCTContext.runActivity(named: "Tasksに当該コマンドが存在する場合") { _ in
            presenter.tasks = stub.tasks
            XCTAssertEqual(presenter.jobName(index: index), "test1", "正しい値が取得できていない")
        }
    }

    func test_createdAt() {
        let index = 0
        presenter.commands = stub.commands

        XCTAssertEqual(presenter.createdAt(index: index), "Created at: " + stub.command5().createTime.toEpocTime.toDateString, "正しい値が取得できていない")
    }

    func test_result() {
        let index = 0
        presenter.commands = stub.commands

        XCTAssertEqual(presenter.result(index: index), "Success \(stub.command5().success) / Fail \(stub.command5().fail) / Error \(stub.command5().error)", "正しい値が取得できていない")
    }

    func test_commandStatus() {
        let index = 0
        presenter.commands = stub.commands

        XCTAssertEqual(presenter.commandStatus(index: index), "failed", "正しい値が取得できていない")
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
                promise(.success(.init(data: self.stub.tasks, cursor: nil, total: nil)))
                taksHandlerExpectation.fulfill()
                XCTAssertEqual(cursor, expectedCursor, "前ページ取得指定になっていない")
            }.eraseToAnyPublisher()
        }

        data.commandFromTaskHandler = { _, _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                promise(.success(self.stub.command1()))
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
                promise(.success(.init(data: self.stub.tasks, cursor: nil, total: nil)))
                taksHandlerExpectation.fulfill()
                XCTAssertEqual(cursor, expectedCursor, "次ページ取得指定になっていない")
            }.eraseToAnyPublisher()
        }

        data.commandFromTaskHandler = { _, _ in
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                promise(.success(self.stub.command1()))
                commandHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.viewNextPage()
        wait(for: [taksHandlerExpectation, commandHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertEqual(vc.reloadTableCallCount, 1, "画面が更新されない")
    }

}
