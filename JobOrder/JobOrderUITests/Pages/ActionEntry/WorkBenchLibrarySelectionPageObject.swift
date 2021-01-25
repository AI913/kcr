//
//  ActionEntryActionLibrarySelectionPageObject.swift
//  JobOrderUITests
//
//  Created by 相田剛志 on 2021/01/06.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest

class WorkBenchLibrarySelectionPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "workbench_library_selection_view"
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

    func tapCancelButton() -> WorkBenchEntryPageObject {
        app.navigationBars.buttons.element(boundBy: 0).tap()
        return WorkBenchEntryPageObject(application: app)
    }

    func tapDoneButton() -> WorkBenchEntryPageObject {
        doneButton.tap()
        return WorkBenchEntryPageObject(application: app)
    }

    func tapTableCell(index: Int) {
        app.collectionViews.cells.element(boundBy: index).tap()
    }
}
// MARK: - Assertion
extension WorkBenchLibrarySelectionPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
