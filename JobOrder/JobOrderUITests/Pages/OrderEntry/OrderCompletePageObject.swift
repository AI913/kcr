//
//  OrderCompletePageObject.swift
//  JobOrderUITests
//
//  Created by 藤井一暢 on 2020/10/23.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//
import XCTest

class OrderCompletePageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "ordercomplete_view"
        static let closeButton: String = "close_button"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    required init(application: XCUIApplication) {
        app = application
    }

    private var closeButton: XCUIElement { return view.buttons[IDs.closeButton] }

    func tapCloseButtonToRobotDetail() -> RobotDetailPageObject {
        closeButton.tap()
        return RobotDetailPageObject(application: app)
    }

    func tapCloseButtonToJobDetail() -> JobDetailPageObject {
        closeButton.tap()
        return JobDetailPageObject(application: app)
    }
}
// MARK: - Assertion
extension OrderCompletePageObject {
    var existsPage: Bool {
        return view.exists
    }
}
