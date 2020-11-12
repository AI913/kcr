//
//  RobotDetailRemarksPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class RobotDetailRemarksPresenterTests: XCTestCase {

    private let stub = PresentationTestsStub()
    private let vc = RobotDetailRemarksViewControllerProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let viewData = MainViewData.Robot()
    private lazy var presenter = RobotDetailRemarksPresenter(useCase: data,
                                                             vc: vc,
                                                             viewData: viewData)
    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_remarks() {
        let param = "test1"

        XCTContext.runActivity(named: "Dataが未設定の場合") { _ in
            presenter.data.id = nil
            data.robots = stub.robots
            XCTAssertNil(presenter.remarks, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Robotsが未設定の場合") { _ in
            presenter.data.id = param
            data.robots = nil
            XCTAssertNil(presenter.remarks, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            presenter.data.id = param
            data.robots = stub.robots
            XCTAssertEqual(presenter.remarks, stub.robot1().remarks, "正しい値が取得できていない: \(stub.robot1())")
        }
    }
}
