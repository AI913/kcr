//
//  RobotVideoPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class RobotVideoPresenterTests: XCTestCase {

    private let vc = RobotVideoViewControllerProtocolMock()
    private let video = JobOrder_Domain.VideoStreamingUseCaseProtocolMock()
    private lazy var presenter = RobotVideoPresenter(useCase: video,
                                                     vc: vc)
    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    // TODO: 後日対応予定
}
