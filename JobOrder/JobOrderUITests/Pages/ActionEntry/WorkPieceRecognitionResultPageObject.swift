//
//  ActionEntryActionLibrarySelectionPageObject.swift
//  JobOrderUITests
//
//  Created by 相田剛志 on 2021/01/06.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest

class WorkPieceRecognitionResultPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "workpiece_recognition_view"
        static let cancelbutton: String = "cancel_button"
        static let recapturebutton: String = "recapture_button"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }
    var recaptureButton: XCUIElement {
        return app.buttons[IDs.recapturebutton]
    }
    var cancelButton: XCUIElement {
        return app.navigationBars.buttons[IDs.cancelbutton]
    }

    required init(application: XCUIApplication) {
        app = application
    }

    func tapCancelButton() -> WorkObjectLibrarySelectionPageObject {
        cancelButton.tap()
        return WorkObjectLibrarySelectionPageObject(application: app)
    }

    func tapRecaptureButton() {
        recaptureButton.tap()
    }
}
// MARK: - Assertion
extension WorkPieceRecognitionResultPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
