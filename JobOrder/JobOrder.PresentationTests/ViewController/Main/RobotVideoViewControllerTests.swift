//
//  RobotVideoViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class RobotVideoViewControllerTests: XCTestCase {

    private let mock = RobotVideoPresenterProtocolMock()
    private let vc = StoryboardScene.Main.robotVideo.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.connectButton, "connectButtonがOutletに接続されていない")
        XCTAssertNotNil(vc.indicator, "indicatorがOutletに接続されていない")
    }

    func test_actions() throws {
        let connectButton = try XCTUnwrap(vc.connectButton, "Unwrap失敗")
        XCTAssertNoThrow(connectButton.sendActions(for: .touchUpInside), "タップで例外発生: \(connectButton)")
    }

    func test_viewDidLoad() {
        vc.viewDidLoad()
        XCTAssertEqual(mock.setContainerViewCallCount, 1, "Presenterのメソッドが呼ばれない")
    }

    func test_tapConnectButton() {
        vc.connectButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(mock.tapConnectButtonCallCount, 1, "Presenterのメソッドが呼ばれない")
    }

    func test_connectButtonHidden() throws {
        let connectButton = try XCTUnwrap(vc.connectButton, "Unwrap失敗")

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(connectButton.isHidden, "ボタンが表示されていない: \(connectButton)")
        }

        XCTContext.runActivity(named: "処理中状態が変化した場合") { _ in
            vc.changedProcessing(true)
            XCTAssertTrue(connectButton.isHidden, "ボタンが表示されてはいけない: \(connectButton)")

            vc.changedProcessing(false)
            XCTAssertFalse(connectButton.isHidden, "ボタンが表示されていない: \(connectButton)")
        }
    }
}
