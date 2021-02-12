//
//  RobotSelectionPageObject.swift
//  JobOrderUITests
//
//  Created by frontarc on 2020/10/06.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//
import XCTest

class RobotSelectionPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "robotselection_view"
        static let selectrobotbutton: String = "selectrobot_button"
        static let continueButton: String = "continue_button"
        static let selectjobButton: String = "Select a job"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    private func robotCell(at index: Int) -> XCUIElement { view.collectionViews.cells.element(boundBy: index) }

    required init(application: XCUIApplication) {
        app = application
    }

    var continueButton: XCUIElement { return app.buttons[IDs.continueButton] }

    var selectJobButton: XCUIElement {
        return app.navigationBars.buttons[IDs.selectjobButton]
    }

    func tapSelectJobButton() -> JobSelectionPageObject {
        // print("NavigationBarButtonCount -> " + String(app.navigationBars.buttons.count))
        selectJobButton.tap()
        return JobSelectionPageObject(application: app)
    }

    func tapContinueButton() -> OrderConfigurationPageObject {
        continueButton.tap()
        return OrderConfigurationPageObject(application: app)
    }

    func tapRobotCell(at index: Int) -> Self {
        robotCell(at: index).tap()
        return self
    }
}
// MARK: - Assertion
extension RobotSelectionPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
