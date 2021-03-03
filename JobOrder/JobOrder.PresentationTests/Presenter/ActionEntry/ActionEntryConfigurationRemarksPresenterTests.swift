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

class ActionEntryConfigurationRemarksPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let vc = ActionEntryConfigurationRemarksViewControllerProtocolMock()
    private let useCase = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let viewData = MainViewData.Job()
    private lazy var presenter = ActionEntryConfigurationRemarksPresenter(dataUseCase: useCase, vc: vc, viewData: viewData)

    override func setUpWithError() throws {
        useCase.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in }.eraseToAnyPublisher()
        }
    }

    override func tearDownWithError() throws {}

}
