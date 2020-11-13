//
//  RobotDetailSystemViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class RobotDetailSystemViewControllerTests: XCTestCase {

    private let mock = RobotDetailSystemPresenterProtocolMock()
    private let vc = StoryboardScene.Main.robotDetailSystem.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.softwareConfigurationTableView, "softwareConfigurationTableViewがOutletに接続されていない")
        XCTAssertNotNil(vc.hardwareConfigurationTableView, "hardwareConfigurationTableViewがOutletに接続されていない")
    }

    func test_actions() throws {}

    func test_inject() {
        let param = "test"
        vc.inject(viewData: MainViewData.Robot(id: param))
        XCTAssertEqual(vc.viewData.id, param, "正常に値が設定されていない")
    }

    func test_viewWillAppear() {
        vc.viewWillAppear(true)
        XCTAssertEqual(mock.viewWillAppearCallCount, 1, "Presenterのメソッドが呼ばれない")
    }

    func test_set() {
        let param: CGFloat = 1.0
        vc.set(height: param)
        XCTAssertEqual(vc.initialHeight, param, "正常に呼ばれること")
    }

}
