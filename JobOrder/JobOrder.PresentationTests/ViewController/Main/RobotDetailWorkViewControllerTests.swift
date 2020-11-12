//
//  RobotDetailWorkViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class RobotDetailWorkViewControllerTests: XCTestCase {

    private let mock = RobotDetailWorkPresenterProtocolMock()
    private let vc = StoryboardScene.Main.robotDetailWork.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.assignedTaskLabel, "assignedTaskLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.runHistoryLabel, "runHistoryLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.orderButton, "orderButtonがOutletに接続されていない")
        XCTAssertNotNil(vc.taskTableView, "taskTableViewがOutletに接続されていない")
        XCTAssertNotNil(vc.historyTableView, "historyTableViewがOutletに接続されていない")
        XCTAssertNotNil(vc.taskTableViewHeight, "taskTableViewHeightがOutletに接続されていない")
        XCTAssertNotNil(vc.historyTableViewHeight, "historyTableViewHeightがOutletに接続されていない")
    }

    func test_actions() throws {
        let orderButton = try XCTUnwrap(vc.orderButton, "Unwrap失敗")
        XCTAssertNoThrow(orderButton.sendActions(for: .touchUpInside), "タップで例外発生: \(orderButton)")
    }

    func test_inject() {
        let param = "test"
        vc.inject(viewData: MainViewData.Robot(id: param))
        XCTAssertEqual(vc.viewData.id, param, "正常に値が設定されていない")
    }

    func test_viewWillAppear() {
        vc.viewWillAppear(true)
        XCTAssertEqual(mock.viewWillAppearCallCount, 1, "Presenterのメソッドが呼ばれない")
    }

    func test_tapOrderButton() {
        vc.orderButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(mock.tapOrderEntryButtonCallCount, 1, "Presenterのメソッドが呼ばれない")
    }

    func test_showErrorAlert() {
        vc.showErrorAlert(NSError(domain: "Error", code: -1, userInfo: nil))
        XCTAssertTrue(vc.presentedViewController is UIAlertController, "アラートが表示されない")
    }

    func test_set() {
        let param: CGFloat = 1.0
        vc.set(height: param)
        XCTAssertEqual(vc.initialHeight, param, "正常に呼ばれること")
    }
}
