//
//  PasswordAuthenticationViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/07/30.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class PasswordAuthenticationViewControllerTests: XCTestCase {

    private let mock = PasswordAuthenticationPresenterProtocolMock()
    private let vc = StoryboardScene.PasswordAuthentication.passwordAuthentication.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.identifierTextField, "identifierTextFieldがOutletに接続されていない")
        XCTAssertNotNil(vc.passwordTextField, "passwordTextFieldがOutletに接続されていない")
        XCTAssertNotNil(vc.connectionSettingsButton, "connectionSettingsButtonがOutletに接続されていない")
        XCTAssertNotNil(vc.biometricsAuthenticationButton, "biometricsAuthenticationButtonがOutletに接続されていない")
        XCTAssertNotNil(vc.biometricsAuthenticationLabel, "biometricsAuthenticationLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.passwordResetButton, "passwordResetButtonがOutletに接続されていない")
        XCTAssertNotNil(vc.signInButton, "signInButtonがOutletに接続されていない")
        XCTAssertNotNil(vc.togglePasswordVisibilityButton, "togglePasswordVisibilityButtonがOutletに接続されていない")
    }

    func test_actions() throws {
        let identifierTextField = try XCTUnwrap(vc.identifierTextField, "Unwrap失敗")
        let passwordTextField = try XCTUnwrap(vc.passwordTextField, "Unwrap失敗")
        let connectionSettingsButton = try XCTUnwrap(vc.connectionSettingsButton, "Unwrap失敗")
        let biometricsAuthenticationButton = try XCTUnwrap(vc.biometricsAuthenticationButton, "Unwrap失敗")
        let passwordResetButton = try XCTUnwrap(vc.passwordResetButton, "Unwrap失敗")
        let signInButton = try XCTUnwrap(vc.signInButton, "Unwrap失敗")
        let togglePasswordVisibilityButton = try XCTUnwrap(vc.togglePasswordVisibilityButton, "Unwrap失敗")
        XCTAssertNoThrow(identifierTextField.sendActions(for: .editingChanged), "文字入力で例外発生: \(identifierTextField)")
        XCTAssertNoThrow(identifierTextField.sendActions(for: .editingDidEndOnExit), "文字入力完了で例外発生: \(identifierTextField)")
        XCTAssertNoThrow(passwordTextField.sendActions(for: .editingChanged), "文字入力で例外発生: \(passwordTextField)")
        XCTAssertNoThrow(passwordTextField.sendActions(for: .editingDidEndOnExit), "文字入力完了で例外発生: \(passwordTextField)")
        XCTAssertNoThrow(connectionSettingsButton.sendActions(for: .touchUpInside), "タップで例外発生: \(connectionSettingsButton)")
        XCTAssertNoThrow(biometricsAuthenticationButton.sendActions(for: .touchUpInside), "タップで例外発生: \(biometricsAuthenticationButton)")
        XCTAssertNoThrow(passwordResetButton.sendActions(for: .touchUpInside), "タップで例外発生: \(passwordResetButton)")
        XCTAssertNoThrow(signInButton.sendActions(for: .touchUpInside), "タップで例外発生: \(signInButton)")
        XCTAssertNoThrow(togglePasswordVisibilityButton.sendActions(for: .touchUpInside), "タップで例外発生: \(togglePasswordVisibilityButton)")
    }

    func test_viewWillAppear() throws {
        let identifierTextField = try XCTUnwrap(vc.identifierTextField, "Unwrap失敗")
        let param = "test"

        XCTContext.runActivity(named: "RestoreIdentifierの設定がOFFの場合") { _ in
            mock.isRestoredIdentifier = false
            mock.username = param
            vc.viewWillAppear(true)
            XCTAssertEqual(identifierTextField.text, "", "テキストを設定してはいけない: \(identifierTextField)")
        }

        XCTContext.runActivity(named: "RestoreIdentifierの設定がONの場合") { _ in
            mock.isRestoredIdentifier = true
            mock.username = param
            vc.viewWillAppear(true)
            XCTAssertEqual(identifierTextField.text, param, "テキストが設定されていない: \(identifierTextField)")
        }
    }

    func test_viewDidAppear() {
        vc.viewDidAppear(true)
        XCTAssertEqual(mock.viewDidAppearCallCount, 1, "Presenterのメソッドが呼ばれない")
    }

    func test_signInButtonEnabled() throws {
        let signInButton = try XCTUnwrap(vc.signInButton, "Unwrap失敗")
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            mock.isEnabledSignInButton = false
            XCTAssertFalse(signInButton.isEnabled, "ボタンが有効になってはいけない: \(signInButton)")
        }

        XCTContext.runActivity(named: "Identifierのみ入力されている場合") { _ in
            vc.identifierTextField.text = param
            vc.identifierTextField.sendActions(for: .editingChanged)
            vc.passwordTextField.text = nil
            vc.passwordTextField.sendActions(for: .editingChanged)
            XCTAssertFalse(signInButton.isEnabled, "ボタンが有効になってはいけない: \(signInButton)")
        }

        XCTContext.runActivity(named: "Passwordのみ入力されている場合") { _ in
            vc.identifierTextField.text = nil
            vc.identifierTextField.sendActions(for: .editingChanged)
            vc.passwordTextField.text = param
            vc.passwordTextField.sendActions(for: .editingChanged)
            XCTAssertFalse(signInButton.isEnabled, "ボタンが有効になってはいけない: \(signInButton)")
        }

        XCTContext.runActivity(named: "IdentifierとPasswordを入力") { _ in
            mock.isEnabledSignInButton = true
            vc.identifierTextField.text = param
            vc.identifierTextField.sendActions(for: .editingChanged)
            vc.passwordTextField.text = param
            vc.passwordTextField.sendActions(for: .editingChanged)
            XCTAssertTrue(signInButton.isEnabled, "ボタンが無効になってはいけない: \(signInButton)")

            vc.changedProcessing(true)
            XCTAssertFalse(signInButton.isEnabled, "ボタンが有効になってはいけない: \(signInButton)")

            vc.changedProcessing(false)
            XCTAssertTrue(signInButton.isEnabled, "ボタンが無効になってはいけない: \(signInButton)")
        }
    }

    func test_biometricsAuthenticationVisible() throws {
        let biometricsAuthenticationButton = try XCTUnwrap(vc.biometricsAuthenticationButton, "Unwrap失敗")
        let biometricsAuthenticationLabel = try XCTUnwrap(vc.biometricsAuthenticationLabel, "Unwrap失敗")

        XCTContext.runActivity(named: "生体認証OFFの場合") { _ in
            mock.isEnabledBiometricsButton = false
            vc.viewWillAppear(true)
            XCTAssertTrue(biometricsAuthenticationButton.isHidden, "ボタンが表示されてはいけない: \(biometricsAuthenticationButton)")
            XCTAssertTrue(biometricsAuthenticationLabel.isHidden, "ラベルが表示されてはいけない: \(biometricsAuthenticationLabel)")
        }

        XCTContext.runActivity(named: "生体認証ONの場合") { _ in
            mock.isEnabledBiometricsButton = true
            vc.viewWillAppear(true)
            XCTAssertFalse(biometricsAuthenticationButton.isHidden, "ボタンが表示されなくてはいけない: \(biometricsAuthenticationButton)")
            XCTAssertFalse(biometricsAuthenticationLabel.isHidden, "ラベルが表示されなくてはいけない: \(biometricsAuthenticationLabel)")
        }
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

    func test_processing() throws {
        let identifierTextField = try XCTUnwrap(vc.identifierTextField, "Unwrap失敗")
        let passwordTextField = try XCTUnwrap(vc.passwordTextField, "Unwrap失敗")
        let connectionSettingsButton = try XCTUnwrap(vc.connectionSettingsButton, "Unwrap失敗")
        let biometricsAuthenticationButton = try XCTUnwrap(vc.biometricsAuthenticationButton, "Unwrap失敗")
        let passwordResetButton = try XCTUnwrap(vc.passwordResetButton, "Unwrap失敗")
        let togglePasswordVisibilityButton = try XCTUnwrap(vc.togglePasswordVisibilityButton, "Unwrap失敗")
        mock.isEnabledBiometricsButton = true

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertTrue(identifierTextField.isEnabled, "テキストフィールドが無効になってはいけない: \(identifierTextField)")
            XCTAssertTrue(passwordTextField.isEnabled, "テキストフィールドが無効になってはいけない: \(passwordTextField)")
            XCTAssertTrue(connectionSettingsButton.isEnabled, "ボタンが無効になってはいけない: \(connectionSettingsButton)")
            XCTAssertTrue(biometricsAuthenticationButton.isEnabled, "ボタンが無効になってはいけない: \(biometricsAuthenticationButton)")
            XCTAssertTrue(passwordResetButton.isEnabled, "ボタンが無効になってはいけない: \(passwordResetButton)")
            XCTAssertTrue(togglePasswordVisibilityButton.isEnabled, "ボタンが無効になってはいけない: \(togglePasswordVisibilityButton)")
        }

        XCTContext.runActivity(named: "処理中の場合") { _ in
            vc.changedProcessing(true)
            XCTAssertFalse(identifierTextField.isEnabled, "テキストフィールドが有効になってはいけない: \(identifierTextField)")
            XCTAssertFalse(passwordTextField.isEnabled, "テキストフィールドが有効になってはいけない: \(passwordTextField)")
            XCTAssertFalse(connectionSettingsButton.isEnabled, "ボタンが有効になってはいけない: \(connectionSettingsButton)")
            XCTAssertFalse(biometricsAuthenticationButton.isEnabled, "ボタンが有効になってはいけない: \(biometricsAuthenticationButton)")
            XCTAssertFalse(passwordResetButton.isEnabled, "ボタンが有効になってはいけない: \(passwordResetButton)")
            XCTAssertFalse(togglePasswordVisibilityButton.isEnabled, "ボタンが有効になってはいけない: \(togglePasswordVisibilityButton)")
        }

        XCTContext.runActivity(named: "処理中でない場合") { _ in
            vc.changedProcessing(false)
            XCTAssertTrue(identifierTextField.isEnabled, "テキストフィールドが無効になってはいけない: \(identifierTextField)")
            XCTAssertTrue(passwordTextField.isEnabled, "テキストフィールドが無効になってはいけない: \(passwordTextField)")
            XCTAssertTrue(connectionSettingsButton.isEnabled, "ボタンが無効になってはいけない: \(connectionSettingsButton)")
            XCTAssertTrue(biometricsAuthenticationButton.isEnabled, "ボタンが無効になってはいけない: \(biometricsAuthenticationButton)")
            XCTAssertTrue(passwordResetButton.isEnabled, "ボタンが無効になってはいけない: \(passwordResetButton)")
            XCTAssertTrue(togglePasswordVisibilityButton.isEnabled, "ボタンが無効になってはいけない: \(togglePasswordVisibilityButton)")
        }
    }

    func test_showAlert() {
        vc.showErrorAlert(NSError(domain: "Error", code: -1, userInfo: nil))
        XCTAssertTrue(vc.presentedViewController is UIAlertController, "アラートが表示されない")
    }
}
