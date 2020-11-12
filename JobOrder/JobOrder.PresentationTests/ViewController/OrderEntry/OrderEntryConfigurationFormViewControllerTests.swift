//
//  OrderEntryConfigurationFormViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class OrderEntryConfigurationFormViewControllerTests: XCTestCase {

    private let mock = OrderEntryConfigurationFormPresenterProtocolMock()
    private let vc = StoryboardScene.OrderEntry.configurationForm.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.startConditionValueLabel, "startConditionValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.exitConditionValueLabel, "exitConditionValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.numberOfRunsTitleLabel, "numberOfRunsTitleLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.incrementNumberOfRunsBy1Button, "incrementNumberOfRunsBy1ButtonがOutletに接続されていない")
        XCTAssertNotNil(vc.incrementNumberOfRunsBy5Button, "incrementNumberOfRunsBy5ButtonがOutletに接続されていない")
        XCTAssertNotNil(vc.incrementNumberOfRunsBy10Button, "incrementNumberOfRunsBy10ButtonがOutletに接続されていない")
        XCTAssertNotNil(vc.clearNumberOfRunsButton, "clearNumberOfRunsButtonがOutletに接続されていない")
        XCTAssertNotNil(vc.numberOfRunsTextField, "numberOfRunsTextFieldがOutletに接続されていない")
        XCTAssertNotNil(vc.remarksTextView, "remarksTextViewがOutletに接続されていない")
        XCTAssertNotNil(vc.continueButton, "continueButtonがOutletに接続されていない")
        XCTAssertNotNil(vc.scrollView, "scrollViewがOutletに接続されていない")
    }

    func test_actions() throws {
        let incrementNumberOfRunsBy1Button = try XCTUnwrap(vc.incrementNumberOfRunsBy1Button, "Unwrap失敗")
        let incrementNumberOfRunsBy5Button = try XCTUnwrap(vc.incrementNumberOfRunsBy5Button, "Unwrap失敗")
        let incrementNumberOfRunsBy10Button = try XCTUnwrap(vc.incrementNumberOfRunsBy10Button, "Unwrap失敗")
        let clearNumberOfRunsButton = try XCTUnwrap(vc.clearNumberOfRunsButton, "Unwrap失敗")
        let numberOfRunsTextField = try XCTUnwrap(vc.numberOfRunsTextField, "Unwrap失敗")
        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")
        XCTAssertNoThrow(incrementNumberOfRunsBy1Button.sendActions(for: .touchUpInside), "タップで例外発生: \(incrementNumberOfRunsBy1Button)")
        XCTAssertNoThrow(incrementNumberOfRunsBy5Button.sendActions(for: .touchUpInside), "タップで例外発生: \(incrementNumberOfRunsBy5Button)")
        XCTAssertNoThrow(incrementNumberOfRunsBy10Button.sendActions(for: .touchUpInside), "タップで例外発生: \(incrementNumberOfRunsBy10Button)")
        XCTAssertNoThrow(clearNumberOfRunsButton.sendActions(for: .touchUpInside), "タップで例外発生: \(clearNumberOfRunsButton)")
        XCTAssertNoThrow(numberOfRunsTextField.sendActions(for: .editingChanged), "文字入力で例外発生: \(numberOfRunsTextField)")
        XCTAssertNoThrow(numberOfRunsTextField.sendActions(for: .editingDidEndOnExit), "文字入力完了で例外発生: \(numberOfRunsTextField)")
        XCTAssertNoThrow(continueButton.sendActions(for: .touchUpInside), "タップで例外発生: \(continueButton)")
    }

    func test_inject() {
        let param = "test"
        vc.inject(viewData: OrderEntryViewData(param, param))
        XCTAssertEqual(vc.viewData.form.robotIds, [param], "正常に値が設定されていない")
        XCTAssertEqual(vc.viewData.form.jobId, param, "正常に値が設定されていない")
    }

    func test_continueButtonEnabled() throws {
        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")
        let param = "1"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            mock.isEnabledContinueButton = false
            vc.numberOfRunsTextField.text = param
            XCTAssertFalse(continueButton.isEnabled, "ボタンが有効になってはいけない: \(continueButton)")
        }

        XCTContext.runActivity(named: "NumberOfRunsが入力されている場合") { _ in
            mock.isEnabledContinueButton = true
            vc.numberOfRunsTextField.text = param
            vc.numberOfRunsTextField.sendActions(for: .editingDidEndOnExit)
            XCTAssertTrue(continueButton.isEnabled, "ボタンが無効になってはいけない: \(continueButton)")
        }
    }

    func test_tapContinueButton() {
        vc.continueButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(mock.tapContinueButtonCallCount, 1, "Presenterのメソッドが呼ばれない")
    }
}
