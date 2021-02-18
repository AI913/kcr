//
//  StartupPageObject.swift
//  JobOrderUITests
//
//  Created by Yu Suzuki on 2021/02/10.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest

class StartupPageObject: PageObject {

    private enum IDs {
        static let rootElement: String = "startup_view"
        static let nextButton: String = "next_button"
        static let spaceTextField: String = "space_textfield"
    }

    let app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    required init(application: XCUIApplication) {
        self.app = application
    }

    private var nextButton: XCUIElement { return view.buttons[IDs.nextButton] }
    private var spaceTextField: XCUIElement { return view.textFields[IDs.spaceTextField] }

    func tapNextButton() -> MainPageObject {
        nextButton.tap()
        return MainPageObject(application: app)
    }

    func enterSpace(_ name: String) -> Self {
        spaceTextField.doubleTap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: 1)
        spaceTextField.typeText(deleteString)
        spaceTextField.typeText(name)
        view.tap()
        return self
    }
}

// MARK: - Assertion
extension StartupPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
