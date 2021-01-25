//
//  TaskDetailExecutionLogPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by 藤井一暢 on 2020/12/15.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class TaskDetailExecutionLogPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let vc = TaskDetailExecutionLogViewControllerProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let viewData = TaskDetailViewData()
    private lazy var presenter = TaskDetailExecutionLogPresenter(dataUseCase: data, vc: vc, viewData: viewData)

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_viewWillAppear() {
        let param1 = "test1"
        let param2 = "test2"

        let expectedCursor = PagingModel.Cursor(offset: 0, limit: 20)
        let expectedTotal = 123

        let taksHandlerExpectation = expectation(description: "task handler")
        let commandHandlerExpectation = expectation(description: "command handler")
        let executionLogHandlerExpectation = expectation(description: "execution log handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        let command = DataManageModel.Output.Command.arbitrary.generate
        let task = DataManageModel.Output.Task.arbitrary.generate
        let executionLogs = DataManageModel.Output.ExecutionLog.arbitrary.sample

        presenter.viewData = TaskDetailViewData(taskId: param1, robotId: param2)

        data.commandFromTaskHandler = { taskId, robotId in
            XCTAssertEqual(taskId, param1, "正しい値が指定されていない")
            XCTAssertEqual(robotId, param2, "正しい値が指定されていない")
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                promise(.success(command))
                commandHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { taskId in
            XCTAssertEqual(taskId, param1, "正しい値が指定されていない")
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                promise(.success(task))
                taksHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.executionLogsFromTaskHandler = { taskId, robotId, cursor in
            XCTAssertEqual(taskId, param1, "正しい値が指定されていない")
            XCTAssertEqual(robotId, param2, "正しい値が指定されていない")
            XCTAssertEqual(cursor, PagingModel.Cursor(offset: 0, limit: 10), "先頭10件取得指定になっていない")
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.ExecutionLog]>, Error> { promise in
                promise(.success(.init(data: executionLogs, cursor: expectedCursor, total: expectedTotal)))
                executionLogHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        vc.setJobHandler = { name in
            XCTAssertEqual(name, task.job.name, "正しい値が取得できていない")
        }

        vc.setRobotHandler = { name in
            XCTAssertEqual(name, command.robot?.name, "正しい値が取得できていない")
        }

        presenter.viewWillAppear()
        wait(for: [taksHandlerExpectation, commandHandlerExpectation, executionLogHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertEqual(presenter.executionLogs.count, executionLogs.count, "正しい値が取得できていない")
        XCTAssertTrue(presenter.executionLogs.elementsEqual(executionLogs), "正しい値が取得できていない")
        XCTAssertEqual(presenter.cursor, expectedCursor, "正しい値が取得できていない")
        XCTAssertEqual(presenter.totalItems, expectedTotal, "正しい値が取得できていない")
        XCTAssertEqual(vc.reloadTableCallCount, 1, "画面が更新されない")
        XCTAssertEqual(vc.setRobotCallCount, 1, "画面が更新されない")
        XCTAssertEqual(vc.setJobCallCount, 1, "画面が更新されない")
    }

    func test_viewWillAppearErrorCommand() {
        let param1 = "test1"
        let param2 = "test2"

        let expectedCursor = PagingModel.Cursor(offset: 0, limit: 20)
        let expectedTotal = 123

        let taksHandlerExpectation = expectation(description: "task handler")
        let commandHandlerExpectation = expectation(description: "command handler")
        let executionLogHandlerExpectation = expectation(description: "execution log handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let task = DataManageModel.Output.Task.arbitrary.generate
        let executionLogs = DataManageModel.Output.ExecutionLog.arbitrary.sample

        presenter.viewData = TaskDetailViewData(taskId: param1, robotId: param2)

        data.commandFromTaskHandler = { taskId, robotId in
            XCTAssertEqual(taskId, param1, "正しい値が指定されていない")
            XCTAssertEqual(robotId, param2, "正しい値が指定されていない")
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                commandHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { taskId in
            XCTAssertEqual(taskId, param1, "正しい値が指定されていない")
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                promise(.success(task))
                taksHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.executionLogsFromTaskHandler = { taskId, robotId, cursor in
            XCTAssertEqual(taskId, param1, "正しい値が指定されていない")
            XCTAssertEqual(robotId, param2, "正しい値が指定されていない")
            XCTAssertEqual(cursor, PagingModel.Cursor(offset: 0, limit: 10), "先頭10件取得指定になっていない")
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.ExecutionLog]>, Error> { promise in
                promise(.success(.init(data: executionLogs, cursor: expectedCursor, total: expectedTotal)))
                executionLogHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        vc.setJobHandler = { name in
            XCTAssertEqual(name, task.job.name, "正しい値が取得できていない")
        }

        presenter.viewWillAppear()
        wait(for: [taksHandlerExpectation, commandHandlerExpectation, executionLogHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertEqual(presenter.executionLogs.count, executionLogs.count, "正しい値が取得できていない")
        XCTAssertTrue(presenter.executionLogs.elementsEqual(executionLogs), "正しい値が取得できていない")
        XCTAssertEqual(presenter.cursor, expectedCursor, "正しい値が取得できていない")
        XCTAssertEqual(presenter.totalItems, expectedTotal, "正しい値が取得できていない")
        XCTAssertEqual(vc.reloadTableCallCount, 1, "画面が更新されない")
        XCTAssertEqual(vc.setRobotCallCount, 0, "画面が更新されてしまった")
        XCTAssertEqual(vc.setJobCallCount, 1, "画面が更新されない")
    }

    func test_viewWillAppearErrorTask() {
        let param1 = "test1"
        let param2 = "test2"

        let expectedCursor = PagingModel.Cursor(offset: 0, limit: 20)
        let expectedTotal = 123

        let taksHandlerExpectation = expectation(description: "task handler")
        let commandHandlerExpectation = expectation(description: "command handler")
        let executionLogHandlerExpectation = expectation(description: "execution log handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        let command = DataManageModel.Output.Command.arbitrary.generate
        let executionLogs = DataManageModel.Output.ExecutionLog.arbitrary.sample

        presenter.viewData = TaskDetailViewData(taskId: param1, robotId: param2)

        data.commandFromTaskHandler = { taskId, robotId in
            XCTAssertEqual(taskId, param1, "正しい値が指定されていない")
            XCTAssertEqual(robotId, param2, "正しい値が指定されていない")
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                promise(.success(command))
                commandHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { taskId in
            XCTAssertEqual(taskId, param1, "正しい値が指定されていない")
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                taksHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.executionLogsFromTaskHandler = { taskId, robotId, cursor in
            XCTAssertEqual(taskId, param1, "正しい値が指定されていない")
            XCTAssertEqual(robotId, param2, "正しい値が指定されていない")
            XCTAssertEqual(cursor, PagingModel.Cursor(offset: 0, limit: 10), "先頭10件取得指定になっていない")
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.ExecutionLog]>, Error> { promise in
                promise(.success(.init(data: executionLogs, cursor: expectedCursor, total: expectedTotal)))
                executionLogHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        vc.setRobotHandler = { name in
            XCTAssertEqual(name, command.robot?.name, "正しい値が取得できていない")
        }

        presenter.viewWillAppear()
        wait(for: [taksHandlerExpectation, commandHandlerExpectation, executionLogHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertEqual(presenter.executionLogs.count, executionLogs.count, "正しい値が取得できていない")
        XCTAssertTrue(presenter.executionLogs.elementsEqual(executionLogs), "正しい値が取得できていない")
        XCTAssertEqual(presenter.cursor, expectedCursor, "正しい値が取得できていない")
        XCTAssertEqual(presenter.totalItems, expectedTotal, "正しい値が取得できていない")
        XCTAssertEqual(vc.reloadTableCallCount, 1, "画面が更新されない")
        XCTAssertEqual(vc.setRobotCallCount, 1, "画面が更新されない")
        XCTAssertEqual(vc.setJobCallCount, 0, "画面が更新されてしまった")
    }

    func test_viewWillAppearErrorExecution() {
        let param1 = "test1"
        let param2 = "test2"

        let taksHandlerExpectation = expectation(description: "task handler")
        let commandHandlerExpectation = expectation(description: "command handler")
        let executionLogHandlerExpectation = expectation(description: "execution log handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        let command = DataManageModel.Output.Command.arbitrary.generate
        let task = DataManageModel.Output.Task.arbitrary.generate

        presenter.viewData = TaskDetailViewData(taskId: param1, robotId: param2)

        data.commandFromTaskHandler = { taskId, robotId in
            XCTAssertEqual(taskId, param1, "正しい値が指定されていない")
            XCTAssertEqual(robotId, param2, "正しい値が指定されていない")
            return Future<JobOrder_Domain.DataManageModel.Output.Command, Error> { promise in
                promise(.success(command))
                commandHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.taskHandler = { taskId in
            XCTAssertEqual(taskId, param1, "正しい値が指定されていない")
            return Future<JobOrder_Domain.DataManageModel.Output.Task, Error> { promise in
                promise(.success(task))
                taksHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        data.executionLogsFromTaskHandler = { taskId, robotId, cursor in
            XCTAssertEqual(taskId, param1, "正しい値が指定されていない")
            XCTAssertEqual(robotId, param2, "正しい値が指定されていない")
            XCTAssertEqual(cursor, PagingModel.Cursor(offset: 0, limit: 10), "先頭10件取得指定になっていない")
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.ExecutionLog]>, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                executionLogHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        vc.setJobHandler = { name in
            XCTAssertEqual(name, task.job.name, "正しい値が取得できていない")
        }

        vc.setRobotHandler = { name in
            XCTAssertEqual(name, command.robot?.name, "正しい値が取得できていない")
        }

        presenter.viewWillAppear()
        wait(for: [taksHandlerExpectation, commandHandlerExpectation, executionLogHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertEqual(presenter.executionLogs.count, 0, "値が取得されてしまった")
        XCTAssertNil(presenter.cursor, "値が取得されてしまった")
        XCTAssertNil(presenter.totalItems, "値が取得されてしまった")
        XCTAssertEqual(vc.reloadTableCallCount, 0, "画面が更新されてしまった")
        XCTAssertEqual(vc.setRobotCallCount, 1, "画面が更新されない")
        XCTAssertEqual(vc.setJobCallCount, 1, "画面が更新されない")
    }

    func test_numberOfSections() {
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.executionLogs.removeAll()
            XCTAssertEqual(presenter.numberOfSections(), 0, "正しい値が取得できていない")
        }

        XCTContext.runActivity(named: "Tasksが存在する場合") { _ in
            let executionLogs = DataManageModel.Output.ExecutionLog.arbitrary.sample
            presenter.executionLogs = executionLogs
            XCTAssertEqual(presenter.numberOfSections(), executionLogs.count, "正しい値が取得できていない")
        }
    }

    func test_result() {
        let index = 0
        let executionLog = DataManageModel.Output.ExecutionLog.arbitrary.generate
        var executionLogs = DataManageModel.Output.ExecutionLog.arbitrary.sample
        executionLogs.insert(executionLog, at: index)
        presenter.executionLogs = executionLogs

        XCTAssertEqual(presenter.result(index: index), executionLog.result, "正しい値が取得できていない")
    }

    func test_executedAt() {
        let index = 0
        let executionLog = DataManageModel.Output.ExecutionLog.arbitrary.generate
        var executionLogs = DataManageModel.Output.ExecutionLog.arbitrary.sample
        executionLogs.insert(executionLog, at: index)
        presenter.executionLogs = executionLogs

        XCTAssertEqual(presenter.executedAt(index: index), executionLog.executedAt.toEpocTime.toMediumDateTimeString, "正しい値が取得できていない")
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

        let executionLogHandlerExpectation = expectation(description: "execution log handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let executionLogs = DataManageModel.Output.ExecutionLog.arbitrary.sample

        presenter.viewData = TaskDetailViewData(taskId: param, robotId: param)
        presenter.cursor = currentCursor
        presenter.totalItems = total

        data.executionLogsFromTaskHandler = { _, _, cursor in
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.ExecutionLog]>, Error> { promise in
                promise(.success(.init(data: executionLogs, cursor: nil, total: nil)))
                executionLogHandlerExpectation.fulfill()
                XCTAssertEqual(cursor, expectedCursor, "前ページ取得指定になっていない")
            }.eraseToAnyPublisher()
        }

        presenter.viewPrevPage()
        wait(for: [executionLogHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertEqual(vc.reloadTableCallCount, 1, "画面が更新されない")
    }

    func test_viewNextPage() {
        let param = "test"
        let currentCursor = PagingModel.Cursor(offset: 10, limit: 10)
        let total = 123

        let expectedCursor = PagingModel.Cursor(offset: 20, limit: 10)

        let executionLogHandlerExpectation = expectation(description: "execution log handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let executionLogs = DataManageModel.Output.ExecutionLog.arbitrary.sample

        presenter.viewData = TaskDetailViewData(taskId: param, robotId: param)
        presenter.cursor = currentCursor
        presenter.totalItems = total

        data.executionLogsFromTaskHandler = { _, _, cursor in
            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.ExecutionLog]>, Error> { promise in
                promise(.success(.init(data: executionLogs, cursor: nil, total: nil)))
                executionLogHandlerExpectation.fulfill()
                XCTAssertEqual(cursor, expectedCursor, "次ページ取得指定になっていない")
            }.eraseToAnyPublisher()
        }

        presenter.viewNextPage()
        wait(for: [executionLogHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertEqual(vc.reloadTableCallCount, 1, "画面が更新されない")
    }
}
