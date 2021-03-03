//
//  ActionEntryConfigurationParametersResultPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Frontarc on 2021/02/16.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
import JobOrder_Utility
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class ActionEntryConfigurationParametersResultPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let vc = ActionEntryConfigurationParametersResultViewControllerProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let useCase = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let viewData = MainViewData.Job()
    private lazy var presenter = ActionEntryConfigurationParametersResultPresenter(dataUseCase: useCase, vc: vc, viewData: viewData)

    override func setUpWithError() throws {
        useCase.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in }.eraseToAnyPublisher()
        }
    }

    override func tearDownWithError() throws {}

    func test_numberOfSections() {
        let tasks = DataManageModel.Output.Task.arbitrary.sample

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.tasks = nil
            XCTAssertEqual(presenter.numberOfSections(in: .task), 0, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Taskが存在する場合") { _ in
            presenter.tasks = tasks
            XCTAssertEqual(presenter.numberOfSections(in: .task), tasks.count, "正常に値が設定されていない")
        }
    }
}
