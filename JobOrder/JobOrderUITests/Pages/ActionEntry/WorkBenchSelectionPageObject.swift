//
//  ActionEntryActionLibrarySelectionPageObject.swift
//  JobOrderUITests
//
//  Created by 相田剛志 on 2021/01/06.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest

class WorkBenchSelectionPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "workbench_selection_view"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    required init(application: XCUIApplication) {
        app = application
    }

    func tapCancelButton() -> WorkObjectSelectionPageObject {
        app.navigationBars.buttons.element(boundBy: 0).tap()
        return WorkObjectSelectionPageObject(application: app)
    }

    func tapCell( index: Int ) -> WorkObjectSelectionPageObject {
        app.tables.cells.element(boundBy: index).tap()
        return WorkObjectSelectionPageObject(application: app)
    }
}
// MARK: - Assertion
extension WorkBenchSelectionPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
