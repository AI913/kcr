//
//  ActionEntryActionLibrarySelectionPageObject.swift
//  JobOrderUITests
//
//  Created by 相田剛志 on 2021/01/06.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest

class WorkObjectLibrarySelectionPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "workobject_library_selection_view"
        static let nextbutton: String = "next_button"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }
    var nextButton: XCUIElement {
        return app.buttons[IDs.nextbutton]
    }

    required init(application: XCUIApplication) {
        app = application
    }

    func tapCancelButton() -> WorkBenchEntryPageObject {
        app.navigationBars.buttons.element(boundBy: 0).tap()
        return WorkBenchEntryPageObject(application: app)
    }

    func tapNextButton() -> WorkObjectSelectionPageObject {
        nextButton.tap()
        return WorkObjectSelectionPageObject(application: app)
    }

    func tapCell( index: Int ) {
        app.collectionViews.cells.element(boundBy: 0).tap()
    }

    func tapCellStart( index: Int ) -> WorkPieceRecognitionResultPageObject {
        app.collectionViews.cells.element(boundBy: 0).buttons.element(boundBy: 0).tap()
        return WorkPieceRecognitionResultPageObject(application: app)
    }
}
// MARK: - Assertion
extension WorkObjectLibrarySelectionPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
