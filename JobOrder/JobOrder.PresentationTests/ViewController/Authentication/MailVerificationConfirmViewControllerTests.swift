//
//  MailVerificationConfirmViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/07/30.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class MailVerificationConfirmViewControllerTests: XCTestCase {

    private let mock = MailVerificationConfirmPresenterProtocolMock()
    private let vc = StoryboardScene.Authentication.mailVerificationConfirm.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.confirmationCodeTextField, "confirmationCodeTextFieldがOutletに接続されていない")
        XCTAssertNotNil(vc.passwordTextField, "passwordTextFieldがOutletに接続されていない")
        XCTAssertNotNil(vc.updateButton, "updateButtonがOutletに接続されていない")
        XCTAssertNotNil(vc.resendButton, "resendButtonがOutletに接続されていない")
        XCTAssertNotNil(vc.togglePasswordVisibilityButton, "togglePasswordVisibilityButtonがOutletに接続されていない")
    }

    func test_actions() throws {
        let confirmationCodeTextField = try XCTUnwrap(vc.confirmationCodeTextField, "Unwrap失敗")
        let passwordTextField = try XCTUnwrap(vc.passwordTextField, "Unwrap失敗")
        let updateButton = try XCTUnwrap(vc.updateButton, "Unwrap失敗")
        let resendButton = try XCTUnwrap(vc.resendButton, "Unwrap失敗")
        let togglePasswordVisibilityButton = try XCTUnwrap(vc.togglePasswordVisibilityButton, "Unwrap失敗")
        XCTAssertNoThrow(confirmationCodeTextField.sendActions(for: .editingChanged), "文字入力で例外発生: \(confirmationCodeTextField)")
        XCTAssertNoThrow(confirmationCodeTextField.sendActions(for: .editingDidEndOnExit), "文字入力完了で例外発生: \(confirmationCodeTextField)")
        XCTAssertNoThrow(passwordTextField.sendActions(for: .editingChanged), "文字入力で例外発生: \(passwordTextField)")
        XCTAssertNoThrow(passwordTextField.sendActions(for: .editingDidEndOnExit), "文字入力完了で例外発生: \(passwordTextField)")
        XCTAssertNoThrow(updateButton.sendActions(for: .touchUpInside), "タップで例外発生: \(updateButton)")
        XCTAssertNoThrow(resendButton.sendActions(for: .touchUpInside), "タップで例外発生: \(resendButton)")
        XCTAssertNoThrow(togglePasswordVisibilityButton.sendActions(for: .touchUpInside), "タップで例外発生: \(togglePasswordVisibilityButton)")
    }

    func test_passwordVisible() throws {
        let passwordTextField = try XCTUnwrap(vc.passwordTextField, "Unwrap失敗")

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertTrue(passwordTextField.isSecureTextEntry, "パスワード文字列がセキュアでなくてはいけない: \(passwordTextField)")
        }

        XCTContext.runActivity(named: "PasswordVisibilityボタンをトグルした場合") { _ in
            vc.togglePasswordVisibilityButton.sendActions(for: .touchUpInside)
            XCTAssertFalse(passwordTextField.isSecureTextEntry, "パスワード文字列がセキュアであってはいけない: \(passwordTextField)")

            vc.togglePasswordVisibilityButton.sendActions(for: .touchUpInside)
            XCTAssertTrue(passwordTextField.isSecureTextEntry, "パスワード文字列がセキュアでなくてはいけない: \(passwordTextField)")
        }
    }

    func test_inject() {
        let param = "test"
        vc.inject(viewData: AuthenticationViewData(identifier: param))
        XCTAssertEqual(vc.viewData.identifier, param, "正常に値が設定されていない")
    }

    func test_updateButtonEnabled() throws {
        let updateButton = try XCTUnwrap(vc.updateButton, "Unwrap失敗")
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            mock.isEnabledUpdateButton = false
            vc.confirmationCodeTextField.text = param
            XCTAssertFalse(updateButton.isEnabled, "ボタンが有効になってはいけない: \(updateButton)")
        }

        XCTContext.runActivity(named: "Identifierのみ入力されている場合") { _ in
            mock.isEnabledUpdateButton = false
            vc.confirmationCodeTextField.text = param
            vc.confirmationCodeTextField.sendActions(for: .editingChanged)
            vc.passwordTextField.text = nil
            vc.passwordTextField.sendActions(for: .editingChanged)
            XCTAssertFalse(updateButton.isEnabled, "ボタンが有効になってはいけない: \(updateButton)")
        }

        XCTContext.runActivity(named: "Passwordのみ入力されている場合") { _ in
            mock.isEnabledUpdateButton = false
            vc.confirmationCodeTextField.text = nil
            vc.confirmationCodeTextField.sendActions(for: .editingChanged)
            vc.passwordTextField.text = param
            vc.passwordTextField.sendActions(for: .editingChanged)
            XCTAssertFalse(updateButton.isEnabled, "ボタンが有効になってはいけない: \(updateButton)")
        }

        XCTContext.runActivity(named: "IdentifierとPasswordを入力") { _ in
            mock.isEnabledUpdateButton = true
            vc.confirmationCodeTextField.text = param
            vc.confirmationCodeTextField.sendActions(for: .editingChanged)
            vc.passwordTextField.text = param
            vc.passwordTextField.sendActions(for: .editingChanged)
            XCTAssertTrue(updateButton.isEnabled, "ボタンが無効になってはいけない: \(updateButton)")

            vc.changedProcessing(true)
            XCTAssertFalse(updateButton.isEnabled, "ボタンが有効になってはいけない: \(updateButton)")

            vc.changedProcessing(false)
            XCTAssertTrue(updateButton.isEnabled, "ボタンが無効になってはいけない: \(updateButton)")
        }
    }

    func test_processing() throws {
        let confirmationCodeTextField = try XCTUnwrap(vc.confirmationCodeTextField, "Unwrap失敗")
        let passwordTextField = try XCTUnwrap(vc.passwordTextField, "Unwrap失敗")
        let resendButton = try XCTUnwrap(vc.resendButton, "Unwrap失敗")
        let togglePasswordVisibilityButton = try XCTUnwrap(vc.togglePasswordVisibilityButton, "Unwrap失敗")

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertTrue(confirmationCodeTextField.isEnabled, "ボタンが無効になってはいけない: \(confirmationCodeTextField)")
            XCTAssertTrue(passwordTextField.isEnabled, "テキストフィールドが無効になってはいけない: \(passwordTextField)")
            XCTAssertTrue(resendButton.isEnabled, "ボタンが無効になってはいけない: \(resendButton)")
            XCTAssertTrue(togglePasswordVisibilityButton.isEnabled, "ボタンが無効になってはいけない: \(togglePasswordVisibilityButton)")
        }

        XCTContext.runActivity(named: "処理中の場合") { _ in
            vc.changedProcessing(true)
            XCTAssertFalse(confirmationCodeTextField.isEnabled, "ボタンが有効になってはいけない: \(confirmationCodeTextField)")
            XCTAssertFalse(passwordTextField.isEnabled, "テキストフィールドが有効になってはいけない: \(passwordTextField)")
            XCTAssertFalse(resendButton.isEnabled, "ボタンが有効になってはいけない: \(resendButton)")
            XCTAssertFalse(togglePasswordVisibilityButton.isEnabled, "ボタンが有効になってはいけない: \(togglePasswordVisibilityButton)")
        }

        XCTContext.runActivity(named: "処理中でない場合") { _ in
            vc.changedProcessing(false)
            XCTAssertTrue(confirmationCodeTextField.isEnabled, "ボタンが無効になってはいけない: \(confirmationCodeTextField)")
            XCTAssertTrue(passwordTextField.isEnabled, "テキストフィールドが無効になってはいけない: \(passwordTextField)")
            XCTAssertTrue(resendButton.isEnabled, "ボタンが無効になってはいけない: \(resendButton)")
            XCTAssertTrue(togglePasswordVisibilityButton.isEnabled, "ボタンが無効になってはいけない: \(togglePasswordVisibilityButton)")
        }
    }

    func test_showAlert() {
        let param = "test"
        vc.showAlert(param)
        XCTAssertTrue(vc.presentedViewController is UIAlertController, "アラートが表示されない")
    }

    func test_showErrorAlert() {
        vc.showErrorAlert(NSError(domain: "Error", code: -1, userInfo: nil))
        XCTAssertTrue(vc.presentedViewController is UIAlertController, "アラートが表示されない")
    }
}
