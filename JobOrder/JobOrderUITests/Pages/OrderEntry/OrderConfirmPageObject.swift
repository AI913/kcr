//
//  OrderConfirmPageObject.swift
//  JobOrderUITests
//
//  Created by 藤井一暢 on 2020/10/23.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//
import XCTest

class OrderConfirmPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "orderconfirm_view"
        static let numOfRunLabel: String = "numofrun_label"
        static let remarkLabel: String = "remark_label"
        static let sendButton: String = "send_button"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    private var sendButton: XCUIElement { return view.buttons[IDs.sendButton] }
    required init(application: XCUIApplication) {
        app = application
    }

    var numOfRunLabel: XCUIElement { return view.staticTexts[IDs.numOfRunLabel] }
    var remarkLabel: XCUIElement { return view.staticTexts[IDs.remarkLabel] }

    var orderConfigurationButton: XCUIElement {
        return app.navigationBars.buttons.element(boundBy: 2)
    }

    func tapOrderConfigurationButton() -> OrderConfigurationPageObject {
        orderConfigurationButton.tap()
        return OrderConfigurationPageObject(application: app)
    }

    func tapSendButton() -> OrderCompletePageObject {
        sendButton.tap()
        return OrderCompletePageObject(application: app)
    }
}
// MARK: - Assertion
extension OrderConfirmPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
