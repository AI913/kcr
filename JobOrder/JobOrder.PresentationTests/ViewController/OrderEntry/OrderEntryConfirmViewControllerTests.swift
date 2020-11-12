//
//  OrderEntryConfirmViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class OrderEntryConfirmViewControllerTests: XCTestCase {

    private let mock = OrderEntryConfirmPresenterProtocolMock()
    private let vc = StoryboardScene.OrderEntry.confirm.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.jobValueLabel, "jobValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.robotsValueLabel, "robotsValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.startConditionValueLabel, "startConditionValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.exitConditionValueLabel, "exitConditionValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.numberOfRunsValueLabel, "numberOfRunsValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.remarksValueLabel, "remarksValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.sendButton, "sendButtonがOutletに接続されていない")
    }

    func test_actions() throws {
        let sendButton = try XCTUnwrap(vc.sendButton, "Unwrap失敗")
        XCTAssertNoThrow(sendButton.sendActions(for: .touchUpInside), "タップで例外発生: \(sendButton)")
    }

    func test_inject() {
        let param = "test"
        vc.inject(viewData: OrderEntryViewData(param, param))
        XCTAssertEqual(vc.viewData.form.robotIds, [param], "正常に値が設定されていない")
        XCTAssertEqual(vc.viewData.form.jobId, param, "正常に値が設定されていない")
    }

    func test_processing() throws {
        let sendButton = try XCTUnwrap(vc.sendButton, "Unwrap失敗")

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertTrue(sendButton.isEnabled, "ボタンが無効になってはいけない: \(sendButton)")
        }

        XCTContext.runActivity(named: "処理中の場合") { _ in
            vc.changedProcessing(true)
            XCTAssertFalse(sendButton.isEnabled, "ボタンが有効になってはいけない: \(sendButton)")
        }

        XCTContext.runActivity(named: "処理中でない場合") { _ in
            vc.changedProcessing(false)
            XCTAssertTrue(sendButton.isEnabled, "ボタンが無効になってはいけない: \(sendButton)")
        }
    }

    func test_tapSendButton() {
        vc.sendButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(mock.tapSendButtonCallCount, 1, "Presenterのメソッドが呼ばれない")
    }

    func test_showAlert() {
        vc.showErrorAlert(NSError(domain: "Error", code: -1, userInfo: nil))
        XCTAssertTrue(vc.presentedViewController is UIAlertController, "アラートが表示されない")
    }
}
