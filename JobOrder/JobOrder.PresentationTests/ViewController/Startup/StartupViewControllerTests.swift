//
//  StartupViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/07/30.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class StartupViewControllerTests: XCTestCase {

    private let mock = StartupPresenterProtocolMock()
    private let vc = StoryboardScene.Startup.startup.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.spaceView, "spaceViewがOutletに接続されていない")
        XCTAssertNotNil(vc.spaceTextField, "spaceTextFieldがOutletに接続されていない")
        XCTAssertNotNil(vc.nextButton, "saveButtonがOutletに接続されていない")
    }

    func test_actions() throws {
        let spaceTextField = try XCTUnwrap(vc.spaceTextField, "Unwrap失敗")
        let nextButton = try XCTUnwrap(vc.nextButton, "Unwrap失敗")
        XCTAssertNoThrow(spaceTextField.sendActions(for: .editingChanged), "文字入力で例外発生: \(spaceTextField)")
        XCTAssertNoThrow(spaceTextField.sendActions(for: .editingDidEndOnExit), "文字入力完了で例外発生: \(spaceTextField)")
        XCTAssertNoThrow(nextButton.sendActions(for: .touchUpInside), "タップで例外発生: \(nextButton)")
    }

    func test_viewDidAppear() throws {
        vc.viewDidAppear(true)
        XCTAssertEqual(mock.viewDidAppearCallCount, 1, "Presenterのメソッドが呼ばれない")
    }

    func test_nextButtonEnabled() throws {
        let nextButton = try XCTUnwrap(vc.nextButton, "Unwrap失敗")
        let param = String.arbitrary.generate

        XCTContext.runActivity(named: "未設定の場合") { _ in
            mock.isEnabledNextButton = false
            vc.spaceTextField.text = nil
            vc.spaceTextField.sendActions(for: .editingChanged)
            XCTAssertFalse(nextButton.isEnabled, "ボタンが有効になってはいけない: \(nextButton)")
        }

        XCTContext.runActivity(named: "spaceを入力") { _ in
            mock.isEnabledNextButton = true
            vc.spaceTextField.text = param
            vc.spaceTextField.sendActions(for: .editingChanged)
            XCTAssertTrue(nextButton.isEnabled, "ボタンが無効になってはいけない: \(nextButton)")
        }
    }

    func test_showErrorAlert() {
        vc.showErrorAlert(NSError(domain: "Error", code: -1, userInfo: nil))
        XCTAssertTrue(vc.presentedViewController is UIAlertController, "アラートが表示されない")
    }
}
