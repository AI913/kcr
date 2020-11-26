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
    private let stub = PresentationTestsStub()
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
        presenter.data.id = param

        data.tasksFromJobHandler = { id in
            return Future<[JobOrder_Domain.DataManageModel.Output.Task], Error> { promise in
                promise(.success(self.stub.tasks))
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

        XCTAssertNotNil(presenter.tasks, "正しい値が取得できていない")
        XCTAssertFalse(presenter.commands.isEmpty, "正しい値が取得できていない")
        XCTAssertTrue(stub.tasks.elementsEqual(presenter.tasks!), "正しい値が取得できていない")
        XCTAssertEqual(stub.command1(), presenter.commands.first!)
    }

    func test_viewWillAppearErrorTask() {
        let param = "test"
        let taksHandlerExpectation = expectation(description: "task handler")
        let commandHandlerExpectation = expectation(description: "command handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        commandHandlerExpectation.isInverted = true
        presenter.data.id = param

        data.tasksFromJobHandler = { id in
            return Future<[JobOrder_Domain.DataManageModel.Output.Task], Error> { promise in
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
        presenter.data.id = param

        data.tasksFromJobHandler = { id in
            return Future<[JobOrder_Domain.DataManageModel.Output.Task], Error> { promise in
                promise(.success(self.stub.tasks))
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
            presenter.tasks = stub.tasks
            XCTAssertEqual(presenter.numberOfSections(in: .task), stub.tasks.count, "正しい値が取得できていない")
        }
    }

    func test_selectRow() {
        let index = 0
        let indexPath = IndexPath(row: 0, section: index)
        presenter.tasks = stub.tasks

        vc.launchTaskDetailHandler = { taskId, robotIds in
            XCTAssertEqual(taskId, self.stub.tasks[index].id, "引数に正しい値が設定されていない")
            XCTAssertEqual(robotIds, self.stub.tasks[index].robotIds, "引数に正しい値が設定されていない")
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
            presenter.tasks = stub.tasks
            XCTAssertEqual(presenter.orderName(in: .task, index: index), "Sep 27, 2020のオーダー", "正しい値が取得できていない")
        }
    }

    func test_assignName() {
        let index = 0
        data.robots = stub.robots

        XCTContext.runActivity(named: "Tasksが未設定の場合") { _ in
            presenter.tasks = nil
            XCTAssertNil(presenter.assignName(in: .task, index: index), "正しい値が取得できていない")
        }

        XCTContext.runActivity(named: "Tasksが存在する場合") { _ in
            XCTContext.runActivity(named: "Robotsが空の場合") { _ in
                presenter.tasks = stub.tasks2
                XCTAssertNil(presenter.assignName(in: .task, index: index), "正しい値が取得できていない")
            }
            XCTContext.runActivity(named: "Robotsが1つだけ存在する場合") { _ in
                presenter.tasks = stub.tasks3
                XCTAssertEqual(presenter.assignName(in: .task, index: index), "test1", "正しい値が取得できていない")
            }
            XCTContext.runActivity(named: "Robotsが複数存在する場合") { _ in
                presenter.tasks = stub.tasks4
                XCTAssertEqual(presenter.assignName(in: .task, index: index), "test1 他2台にアサイン", "正しい値が取得できていない")
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
            presenter.tasks = stub.tasks4
            XCTContext.runActivity(named: "Commandsに該当タスクが存在しない場合") { _ in
                presenter.commands = stub.commands
                XCTAssertNil(presenter.status(in: .task, index: index), "正しい値が取得できていない")
            }
            XCTContext.runActivity(named: "Commandsが空の場合") { _ in
                presenter.commands = stub.commands2
                XCTAssertNil(presenter.status(in: .task, index: index), "正しい値が取得できていない")
            }
            XCTContext.runActivity(named: "Commandsが存在する場合") { _ in
                presenter.commands = stub.commands3
                XCTAssertEqual(presenter.status(in: .task, index: index), "queued", "正しい値が取得できていない")
            }
        }
    }
}
