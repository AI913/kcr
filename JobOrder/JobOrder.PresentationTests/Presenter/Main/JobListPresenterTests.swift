//
//  JobListPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class JobListPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let stub = PresentationTestsStub()
    private let vc = JobListViewControllerProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private lazy var presenter = JobListPresenter(useCase: data,
                                                  vc: vc)
    override func setUpWithError() throws {
        data.observeJobDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Job]?, Never> { promise in }.eraseToAnyPublisher()
        }
    }

    override func tearDownWithError() throws {}

    func test_numberOfRowsInSection() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertEqual(presenter.numberOfRowsInSection, 0, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Jobが存在する場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            data.observeJobDataHandler = {
                return Future<[JobOrder_Domain.DataManageModel.Output.Job]?, Never> { promise in
                    promise(.success(self.stub.jobs))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            // 初期化時に登録
            presenter = JobListPresenter(useCase: data,
                                         vc: vc)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            XCTAssertEqual(presenter.numberOfRowsInSection, stub.jobs.count, "正しい値が取得できていない")
        }
    }

    func test_id() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            stub.jobs.enumerated().forEach {
                XCTAssertNil(presenter.id($0.offset), "値を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Jobが存在する場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            data.observeJobDataHandler = {
                return Future<[JobOrder_Domain.DataManageModel.Output.Job]?, Never> { promise in
                    promise(.success(self.stub.jobs))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            // 初期化時に登録
            presenter = JobListPresenter(useCase: data,
                                         vc: vc)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            stub.jobs.enumerated().forEach {
                let id = presenter.id($0.offset)
                XCTAssertTrue(stub.jobs.contains { $0.id == id }, "正しい値が取得できていない: \($0.offset)")
            }
        }
    }

    func test_displayName() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            stub.jobs.enumerated().forEach {
                XCTAssertNil(presenter.displayName($0.offset), "値を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Jobが存在する場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            data.observeJobDataHandler = {
                return Future<[JobOrder_Domain.DataManageModel.Output.Job]?, Never> { promise in
                    promise(.success(self.stub.jobs))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            // 初期化時に登録
            presenter = JobListPresenter(useCase: data,
                                         vc: vc)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            stub.robots.enumerated().forEach {
                let name = presenter.displayName($0.offset)
                XCTAssertTrue(stub.jobs.contains { $0.name == name }, "正しい値が取得できていない: \($0.offset)")
            }
        }
    }

    func test_requirementText() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            stub.jobs.enumerated().forEach {
                XCTAssertNil(presenter.requirementText($0.offset), "値を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Jobが存在する場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            data.observeJobDataHandler = {
                return Future<[JobOrder_Domain.DataManageModel.Output.Job]?, Never> { promise in
                    promise(.success(self.stub.jobs))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            // 初期化時に登録
            presenter = JobListPresenter(useCase: data,
                                         vc: vc)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            stub.robots.enumerated().forEach {
                let requirementText = presenter.requirementText($0.offset)
                XCTAssertTrue(stub.jobs.contains { $0.overview == requirementText }, "正しい値が取得できていない: \($0.offset)")
            }
        }
    }

    func test_selectRow() {
        presenter.selectRow(index: 0)
        XCTAssertEqual(vc.transitionToJobDetailCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_tapAddButton() {
        presenter.tapAddButton()
        XCTAssertEqual(vc.launchJobEntryCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_filterAndSort() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertEqual(vc.reloadTableCallCount, 0, "ViewControllerのメソッドが呼ばれてしまう")
        }

        XCTContext.runActivity(named: "Jobが存在する場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            data.observeJobDataHandler = {
                return Future<[JobOrder_Domain.DataManageModel.Output.Job]?, Never> { promise in
                    promise(.success(self.stub.jobs))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            // 初期化時に登録
            presenter = JobListPresenter(useCase: data,
                                         vc: vc)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            XCTAssertEqual(vc.reloadTableCallCount, 1, "ViewControllerのメソッドが呼ばれない")
        }
    }

    func test_observeJobsNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        data.jobs = stub.jobs

        data.observeJobDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Job]?, Never> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = JobListPresenter(useCase: data,
                                     vc: vc)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.reloadTableCallCount, 0, "ViewControllerのメソッドが呼ばれてしまう")
    }

    func test_observeJobsReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        data.jobs = stub.jobs

        data.observeJobDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Job]?, Never> { promise in
                promise(.success(self.stub.jobs))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = JobListPresenter(useCase: data,
                                     vc: vc)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.reloadTableCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_filterAndSortParameter() {

        XCTContext.runActivity(named: "nameが全て違う場合") { _ in
            let Job1 = stub.job1(id: "2", name: "c")
            let Job2 = stub.job2(id: "3", name: "b")
            let Job3 = stub.job3(id: "1", name: "a")

            presenter.filterAndSort(keyword: nil, jobs: [Job1, Job2, Job3])
            XCTAssertEqual(presenter.displayJobs?[0].id, "1", "name順にソートされていない")
            XCTAssertEqual(presenter.displayJobs?[1].id, "3", "name順にソートされていない")
            XCTAssertEqual(presenter.displayJobs?[2].id, "2", "name順にソートされていない")
        }

        XCTContext.runActivity(named: "nameが全て同じ場合") { _ in
            let Job1 = stub.job1(id: "2", name: "a")
            let Job2 = stub.job2(id: "3", name: "a")
            let Job3 = stub.job3(id: "1", name: "a")

            presenter.filterAndSort(keyword: nil, jobs: [Job1, Job2, Job3])
            XCTAssertEqual(presenter.displayJobs?[0].id, "1", "id順にソートされていない")
            XCTAssertEqual(presenter.displayJobs?[1].id, "2", "id順にソートされていない")
            XCTAssertEqual(presenter.displayJobs?[2].id, "3", "id順にソートされていない")
        }

        XCTContext.runActivity(named: "nameが一部同じ場合") { _ in
            let Job1 = stub.job1(id: "2", name: "b")
            let Job2 = stub.job2(id: "3", name: "a")
            let Job3 = stub.job3(id: "1", name: "a")

            presenter.filterAndSort(keyword: nil, jobs: [Job1, Job2, Job3])
            XCTAssertEqual(presenter.displayJobs?[0].id, "1", "name順にソートされ、同じ場合はid順にソートされていない")
            XCTAssertEqual(presenter.displayJobs?[1].id, "3", "name順にソートされ、同じ場合はid順にソートされていない")
            XCTAssertEqual(presenter.displayJobs?[2].id, "2", "name順にソートされ、同じ場合はid順にソートされていない")
        }
    }
}
