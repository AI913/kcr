//
//  JobEntryPageObject.swift
//  JobOrderUITests
//
//  Created by Frontarc on 2021/02/18.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest

class JobOrderEntryPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "jobselection_view"
        static let cancelbutton: String = "cancel_button"
        static let continueButton: String = "continue_button"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    private func jobCell(at index: Int) -> XCUIElement { view.collectionViews.cells.element(boundBy: index) }

    required init(application: XCUIApplication) {
        app = application
    }

    var continueButton: XCUIElement { return view.buttons[IDs.continueButton] }

    var cancelButton: XCUIElement {
        return app.navigationBars.buttons[IDs.cancelbutton]
    }

    func tapCancelButtonToRobotDetail() -> RobotDetailPageObject {
        cancelButton.tap()
        return RobotDetailPageObject(application: app)
    }

    func tapCancelButtonToJobDetail() -> JobDetailPageObject {
        cancelButton.tap()
        return JobDetailPageObject(application: app)
    }

    func tapContinueButton() -> RobotSelectionPageObject {
        continueButton.tap()
        return RobotSelectionPageObject(application: app)
    }

    func tapJobCell(at index: Int) -> Self {
        jobCell(at: index).tap()
        return self
    }
}
// MARK: - Assertion
extension JobOrderEntryPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
