////
////  JobEntryActionPageObject.swift
////  JobOrderUITests
////
////  Created by frontarc on 2021/03/02.
////  Copyright © 2021 Kento Tatsumi. All rights reserved.
////
//
// import XCTest
//
// class JobEntryActionPageObject: PageObject {
//    private enum IDs {
//        static let rootElement: String = "jobentry_view"
//        static let cancelbutton: String = "cancel_button"
//        static let nextbutton: String = "next_button"
//    }
//    var app: XCUIApplication
//    var view: XCUIElement { return app.otherElements[IDs.rootElement] }
//    var cancelButton: XCUIElement {
//        return app.navigationBars.buttons[IDs.cancelbutton]
//    }
//    var nextButton: XCUIElement {
//        return app.buttons[IDs.nextbutton]
//    }
//
//    required init(application: XCUIApplication) {
//        app = application
//    }
//
//    func tapCancelButton() -> JobListPageObject {
//        cancelButton.tap()
//        return JobListPageObject(application: app)
//    }
//
//    func tapNextButton() -> ActionEntryActionLibrarySelectionPageObject {
//        nextButton.tap()
//        return ActionEntryActionLibrarySelectionPageObject(application: app)
//    }
// }
// MARK: - Assertion
// extension JobInfoEntryPageObject {
//    var existsPage: Bool {
//        return view.exists
//    }
// }
