//
//  PasswordAuthenticationPage.swift
//  JobOrderUITests
//
//  Created by Yu Suzuki on 2020/06/08.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest

class PasswordAuthenticationPageObject: PageObject {

    private enum IDs {
        static let rootElement: String = "password_authentication_view"
        static let connectionSettingsButton: String = "connection_settings_button"
        static let identifierTextField: String = "identifier_textfield"
        static let passwordTextField: String = "password_textfield"
        static let biometricsButton: String = "biometrics_button"
        static let signInButton: String = "sign_in_button"
        static let forgotYourPasswordButton: String = "forgot_your_password_button"
    }

    let app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    required init(application: XCUIApplication) {
        self.app = application
    }

    private var settingsButton: XCUIElement { return view.buttons[IDs.connectionSettingsButton] }
    private var identifierTextField: XCUIElement { return view.textFields[IDs.identifierTextField] }
    private var passwordTextField: XCUIElement { return view.secureTextFields[IDs.passwordTextField] }
    private var biometricsButton: XCUIElement { return view.buttons[IDs.biometricsButton] }
    //    private var biometricsLabel: XCUIElement { return view.labels["biometrics_label"] }
    private var signInButton: XCUIElement { return view.buttons[IDs.signInButton] }
    private var forgotYourPasswordButton: XCUIElement { return view.buttons[IDs.forgotYourPasswordButton] }

    var invalidAlert: XCUIElement { return app.alerts.element.staticTexts["Error:認証エラー"] }

    func tapSettings() -> ConnectionSettingsPageObject {
        settingsButton.tap()
        return ConnectionSettingsPageObject(application: app)
    }

    func enterIdentifier(_ email: String) -> PasswordAuthenticationPageObject {
        identifierTextField.doubleTap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: 1)
        identifierTextField.typeText(deleteString)
        identifierTextField.typeText(email)
        return self
    }

    func enterPassword(_ password: String) -> PasswordAuthenticationPageObject {
        passwordTextField.tap()
        passwordTextField.typeText(password)
        return self
    }

    func tapSignInButton() -> MainPageObject {
        signInButton.tap()
        return MainPageObject(application: app)
    }

    func tapForgotYourPasswordButton() -> MailVerificationEntryPageObject {
        forgotYourPasswordButton.tap()
        return MailVerificationEntryPageObject(application: app)
    }
}

// MARK: - Assertion
extension PasswordAuthenticationPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
