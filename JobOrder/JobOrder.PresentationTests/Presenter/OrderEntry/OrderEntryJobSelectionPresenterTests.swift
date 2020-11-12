//
//  OrderEntryJobSelectionPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class OrderEntryJobSelectionPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let stub = PresentationTestsStub()
    private let vc = OrderEntryJobSelectionViewControllerProtocolMock()
    private let useCase = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let viewData = OrderEntryViewData(nil, nil)
    private lazy var presenter = OrderEntryJobSelectionPresenter(useCase: useCase,
                                                                 vc: vc,
                                                                 viewData: viewData)

    override func setUpWithError() throws {
        useCase.observeJobDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Job]?, Never> { promise in }.eraseToAnyPublisher()
        }
    }

    override func tearDownWithError() throws {}

    func test_numberOfItemsInSection() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.cacheJobs(nil)
            XCTAssertEqual(presenter.numberOfItemsInSection, 0, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Jobが存在する場合") { _ in
            presenter.cacheJobs(stub.jobs)
            XCTAssertEqual(presenter.numberOfItemsInSection, stub.jobs.count, "正常に値が設定されていない")
        }
    }

    func test_isEnabledContinueButton() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(presenter.isEnabledContinueButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "JobIdが存在する場合") { _ in
            presenter.data.form.jobId = "test"
            XCTAssertTrue(presenter.isEnabledContinueButton, "無効になってはいけない")
        }
    }

    func test_viewDidLoad() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.viewDidLoad()
            XCTAssertEqual(vc.transitionToRobotSelectionScreenCallCount, 0, "ViewControllerのメソッドが呼ばれない")
        }

        XCTContext.runActivity(named: "JobIdが存在する場合") { _ in
            presenter.data.form.jobId = "test"
            presenter.viewDidLoad()
            XCTAssertEqual(vc.transitionToRobotSelectionScreenCallCount, 1, "ViewControllerのメソッドが呼ばれてしまう")
        }
    }

    func test_displayName() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.cacheJobs(nil)
            stub.jobs.enumerated().forEach {
                XCTAssertNil(presenter.displayName($0.offset), "値を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Jobが存在する場合") { _ in
            presenter.cacheJobs(stub.jobs)
            stub.jobs.enumerated().forEach {
                XCTAssertEqual(presenter.displayName($0.offset), $0.element.name, "正しい値が取得できていない: \($0.offset)")
            }
        }
    }

    func test_requirementText() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.cacheJobs(nil)
            stub.jobs.enumerated().forEach {
                XCTAssertNil(presenter.requirementText($0.offset), "値を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Jobが存在する場合") { _ in
            presenter.cacheJobs(stub.jobs)
            stub.jobs.enumerated().forEach {
                XCTAssertEqual(presenter.requirementText($0.offset), $0.element.overview, "正しい値が取得できていない: \($0.offset)")
            }
        }
    }

    func test_isSelected() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.cacheJobs(nil)
            stub.jobs.enumerated().forEach {
                presenter.data.form.jobId = $0.element.id
                XCTAssertFalse(presenter.isSelected(indexPath: IndexPath(row: $0.offset, section: 0)), "有効になってはいけない")
            }
        }

        XCTContext.runActivity(named: "JobIdが存在する場合") { _ in
            presenter.cacheJobs(stub.jobs)
            stub.jobs.enumerated().forEach {
                presenter.data.form.jobId = $0.element.id
                XCTAssertTrue(presenter.isSelected(indexPath: IndexPath(row: $0.offset, section: 0)), "無効になってはいけない")
            }
        }

        XCTContext.runActivity(named: "JobIdが存在しない場合") { _ in
            presenter.cacheJobs(stub.jobs)
            stub.jobs.enumerated().forEach {
                presenter.data.form.jobId = nil
                XCTAssertFalse(presenter.isSelected(indexPath: IndexPath(row: $0.offset, section: 0)), "有効になってはいけない")
            }
        }
    }

    func test_selectItem() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.cacheJobs(nil)
            stub.jobs.enumerated().forEach {
                presenter.selectItem(indexPath: IndexPath(row: $0.offset, section: 0))
                XCTAssertNil(presenter.data.form.jobId, "値を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Jobが存在する場合") { _ in
            presenter.cacheJobs(stub.jobs)
            stub.jobs.enumerated().forEach {
                presenter.selectItem(indexPath: IndexPath(row: $0.offset, section: 0))
                XCTAssertEqual(presenter.data.form.jobId, $0.element.id, "正しい値が取得できていない: \($0.offset)")
            }
        }
    }

    func test_tapContinueButton() {
        presenter.tapContinueButton()
        XCTAssertEqual(vc.transitionToRobotSelectionScreenCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_observeJobsNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        useCase.observeJobDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Job]?, Never> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = OrderEntryJobSelectionPresenter(useCase: useCase,
                                                    vc: vc,
                                                    viewData: viewData)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.reloadCollectionCallCount, 0, "ViewControllerのメソッドが呼ばれてしまう")
    }

    func test_observeJobsReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        useCase.observeJobDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Job]?, Never> { promise in
                promise(.success(self.stub.jobs))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = OrderEntryJobSelectionPresenter(useCase: useCase,
                                                    vc: vc,
                                                    viewData: viewData)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.reloadCollectionCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_filterAndSort() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.cacheJobs(nil)
            XCTAssertEqual(vc.reloadCollectionCallCount, 0, "ViewControllerのメソッドが呼ばれてしまう")
        }

        XCTContext.runActivity(named: "Jobが存在する場合") { _ in
            presenter.cacheJobs(stub.jobs)
            XCTAssertEqual(vc.reloadCollectionCallCount, 1, "ViewControllerのメソッドが呼ばれない")
        }
    }
}
