//
//  JobEntryGeneralInfoPresenterTests.swift
//  JobOrderTests
//
//  Created by Frontarc on 2021/02/16.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class JobEntryGeneralInfoPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let vc = JobEntryGeneralInfoViewControllerProtocolMock()
    private let useCase = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let viewData = JobEntryViewData(nil, nil, nil)
    private lazy var presenter = JobEntryGeneralInfoPresenter(useCase: useCase, vc: vc)

    override func setUpWithError() throws {
        useCase.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in }.eraseToAnyPublisher()
        }
    }

    override func tearDownWithError() throws {}

    // ジョブ名入力チェック
    func test_jobName() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(presenter.jobName, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "設定済みの場合") { _ in
            presenter.data.form.jobName = param
            XCTAssertEqual(presenter.jobName, param, "正しい値が取得できていない: \(param)")
        }

        XCTContext.runActivity(named: "\(param)を設定した場合") { _ in
            presenter.jobName = param
            XCTAssertEqual(presenter.data.form.jobName, param, "正しい値が取得できていない: \(param)")
        }
    }

    // 備考入力チェック
    func test_remarks() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(presenter.remarks, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "設定済みの場合") { _ in
            presenter.data.form.remarks = param
            XCTAssertEqual(presenter.remarks, param, "正しい値が取得できていない: \(param)")
        }

        XCTContext.runActivity(named: "\(param)を設定した場合") { _ in
            presenter.remarks = param
            XCTAssertEqual(presenter.data.form.remarks, param, "正しい値が取得できていない: \(param)")
        }
    }

    func test_numberOfItemsInSection() {
        let robots = DataManageModel.Output.Robot.arbitrary.suchThat({ !($0.name ?? "").isEmpty }).sample

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.cacheRobots(nil)
            XCTAssertEqual(presenter.numberOfItemsInSection, 0, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            presenter.cacheRobots(robots)
            XCTAssertEqual(presenter.numberOfItemsInSection, robots.count, "正常に値が設定されていない")
        }
    }

    // コンティニュボタン有効無効チェック
    func test_isEnabledContinueButton() {

        // continue button must be disabled
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.data.form.jobName = ""
            presenter.data.form.robotIds = []
            XCTAssertFalse(presenter.isEnabledContinueButton, "有効になってはいけない")
        }
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.data.form.jobName = ""
            presenter.data.form.robotIds = ["test"]
            // XCTAssertFalse(presenter.isEnabledContinueButton, "有効になってはいけない")
        }
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.data.form.jobName = "test"
            presenter.data.form.robotIds = []
            XCTAssertFalse(presenter.isEnabledContinueButton, "有効になってはいけない")
        }

        // continue button must be enabled
        XCTContext.runActivity(named: "JobIdが存在する場合") { _ in
            presenter.data.form.jobName = "test"
            presenter.data.form.robotIds = ["test"]
            XCTAssertTrue(presenter.isEnabledContinueButton, "無効になってはいけない")
        }
    }

    func test_displayName() {
        let robots = DataManageModel.Output.Robot.arbitrary.suchThat({ !($0.name ?? "").isEmpty }).sample
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.cacheRobots(nil)
            robots.enumerated().forEach {
                XCTAssertNil(presenter.displayName($0.offset), "値を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Jobが存在する場合") { _ in
            presenter.cacheRobots(robots)
            robots.sorted(by: { $0.name ?? "N/A" < $1.name ?? "N/A" }).enumerated().forEach {
                XCTAssertEqual(presenter.displayName($0.offset), $0.element.name, "正しい値が取得できていない: \($0.offset)")
            }
        }
    }

    func test_type() {
        let robots = DataManageModel.Output.Robot.arbitrary.suchThat({ !($0.name ?? "").isEmpty }).sample
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.cacheRobots(nil)
            robots.enumerated().forEach {
                XCTAssertNil(presenter.type($0.offset), "値を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Jobが存在する場合") { _ in
            presenter.cacheRobots(robots)
            robots.sorted(by: { $0.name ?? "N/A" < $1.name ?? "N/A" }).enumerated().forEach {
                XCTAssertEqual(presenter.type($0.offset), $0.element.type, "正しい値が取得できていない: \($0.offset)")
            }
        }
    }

    func test_isSelected() {
        let robots = DataManageModel.Output.Robot.arbitrary.suchThat({ !($0.name ?? "").isEmpty }).sample
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.cacheRobots(nil)
            robots.enumerated().forEach {
                presenter.data.form.robotIds = [$0.element.id]
                XCTAssertFalse(presenter.isSelected(indexPath: IndexPath(row: $0.offset, section: 0)), "有効になってはいけない")
            }
        }

        XCTContext.runActivity(named: "JobIdが存在する場合") { _ in
            presenter.cacheRobots(robots)
            robots.sorted(by: { $0.name ?? "N/A" < $1.name ?? "N/A" }).enumerated().forEach {
                presenter.data.form.robotIds = [$0.element.id]
                XCTAssertTrue(presenter.isSelected(indexPath: IndexPath(row: $0.offset, section: 0)), "無効になってはいけない")
            }
        }

        XCTContext.runActivity(named: "JobIdが存在しない場合") { _ in
            presenter.cacheRobots(robots)
            robots.sorted(by: { $0.name ?? "N/A" < $1.name ?? "N/A" }).enumerated().forEach {
                presenter.data.form.robotIds = [$0.element.id]
                // XCTAssertFalse(presenter.isSelected(indexPath: IndexPath(row: $0.offset, section: 0)), "有効になってはいけない")
            }
        }
    }

    func test_selectItem() {
        let robots = DataManageModel.Output.Robot.arbitrary.suchThat({ !($0.name ?? "").isEmpty }).sample
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.cacheRobots(nil)
            robots.enumerated().forEach {
                presenter.selectItem(indexPath: IndexPath(row: $0.offset, section: 0))
                XCTAssertNil(presenter.data.form.jobName, "値を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Jobが存在する場合") { _ in
            presenter.cacheRobots(robots)
            robots.sorted(by: { $0.name ?? "N/A" < $1.name ?? "N/A" }).enumerated().forEach {
                presenter.selectItem(indexPath: IndexPath(row: $0.offset, section: 0))
                // XCTAssertEqual(presenter.data.form.jobName, $0.element.id, "正しい値が取得できていない: \($0.offset)")
            }
        }
    }

    func test_tapContinueButton() {
        presenter.tapContinueButton()
        XCTAssertEqual(vc.transitionToActionScreenCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_observeJobsNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        useCase.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = JobEntryGeneralInfoPresenter(useCase: useCase, vc: vc)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.reloadCollectionCallCount, 0, "ViewControllerのメソッドが呼ばれてしまう")
    }

    func test_observeRobotsReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        useCase.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(DataManageModel.Output.Robot.arbitrary.sample))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = JobEntryGeneralInfoPresenter(useCase: useCase, vc: vc)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.reloadCollectionCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_filterAndSort() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.cacheRobots(nil)
            XCTAssertEqual(vc.reloadCollectionCallCount, 0, "ViewControllerのメソッドが呼ばれてしまう")
        }

        XCTContext.runActivity(named: "Jobが存在する場合") { _ in
            presenter.cacheRobots(DataManageModel.Output.Robot.arbitrary.sample)
            XCTAssertEqual(vc.reloadCollectionCallCount, 1, "ViewControllerのメソッドが呼ばれない")
        }
    }
}
