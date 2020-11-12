//
//  DashboardViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class DashboardViewControllerTests: XCTestCase {

    private let mock = DashboardPresenterProtocolMock()
    private let vc = StoryboardScene.Main.dashboard.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.robotStatusChartView, "robotStatusChartViewがOutletに接続されていない")
        XCTAssertNotNil(vc.executionChartView, "executionChartViewがOutletに接続されていない")
        XCTAssertNotNil(vc.errorChartView, "errorChartViewがOutletに接続されていない")
    }

    func test_actions() throws {}

    func test_showAlert() {
        vc.showErrorAlert(NSError(domain: "Error", code: -1, userInfo: nil))
        XCTAssertTrue(vc.presentedViewController is UIAlertController, "アラートが表示されない")
    }
}
