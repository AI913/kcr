//
//  RobotDetailWorkPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
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

    func test_getTaskExecutions() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        presenter.data.id = param

        data.commandFromRobotHandler = { id in
            return Future<[JobOrder_Domain.DataManageModel.Output.Command], Error> { promise in
                promise(.success(self.stub.commands))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }
        presenter.getTaskExecutions(id: presenter.data.id!)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        stub.commands.enumerated().forEach {
            XCTAssert(presenter.commands?[$0.offset] == $0.element, "正しい値が取得できていない")
        }
    }

    func test_getTaskExectionsError() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        presenter.data.id = param

        data.commandFromRobotHandler = { id in
            return Future<[JobOrder_Domain.DataManageModel.Output.Command], Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }
        presenter.getTaskExecutions(id: presenter.data.id!)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertNil(presenter.commands, "値が取得できてはいけない")
    }

    func test_getTaskExecutionsNoId() {
        presenter.data.id = nil
        XCTAssertNil(presenter.commands, "値を取得できてはいけない")
    }

    func test_numberOfSections() {
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.commands = nil
            XCTAssertEqual(presenter.numberOfSections(), 0, "正しい値が取得できていない")
        }

        XCTContext.runActivity(named: "Commandsが存在する場合") { _ in
            presenter.commands = stub.commands
            XCTAssertEqual(presenter.numberOfSections(), stub.commands.count, "正しい値が取得できていない")
        }
    }

    func test_selectRow() {
        presenter.selectRow(indexPath: IndexPath())
        XCTAssertEqual(vc.launchTaskDetailCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_taskName() {
        let topStr = "Created at : "
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.commands = nil
            stub.commands.enumerated().forEach {
                XCTAssertEqual(presenter.taskName($0.offset), topStr + toDateString(Date(timeIntervalSince1970: Double(1))), "正しい値が取得できていない")
            }
        }

        XCTContext.runActivity(named: "Commandsが存在する場合") { _ in
            presenter.commands = stub.commands
            stub.commands.enumerated().forEach {
                XCTAssertEqual(presenter.taskName($0.offset), topStr + toDateString(Date(timeIntervalSince1970: Double(stub.commands[$0.offset].createTime / 1000))), "正しい値が取得できていない")
            }
        }
    }

    func test_taskId() {
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.commands = nil
            stub.commands.enumerated().forEach {
                XCTAssertNil(presenter.identifier($0.offset), "値が取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Commandsが存在する場合") { _ in
            presenter.commands = stub.commands
            stub.commands.enumerated().forEach {
                XCTAssertEqual(presenter.identifier($0.offset), stub.commands[$0.offset].taskId, "正しい値が取得できていない")
            }
        }
    }

    func test_status() {
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.commands = nil
            stub.commands.enumerated().forEach {
                XCTAssertEqual(presenter.status($0.offset), "", "正しい値が取得できていない")
            }
        }

        XCTContext.runActivity(named: "Commandsが存在する場合") { _ in
            presenter.commands = stub.commands
            stub.commands.enumerated().forEach {
                XCTAssertEqual(presenter.status($0.offset), stub.commands[$0.offset].status, "正しい値が取得できていない")
            }
        }
    }

    func test_createdAt() {
        let topStr = "Created at : "
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.commands = nil
            stub.commands.enumerated().forEach {
                let date = Date(timeIntervalSince1970: Double(1))
                let dateStr = string(date: date, label: topStr, textColor: UIColor.secondaryLabel, font: UIFont.systemFont(ofSize: 14.0))
                XCTAssertEqual(presenter.queuedAt($0.offset, textColor: .secondaryLabel, font: UIFont.systemFont(ofSize: 14.0)), dateStr, "正しい値が取得できていない")
            }
        }

        XCTContext.runActivity(named: "Commandsが存在する場合") { _ in
            presenter.commands = stub.commands
            stub.commands.enumerated().forEach {
                let date = Date(timeIntervalSince1970: Double(stub.commands[$0.offset].createTime / 1000))
                let dateStr = string(date: date, label: topStr, textColor: UIColor.secondaryLabel, font: UIFont.systemFont(ofSize: 14.0))
                XCTAssertEqual(presenter.queuedAt($0.offset, textColor: .secondaryLabel, font: UIFont.systemFont(ofSize: 14.0)), dateStr, "正しい値が取得できていない")
            }
        }
    }

    func test_resultInfo() {
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.commands = nil
            stub.commands.enumerated().forEach {
                XCTAssertNil(presenter.resultInfo($0.offset), "値が取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Commandsが存在する場合") { _ in
            presenter.commands = stub.commands
            stub.commands.enumerated().forEach {
                XCTAssertEqual(presenter.resultInfo($0.offset), stub.commands[$0.offset].resultInfo, "正しい値が取得できていない")
            }
        }
    }

    func test_tapOrderEntryButton() {
        presenter.tapOrderEntryButton()
        XCTAssertEqual(vc.launchOrderEntryCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

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
        let queuedAt = toDateString(date)
        mutableAttributedString.append(NSAttributedString(string: queuedAt, attributes: [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 14.0)
        ]))
        return mutableAttributedString
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
