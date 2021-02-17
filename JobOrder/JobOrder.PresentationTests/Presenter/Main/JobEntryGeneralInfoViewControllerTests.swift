//
//  JobEntryGeneralInfoViewControllerTests.swift
//  JobOrderTests
//
//  Created by Frontarc on 2021/02/16.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class JobEntryGeneralInfoViewControllerTests: XCTestCase {

    private let mock = JobEntryGeneralInfoPresenterProtocolMock()
    private let vc = StoryboardScene.JobEntry.form.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.robotCollection, "robotCollectionがOutletに接続されていない")
        XCTAssertNotNil(vc.subtitle, "subtitleがOutletに接続されていない")
        XCTAssertNotNil(vc.jobNameTitleLabel, "jobNameTitleLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.jobNameTextField, "jobNameTextFieldがOutletに接続されていない")
        XCTAssertNotNil(vc.overviewTitleLabel, "overviewTitleLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.overviewTextView, "overviewTextViewがOutletに接続されていない")
        XCTAssertNotNil(vc.cancelBarButtonItem, "cancelBarButtonItemがOutletに接続されていない")
        XCTAssertNotNil(vc.continueButton, "continueButtonがOutletに接続されていない")
    }

//    func test_actions() throws {
//        let jobNameTextField = try XCTUnwrap(vc.jobNameTextField, "Unwrap失敗")
//        let overviewTextView = try XCTUnwrap(vc.overviewTextView, "Unwrap失敗")
//        let cancelBarButtonItem = try XCTUnwrap(vc.cancelBarButtonItem, "Unwrap失敗")
//        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")
//        XCTAssertNoThrow(jobNameTextField.sendActions(for: .editingChanged), "文字入力で例外発生: \(jobNameTextField)")
//        XCTAssertNoThrow(overviewTextView.sendActions(for: .editingChanged), "文字入力完了で例外発生: \(overviewTextView)")
//        XCTAssertNoThrow(cancelBarButtonItem.target?.perform(cancelBarButtonItem.action, with: nil), "タップで例外発生: \(cancelBarButtonItem)")
//        XCTAssertNoThrow(continueButton.sendActions(for: .touchUpInside), "タップで例外発生: \(continueButton)")
//    }
//
//    func test_inject() {
//        let param = "test"
//        vc.inject(viewData: OrderEntryViewData(param, param))
//        XCTAssertEqual(vc.viewData.form.robotIds, [param], "正常に値が設定されていない")
//        XCTAssertEqual(vc.viewData.form.jobId, param, "正常に値が設定されていない")
//    }
//
//    func test_continueButtonEnabled() throws {
//        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")
//        let param = "1"
//
//        XCTContext.runActivity(named: "未設定の場合") { _ in
//            mock.isEnabledContinueButton = false
//            vc.numberOfRunsTextField.text = param
//            XCTAssertFalse(continueButton.isEnabled, "ボタンが有効になってはいけない: \(continueButton)")
//        }
//
//        XCTContext.runActivity(named: "NumberOfRunsが入力されている場合") { _ in
//            mock.isEnabledContinueButton = true
//            vc.numberOfRunsTextField.text = param
//            vc.numberOfRunsTextField.sendActions(for: .editingDidEndOnExit)
//            XCTAssertTrue(continueButton.isEnabled, "ボタンが無効になってはいけない: \(continueButton)")
//        }
//    }
//
//    func test_tapContinueButton() {
//        vc.continueButton.sendActions(for: .touchUpInside)
//        XCTAssertEqual(mock.tapContinueButtonCallCount, 1, "Presenterのメソッドが呼ばれない")
//    }
}
