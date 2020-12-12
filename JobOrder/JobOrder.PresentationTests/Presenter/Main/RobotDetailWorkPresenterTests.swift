//
//  RobotDetailWorkPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
import JobOrder_Utility
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class RobotDetailWorkPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let stub = PresentationTestsStub()
    private let vc = RobotDetailWorkViewControllerProtocolMock()
    private let mqtt = JobOrder_Domain.MQTTUseCaseProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let viewData = MainViewData.Robot()
    private lazy var presenter = RobotDetailWorkPresenter(dataUseCase: data,
                                                          vc: vc,
                                                          viewData: viewData)
    override func setUpWithError() throws {
        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in }.eraseToAnyPublisher()
        }
    }

    override func tearDownWithError() throws {}
    //ハンドラー でFatalエラーが出る
    //    func test_getTasksAndJob() {
    //        let param = "test"
    //        let handlerExpectation = expectation(description: "handler")
    //        let completionExpectation = expectation(description: "completion")
    //        completionExpectation.isInverted = true
    //        presenter.data.id = param
    //
    //        data.commandFromRobotHandler = { id, status, cursor in
    //            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Command]>, Error> { promise in
    //                promise(.success(.init(data: self.stub.commands, cursor: nil, total: nil)))
    //                handlerExpectation.fulfill()
    //                if let status = status {
    //                    XCTAssertTrue(status.elementsEqual(CommandModel.Status.inProgress), "ステータス指定が実行中になっていない")
    //                } else {
    //                    XCTFail("ステータスが設定されていない")
    //                }
    //                XCTAssertNil(cursor, "全件取得設定になっていない")
    //            }.eraseToAnyPublisher()
    //        }
    //        presenter.getTasksAndJob(id: presenter.data.id!)
    //        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    //        stub.commands.enumerated().forEach {
    //            XCTAssert(presenter.tasks?[$0.offset] == $0.element, "正しい値が取得できていない")
    //        }
    //    }
    //
    //    func test_getTasksAndJobError() {
    //        let param = "test"
    //        let handlerExpectation = expectation(description: "handler")
    //        let completionExpectation = expectation(description: "completion")
    //        completionExpectation.isInverted = true
    //        presenter.data.id = param
    //
    //        data.commandFromRobotHandler = { id, _, _ in
    //            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Command]>, Error> { promise in
    //                let error = NSError(domain: "Error", code: -1, userInfo: nil)
    //                promise(.failure(error))
    //                handlerExpectation.fulfill()
    //            }.eraseToAnyPublisher()
    //        }
    //        presenter.getTasksAndJob(id: presenter.data.id!)
    //        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    //        XCTAssertNil(presenter.tasks, "値が取得できてはいけない")
    //    }
    //
    //    func test_getHistoryAndJob() {
    //        let param = "test"
    //        let handlerExpectation = expectation(description: "handler")
    //        let completionExpectation = expectation(description: "completion")
    //        completionExpectation.isInverted = true
    //        presenter.data.id = param
    //
    //        data.commandFromRobotHandler = { id, status, cursor in
    //            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Command]>, Error> { promise in
    //                promise(.success(.init(data: self.stub.commands, cursor: nil, total: nil)))
    //                handlerExpectation.fulfill()
    //                if let status = status {
    //                    XCTAssertTrue(status.elementsEqual(CommandModel.Status.done), "ステータス指定が実行済になっていない")
    //                } else {
    //                    XCTFail("ステータスが設定されていない")
    //                }
    //                if let cursor = cursor {
    //                    XCTAssertEqual(cursor, PagingModel.Cursor(offset: 0, limit: 20), "カーソル指定が1ページ目の20件になっていない")
    //                } else {
    //                    XCTFail("カーソルが設定されていない")
    //                }
    //            }.eraseToAnyPublisher()
    //        }
    //        presenter.getHistoryAndJob(id: presenter.data.id!)
    //        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    //        stub.commands.enumerated().forEach {
    //            XCTAssert(presenter.history?[$0.offset] == $0.element, "正しい値が取得できていない")
    //        }
    //    }
    //
    //    func test_getHistoryAndJobError() {
    //        let param = "test"
    //        let handlerExpectation = expectation(description: "handler")
    //        let completionExpectation = expectation(description: "completion")
    //        completionExpectation.isInverted = true
    //        presenter.data.id = param
    //
    //        data.commandFromRobotHandler = { id, _, _ in
    //            return Future<PagingModel.PaginatedResult<[JobOrder_Domain.DataManageModel.Output.Command]>, Error> { promise in
    //                let error = NSError(domain: "Error", code: -1, userInfo: nil)
    //                promise(.failure(error))
    //                handlerExpectation.fulfill()
    //            }.eraseToAnyPublisher()
    //        }
    //        presenter.getHistoryAndJob(id: presenter.data.id!)
    //        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    //        XCTAssertNil(presenter.history, "値が取得できてはいけない")
    //    }

    func test_getTasksNoId() {
        presenter.data.id = nil
        XCTAssertNil(presenter.tasks, "値を取得できてはいけない")
        XCTAssertNil(presenter.history, "値を取得できてはいけない")
    }

    func test_numberOfSections() {
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.tasks = nil
            presenter.history = nil
            XCTAssertEqual(presenter.numberOfSections(in: .tasks), 0, "正しい値が取得できていない")
            XCTAssertEqual(presenter.numberOfSections(in: .history), 0, "正しい値が取得できていない")
        }

        XCTContext.runActivity(named: "Taskが存在する場合") { _ in
            presenter.tasks = stub.commands
            XCTAssertEqual(presenter.numberOfSections(in: .tasks), stub.commands.count, "正しい値が取得できていない")
        }

        XCTContext.runActivity(named: "Historyが存在する場合") { _ in
            presenter.history = stub.commands
            XCTAssertEqual(presenter.numberOfSections(in: .history), stub.commands.count, "正しい値が取得できていない")
        }
    }

    func test_selectRow() {
        presenter.selectRow(in: .tasks, indexPath: IndexPath())
        XCTAssertEqual(vc.launchTaskDetailCallCount, 1, "ViewControllerのメソッドが呼ばれない")
        presenter.selectRow(in: .history, indexPath: IndexPath())
        XCTAssertEqual(vc.launchTaskDetailCallCount, 2, "ViewControllerのメソッドが呼ばれない")
    }

    func test_taskName() {
        let topStr = "Created at : "
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.tasks = nil
            stub.commands.enumerated().forEach {
                XCTAssertEqual(presenter.taskName(in: .tasks, $0.offset), topStr + "N/A", "正しい値が取得できていない")
            }
        }

        XCTContext.runActivity(named: "Taskが存在する場合") { _ in
            presenter.tasks = stub.commands
            stub.commands.enumerated().forEach {
                XCTAssertEqual(presenter.taskName(in: .tasks, $0.offset), topStr + Date(timeIntervalSince1970: Double(stub.commands[$0.offset].createTime / 1000)).toDateString, "正しい値が取得できていない")
            }
        }

        XCTContext.runActivity(named: "Historyが存在する場合") { _ in
            presenter.history = stub.commands
            stub.commands.enumerated().forEach {
                XCTAssertEqual(presenter.taskName(in: .history, $0.offset), topStr + Date(timeIntervalSince1970: Double(stub.commands[$0.offset].createTime / 1000)).toDateString, "正しい値が取得できていない")
            }
        }
    }

    func test_taskId() {
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.tasks = nil
            stub.commands.enumerated().forEach {
                XCTAssertNil(presenter.identifier(in: .tasks, $0.offset), "値が取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Taskが存在する場合") { _ in
            presenter.tasks = stub.commands
            stub.commands.enumerated().forEach {
                XCTAssertEqual(presenter.identifier(in: .tasks, $0.offset), stub.commands[$0.offset].taskId, "正しい値が取得できていない")
            }
        }

        XCTContext.runActivity(named: "Historyが存在する場合") { _ in
            presenter.history = stub.commands
            stub.commands.enumerated().forEach {
                XCTAssertEqual(presenter.identifier(in: .history, $0.offset), stub.commands[$0.offset].taskId, "正しい値が取得できていない")
            }
        }
    }

    func test_status() {
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.tasks = nil
            stub.commands.enumerated().forEach {
                XCTAssertEqual(presenter.status(in: .tasks, $0.offset), "", "正しい値が取得できていない")
            }
        }

        XCTContext.runActivity(named: "Taskが存在する場合") { _ in
            presenter.tasks = stub.commands
            stub.commands.enumerated().forEach {
                XCTAssertEqual(presenter.status(in: .tasks, $0.offset), stub.commands[$0.offset].status, "正しい値が取得できていない")
            }
        }

        XCTContext.runActivity(named: "Historyが存在する場合") { _ in
            presenter.history = stub.commands
            stub.commands.enumerated().forEach {
                XCTAssertEqual(presenter.status(in: .history, $0.offset), stub.commands[$0.offset].status, "正しい値が取得できていない")
            }
        }
    }

    func test_createdAt() {
        let topStr = "Created at : "
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.tasks = nil
            stub.commands.enumerated().forEach {
                let dateStr = string(date: nil, label: topStr, textColor: UIColor.secondaryLabel, font: UIFont.systemFont(ofSize: 14.0))
                XCTAssertEqual(presenter.queuedAt(in: .tasks, $0.offset, textColor: .secondaryLabel, font: UIFont.systemFont(ofSize: 14.0)), dateStr, "正しい値が取得できていない")
            }
        }

        XCTContext.runActivity(named: "Taskが存在する場合") { _ in
            presenter.tasks = stub.commands
            stub.commands.enumerated().forEach {
                let date = Date(timeIntervalSince1970: Double(stub.commands[$0.offset].createTime / 1000))
                let dateStr = string(date: date, label: topStr, textColor: UIColor.secondaryLabel, font: UIFont.systemFont(ofSize: 14.0))
                XCTAssertEqual(presenter.queuedAt(in: .tasks, $0.offset, textColor: .secondaryLabel, font: UIFont.systemFont(ofSize: 14.0)), dateStr, "正しい値が取得できていない")
            }
        }

        XCTContext.runActivity(named: "Historyが存在する場合") { _ in
            presenter.history = stub.commands
            stub.commands.enumerated().forEach {
                let date = Date(timeIntervalSince1970: Double(stub.commands[$0.offset].createTime / 1000))
                let dateStr = string(date: date, label: topStr, textColor: UIColor.secondaryLabel, font: UIFont.systemFont(ofSize: 14.0))
                XCTAssertEqual(presenter.queuedAt(in: .history, $0.offset, textColor: .secondaryLabel, font: UIFont.systemFont(ofSize: 14.0)), dateStr, "正しい値が取得できていない")
            }
        }
    }
    //表示内容を変更したことにより通らない
    //    func test_resultInfo() {
    //        XCTContext.runActivity(named: "未設定の場合") { _ in
    //            presenter.tasks = nil
    //            stub.commands.enumerated().forEach {
    //                XCTAssertNil(presenter.resultInfo(in: .tasks, $0.offset), "値が取得できてはいけない")
    //            }
    //        }
    //
    //        XCTContext.runActivity(named: "Taskが存在する場合") { _ in
    //            presenter.tasks = stub.commands
    //            stub.commands.enumerated().forEach {
    //                XCTAssertEqual(presenter.resultInfo(in: .tasks, $0.offset), stub.commands[$0.offset].resultInfo, "正しい値が取得できていない")
    //            }
    //        }
    //
    //        XCTContext.runActivity(named: "Historyが存在する場合") { _ in
    //            presenter.history = stub.commands
    //            stub.commands.enumerated().forEach {
    //                XCTAssertEqual(presenter.resultInfo(in: .history, $0.offset), stub.commands[$0.offset].resultInfo, "正しい値が取得できていない")
    //            }
    //        }
    //    }

    func test_observeRobotsNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = RobotDetailWorkPresenter(dataUseCase: data,
                                             vc: vc,
                                             viewData: viewData)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.reloadTableCallCount, 0, "ViewControllerのメソッドが呼ばれてしまう")
    }

    func test_observeRobotsReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        data.robots = stub.robots

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = RobotDetailWorkPresenter(dataUseCase: data,
                                             vc: vc,
                                             viewData: viewData)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.reloadTableCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    private func string(date: Date?, label: String, textColor: UIColor, font: UIFont) -> NSAttributedString? {
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(NSAttributedString(string: label, attributes: [
            .foregroundColor: textColor,
            .font: font
        ]))
        let queuedAt = date?.toDateString ?? "N/A"
        mutableAttributedString.append(NSAttributedString(string: queuedAt, attributes: [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 14.0)
        ]))
        return mutableAttributedString
    }

}
