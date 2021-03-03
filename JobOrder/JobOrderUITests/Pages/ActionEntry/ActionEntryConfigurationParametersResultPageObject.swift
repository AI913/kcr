////
////  ActionEntryConfigurationParametersResultPageObject.swift
////  JobOrderUITests
////
////  Created by frontarc on 2021/03/02.
////  Copyright © 2021 Kento Tatsumi. All rights reserved.
////
//
// import XCTest
//
// class ActionEntryConfigurationParametersResultPageObject: PageObject {
//    private enum IDs {
//        static let rootElement: String = "actionpara_view"
//        static let closeButton: String = "close_button"
//        static let nextbutton: String = "next_button"
//    }
//    var app: XCUIApplication
//    var view: XCUIElement { return app.otherElements[IDs.rootElement] }
//    var cancelButton: XCUIElement {
//        return app.navigationBars.buttons[IDs.closeButton]
//    }
//    var nextButton: XCUIElement {
//        return app.buttons[IDs.nextbutton]
//    }
//
//    required init(application: XCUIApplication) {
//        app = application
//    }
//
//    func tapCancelButton() -> JobListPageObject {   // TODO:
//        cancelButton.tap()
//        return PageObject(application: app)
//    }
//
//    func tapNextButton() -> WorkBenchEntryPageObject {
//        nextButton.tap()
//        return WorkBenchEntryPageObject(application: app)
//    }
// }
// MARK: - Assertion
// extension ActionEntryConfigurationParametersResultPageObject {
//    var existsPage: Bool {
//        return view.exists
//    }
// }
