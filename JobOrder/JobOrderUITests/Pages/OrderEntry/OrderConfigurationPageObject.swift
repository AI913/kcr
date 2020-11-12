//
//  OrderConfigurationPageObject.swift
//  JobOrderUITests
//
//  Created by 藤井一暢 on 2020/10/23.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest

class OrderConfigurationPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "orderconfiguration_view"
        static let orderEntryStepView: String = "orderentrystep_view"
        static let numOfRunTextField: String = "numofrun_textfield"
        static let remarkTextField: String = "remark_textfield"
        static let continueButton: String = "continue_button"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    required init(application: XCUIApplication) {
        app = application
    }

    private var orderEntryStepView: XCUIElement { return view.otherElements[IDs.orderEntryStepView] }
    private var numOfRunTextField: XCUIElement { return view.textFields[IDs.numOfRunTextField] }
    private var remarkTextField: XCUIElement { return view.textViews[IDs.remarkTextField] }

    var continueButton: XCUIElement { return view.buttons[IDs.continueButton] }

    var selectRobotButton: XCUIElement {
        return app.navigationBars.buttons.element(boundBy: 2)
    }

    func tapSelectRobotButton() -> RobotSelectionPageObject {
        selectRobotButton.tap()
        return RobotSelectionPageObject(application: app)
    }

    func tapStepView() -> Self {
        orderEntryStepView.tap()
        return self
    }

    func dismissKeyboardIfPresented() -> Self {
        return tapStepView()
    }

    private func enterTextField(field: XCUIElement, text: String) {
        field.tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: 1)
        field.typeText(deleteString)
        field.typeText(text)
    }

    func enterNumOfRun(_ numOfRun: Int) -> Self {
        enterTextField(field: numOfRunTextField, text: String(numOfRun))
        return self
    }

    func enterRemark(_ remark: String) -> Self {
        enterTextField(field: remarkTextField, text: remark)
        return self
    }

    func tapContinueButton() -> OrderConfirmPageObject {
        continueButton.tap()
        return OrderConfirmPageObject(application: app)
    }
}
// MARK: - Assertion
extension OrderConfigurationPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
