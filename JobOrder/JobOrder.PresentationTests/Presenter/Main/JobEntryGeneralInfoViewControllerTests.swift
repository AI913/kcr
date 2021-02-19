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

    func test_actions() throws {
        let jobNameTextField = try XCTUnwrap(vc.jobNameTextField, "Unwrap失敗")
        let cancelBarButtonItem = try XCTUnwrap(vc.cancelBarButtonItem, "Unwrap失敗")
        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")
        XCTAssertNoThrow(jobNameTextField.sendActions(for: .editingChanged), "文字入力で例外発生: \(jobNameTextField)")
        XCTAssertNoThrow(cancelBarButtonItem.target?.perform(cancelBarButtonItem.action, with: nil), "タップで例外発生: \(cancelBarButtonItem)")
        XCTAssertNoThrow(continueButton.sendActions(for: .touchUpInside), "タップで例外発生: \(continueButton)")
    }

    func test_viewWillAppear() throws {
        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")

        XCTContext.runActivity(named: "Trueの場合") { _ in
            mock.isEnabledContinueButton = true
            vc.viewWillAppear(true)
            XCTAssertTrue(continueButton.isEnabled, "ボタンが無効になってはいけない: \(continueButton)")
        }

        XCTContext.runActivity(named: "Falseの場合") { _ in
            mock.isEnabledContinueButton = false
            vc.viewWillAppear(true)
            XCTAssertFalse(continueButton.isEnabled, "ボタンが有効になってはいけない: \(continueButton)")
        }

    }

    func test_tapContinueButton() {
        vc.continueButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(mock.tapContinueButtonCallCount, 1, "Presenterのメソッドが呼ばれない")
    }

    func test_numberOfItemsInSection() {
        mock.numberOfItemsInSection = 1
        let num = vc.robotCollection.dataSource?.collectionView(vc.robotCollection, numberOfItemsInSection: 0)
        XCTAssertEqual(num, 1, "正常に値が設定されていない")
    }

    func test_didSelectItemWithContinueButtonEnable() throws {
        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")
        mock.isEnabledContinueButton = true
        vc.robotCollection.delegate?.collectionView?(vc.robotCollection, didSelectItemAt: IndexPath())
        XCTAssertEqual(mock.selectItemCallCount, 1, "Presenterのメソッドが呼ばれない")
        XCTAssertTrue(continueButton.isEnabled, "ボタンが無効になってはいけない: \(continueButton)")
    }

    func test_didSelectItemWithContinueButtonDisable() throws {
        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")
        mock.isEnabledContinueButton = false
        vc.robotCollection.delegate?.collectionView?(vc.robotCollection, didSelectItemAt: IndexPath())
        XCTAssertEqual(mock.selectItemCallCount, 1, "Presenterのメソッドが呼ばれない")
        XCTAssertFalse(continueButton.isEnabled, "ボタンが有効になってはいけない: \(continueButton)")
    }
}
