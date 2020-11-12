//
//  OrderEntryRobotSelectionPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class OrderEntryRobotSelectionPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let stub = PresentationTestsStub()
    private let vc = OrderEntryRobotSelectionViewControllerProtocolMock()
    private let useCase = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let viewData = OrderEntryViewData(nil, nil)
    private lazy var presenter = OrderEntryRobotSelectionPresenter(useCase: useCase,
                                                                   vc: vc,
                                                                   viewData: viewData)

    override func setUpWithError() throws {
        useCase.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in }.eraseToAnyPublisher()
        }
    }

    override func tearDownWithError() throws {}

    func test_numberOfItemsInSection() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.cacheRobots(nil)
            XCTAssertEqual(presenter.numberOfItemsInSection, 0, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            presenter.cacheRobots(stub.robots)
            XCTAssertEqual(presenter.numberOfItemsInSection, stub.robots.count, "正常に値が設定されていない")
        }
    }

    func test_isEnabledContinueButton() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(presenter.isEnabledContinueButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "RobotIdが存在する場合") { _ in
            presenter.data.form.robotIds = ["test"]
            XCTAssertTrue(presenter.isEnabledContinueButton, "無効になってはいけない")
        }
    }

    func test_displayName() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.cacheRobots(nil)
            stub.robots.enumerated().forEach {
                XCTAssertNil(presenter.displayName($0.offset), "値を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            presenter.cacheRobots(stub.robots)
            stub.robots.enumerated().forEach {
                XCTAssertEqual(presenter.displayName($0.offset), $0.element.name, "正しい値が取得できていない: \($0.offset)")
            }
        }
    }

    func test_type() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.cacheRobots(nil)
            stub.robots.enumerated().forEach {
                XCTAssertNil(presenter.type($0.offset), "値を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            presenter.cacheRobots(stub.robots)
            stub.robots.enumerated().forEach {
                XCTAssertEqual(presenter.type($0.offset), $0.element.type, "正しい値が取得できていない: \($0.offset)")
            }
        }
    }

    func test_isSelected() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.cacheRobots(nil)
            stub.robots.enumerated().forEach {
                presenter.data.form.robotIds = [$0.element.id]
                XCTAssertFalse(presenter.isSelected(indexPath: IndexPath(row: $0.offset, section: 0)), "有効になってはいけない")
            }
        }

        XCTContext.runActivity(named: "RobotIdが存在する場合") { _ in
            presenter.cacheRobots(stub.robots)
            stub.robots.enumerated().forEach {
                presenter.data.form.robotIds = [$0.element.id]
                XCTAssertTrue(presenter.isSelected(indexPath: IndexPath(row: $0.offset, section: 0)), "無効になってはいけない")
            }
        }

        XCTContext.runActivity(named: "RobotIdが存在しない場合") { _ in
            presenter.cacheRobots(stub.robots)
            stub.robots.enumerated().forEach {
                presenter.data.form.robotIds = nil
                XCTAssertFalse(presenter.isSelected(indexPath: IndexPath(row: $0.offset, section: 0)), "有効になってはいけない")
            }
        }
    }

    func test_selectItem() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.data.form.robotIds = nil
            presenter.cacheRobots(nil)
            stub.robots.enumerated().forEach {
                presenter.selectItem(indexPath: IndexPath(row: $0.offset, section: 0))
                XCTAssertNil(presenter.data.form.robotIds, "値を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Robotを選択した場合") { _ in
            presenter.cacheRobots(stub.robots)
            stub.robots.enumerated().forEach {
                presenter.selectItem(indexPath: IndexPath(row: $0.offset, section: 0))
                do {
                    let robotIds = try XCTUnwrap(presenter.data.form.robotIds, "Unwrap失敗")
                    XCTAssertTrue(robotIds.contains($0.element.id), "正しい値が取得できていない: \($0.offset)")
                } catch {}
            }
        }

        XCTContext.runActivity(named: "選択済みのRobotを解除した場合") { _ in
            presenter.cacheRobots(stub.robots)
            stub.robots.enumerated().forEach {
                presenter.selectItem(indexPath: IndexPath(row: $0.offset, section: 0))
                do {
                    let robotIds = try XCTUnwrap(presenter.data.form.robotIds, "Unwrap失敗")
                    XCTAssertFalse(robotIds.contains($0.element.id), "正しい値が取得できていない: \($0.offset)")
                } catch {}
            }
        }
    }

    func test_tapContinueButton() {
        presenter.tapContinueButton()
        XCTAssertEqual(vc.transitionToConfigurationFormScreenCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_observeRobotsNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        useCase.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = OrderEntryRobotSelectionPresenter(useCase: useCase,
                                                      vc: vc,
                                                      viewData: viewData)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.reloadCollectionCallCount, 0, "ViewControllerのメソッドが呼ばれてしまう")
    }

    func test_observeRobotsReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        useCase.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(self.stub.robots))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = OrderEntryRobotSelectionPresenter(useCase: useCase,
                                                      vc: vc,
                                                      viewData: viewData)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.reloadCollectionCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_filterAndSort() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.cacheRobots(nil)
            XCTAssertEqual(vc.reloadCollectionCallCount, 0, "ViewControllerのメソッドが呼ばれてしまう")
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            presenter.cacheRobots(stub.robots)
            XCTAssertEqual(vc.reloadCollectionCallCount, 1, "ViewControllerのメソッドが呼ばれない")
        }
    }
}
