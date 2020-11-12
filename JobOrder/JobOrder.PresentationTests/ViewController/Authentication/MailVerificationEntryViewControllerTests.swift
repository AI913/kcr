//
//  MailVerificationEntryViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/07/30.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class MailVerificationEntryViewControllerTests: XCTestCase {

    private let mock = MailVerificationEntryPresenterProtocolMock()
    private let vc = StoryboardScene.PasswordAuthentication.mailVerificationEntry.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.identifierTextField, "identifierTextFieldがOutletに接続されていない")
        XCTAssertNotNil(vc.sendMailButton, "sendMailButtonがOutletに接続されていない")
    }

    func test_actions() throws {
        let sendMailButton = try XCTUnwrap(vc.sendMailButton, "Unwrap失敗")
        let identifierTextField = try XCTUnwrap(vc.identifierTextField, "Unwrap失敗")
        XCTAssertNoThrow(sendMailButton.sendActions(for: .touchUpInside), "タップで例外発生: \(sendMailButton)")
        XCTAssertNoThrow(identifierTextField.sendActions(for: .editingChanged), "文字入力で例外発生: \(identifierTextField)")
        XCTAssertNoThrow(identifierTextField.sendActions(for: .editingDidEndOnExit), "文字入力完了で例外発生: \(identifierTextField)")
    }

    func test_sendMailButtonEnabled() throws {
        let sendMailButton = try XCTUnwrap(vc.sendMailButton, "Unwrap失敗")

        XCTContext.runActivity(named: "未設定の場合") { _ in
            mock.isEnabledSendButton = false
            XCTAssertFalse(sendMailButton.isEnabled, "ボタンが有効になってはいけない: \(sendMailButton)")
        }

        XCTContext.runActivity(named: "Identifierを入力") { _ in
            mock.isEnabledSendButton = true
            vc.identifierTextField.text = "test"
            vc.identifierTextField.sendActions(for: .editingChanged)
            XCTAssertTrue(sendMailButton.isEnabled, "ボタンが無効になってはいけない: \(sendMailButton)")

            vc.changedProcessing(true)
            XCTAssertFalse(sendMailButton.isEnabled, "ボタンが有効になってはいけない: \(sendMailButton)")

            vc.changedProcessing(false)
            XCTAssertTrue(sendMailButton.isEnabled, "ボタンが無効になってはいけない: \(sendMailButton)")
        }
    }

    func test_processing() throws {
        let identifierTextField = try XCTUnwrap(vc.identifierTextField, "Unwrap失敗")

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertTrue(identifierTextField.isEnabled, "テキストフィールドが無効になってはいけない: \(identifierTextField)")
        }

        XCTContext.runActivity(named: "処理中の場合") { _ in
            vc.changedProcessing(true)
            XCTAssertFalse(identifierTextField.isEnabled, "テキストフィールドが有効になってはいけない: \(identifierTextField)")
        }

        XCTContext.runActivity(named: "処理中でない場合") { _ in
            vc.changedProcessing(false)
            XCTAssertTrue(identifierTextField.isEnabled, "テキストフィールドが無効になってはいけない: \(identifierTextField)")
        }
    }

    func test_showAlert() {
        vc.showErrorAlert(NSError(domain: "Error", code: -1, userInfo: nil))
        XCTAssertTrue(vc.presentedViewController is UIAlertController, "アラートが表示されない")
    }
}
