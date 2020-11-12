//
//  MainTabBarControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class MainTabBarControllerTests: XCTestCase {

    private let mock = MainPresenterProtocolMock()
    private let vc = StoryboardScene.Main.mainTabBar.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.connectionStatusBarButtonItem, "connectionStatusBarButtonItemがOutletに接続されていない")
    }

    func test_actions() throws {
        let connectionStatusBarButtonItem = try XCTUnwrap(vc.connectionStatusBarButtonItem, "Unwrap失敗")
        XCTAssertNoThrow(connectionStatusBarButtonItem.target?.perform(connectionStatusBarButtonItem.action, with: nil), "タップで例外発生: \(connectionStatusBarButtonItem)")
    }

    func test_viewDidAppear() {
        vc.viewDidAppear(true)
        XCTAssertEqual(mock.viewDidAppearCallCount, 1, "Presenterのメソッドが呼ばれない")
    }

    func test_tapConnectionStatusBarButtonItem() {
        _ = vc.connectionStatusBarButtonItem.target?.perform(vc.connectionStatusBarButtonItem.action, with: nil)
        XCTAssertEqual(mock.tapConnectionStatusButtonCallCount, 1, "Presenterのメソッドが呼ばれない")
    }

    func test_showAlert() {
        let param = "test"
        vc.showAlert(param, param)
        XCTAssertTrue(vc.presentedViewController is UIAlertController, "アラートが表示されない")
    }

    func test_showErrorAlert() {
        vc.showErrorAlert(NSError(domain: "Error", code: -1, userInfo: nil))
        XCTAssertTrue(vc.presentedViewController is UIAlertController, "アラートが表示されない")
    }

    func test_updateConnectionStatusButton() throws {
        let connectionStatusBarButtonItem = try XCTUnwrap(vc.connectionStatusBarButtonItem, "Unwrap失敗")
        let param: UIColor = .red
        vc.updateConnectionStatusButton(color: param)
        XCTAssertEqual(connectionStatusBarButtonItem.tintColor, param, "正しい色が設定されていない: \(connectionStatusBarButtonItem)")
    }
}
