//
//  ConnectionSettingsPageObject.swift
//  JobOrderUITests
//
//  Created by Yu Suzuki on 2020/06/08.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest

class ConnectionSettingsPageObject: PageObject {

    private enum IDs {
        static let rootElement: String = "connection_settings_view"
        static let resetButton: String = "reset_button"
        static let auth_navbar: String = "auth_navbar"
    }

    let app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    required init(application: XCUIApplication) {
        self.app = application
    }

    private var backButton: XCUIElement { return app.navigationBars[IDs.auth_navbar].buttons.element(boundBy: 0) }
    private var resetButton: XCUIElement { return view.buttons[IDs.resetButton] }
    var alert: XCUIElement { return app.alerts.element }

    func tapBackButton() -> PasswordAuthenticationPageObject {
        backButton.tap()
        return PasswordAuthenticationPageObject(application: app)
    }

    func tapResetButton() -> Self {
        resetButton.tap()
        return self
    }

    func tapAlertCancelButton() -> Self {
        alert.buttons.element(boundBy: 0).tap()
        return self
    }

    func tapAlertOkButton() -> PasswordAuthenticationPageObject {
        alert.buttons.element(boundBy: 1).tap()
        return PasswordAuthenticationPageObject(application: app)
    }
}

// MARK: - Assertion
extension ConnectionSettingsPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
