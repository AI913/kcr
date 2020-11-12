//
//  RobotDetailSystemPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class RobotDetailSystemPresenterTests: XCTestCase {

    private let vc = RobotDetailSystemViewControllerProtocolMock()
    private let mqtt = JobOrder_Domain.MQTTUseCaseProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let viewData = MainViewData.Robot()
    private lazy var presenter = RobotDetailSystemPresenter(mqttUseCase: mqtt,
                                                            dataUseCase: data,
                                                            vc: vc,
                                                            viewData: viewData)
    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_operatingSystem() {}
    func test_middleware() {}
    func test_systemVersion() {}
}
