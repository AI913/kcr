//
//  ActionEntryActionLibrarySelectionPageObject.swift
//  JobOrderUITests
//
//  Created by 相田剛志 on 2021/01/06.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest

class WorkObjectSelectionPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "workobject_selection_view"
        static let donebutton: String = "done_button"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }
    var doneButton: XCUIElement {
        return app.buttons[IDs.donebutton]
    }

    required init(application: XCUIApplication) {
        app = application
    }

    func tapCancelButton() -> WorkObjectLibrarySelectionPageObject {
        app.navigationBars.buttons.element(boundBy: 0).tap()
        return WorkObjectLibrarySelectionPageObject(application: app)
    }

    func tapDoneButton() -> JobInfoEntryConfirmPageObject {
        doneButton.tap()
        return JobInfoEntryConfirmPageObject(application: app)
    }

    func tapCell( index: Int ) -> WorkBenchSelectionPageObject {
        app.tables.cells.element(boundBy: index).tap()
        return WorkBenchSelectionPageObject(application: app)
    }
}
// MARK: - Assertion
extension WorkObjectSelectionPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
