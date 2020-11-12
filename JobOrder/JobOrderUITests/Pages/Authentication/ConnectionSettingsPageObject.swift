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
        static let spaceTextField: String = "space_textfield"
        static let saveButton: String = "save_button"
    }

    let app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }
    private var spaceTextField: XCUIElement { return view.textFields[IDs.spaceTextField] }
    private var saveButton: XCUIElement { return view.buttons[IDs.saveButton] }

    required init(application: XCUIApplication) {
        self.app = application
    }

    func enterSpace(_ name: String) -> ConnectionSettingsPageObject {
        spaceTextField.doubleTap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: 1)
        spaceTextField.typeText(deleteString)
        spaceTextField.typeText(name)
        view.tap()
        return self
    }

    func tapSaveButton() -> PasswordAuthenticationPageObject {
        saveButton.tap()
        return PasswordAuthenticationPageObject(application: app)
    }
}

// MARK: - Assertion
extension ConnectionSettingsPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
