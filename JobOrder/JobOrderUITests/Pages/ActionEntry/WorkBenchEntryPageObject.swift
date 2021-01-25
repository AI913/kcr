//
//  ActionEntryActionLibrarySelectionPageObject.swift
//  JobOrderUITests
//
//  Created by 相田剛志 on 2021/01/06.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest

class WorkBenchEntryPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "workbench_entry_view"
        static let librarybutton: String = "library_button"
        static let nextbutton: String = "next_button"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }
    var libraryButton: XCUIElement {
        return app.buttons[IDs.librarybutton]
    }
    var nextButton: XCUIElement {
        return app.buttons[IDs.nextbutton]
    }

    required init(application: XCUIApplication) {
        app = application
    }

    func tapCancelButton() -> ActionEntryActionLibrarySelectionPageObject {
        app.navigationBars.buttons.element(boundBy: 0).tap()
        return ActionEntryActionLibrarySelectionPageObject(application: app)
    }

    func tapLibraryButton() -> WorkBenchLibrarySelectionPageObject {
        libraryButton.tap()
        return WorkBenchLibrarySelectionPageObject(application: app)
    }

    func tapNextButton() -> WorkObjectLibrarySelectionPageObject {
        nextButton.tap()
        return WorkObjectLibrarySelectionPageObject(application: app)
    }

    func tapTableCell(index: Int) -> WorkObjectLibrarySelectionPageObject {
        app.tables.cells.element(boundBy: index).tap()
        return WorkObjectLibrarySelectionPageObject(application: app)
    }
}
// MARK: - Assertion
extension WorkBenchEntryPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
