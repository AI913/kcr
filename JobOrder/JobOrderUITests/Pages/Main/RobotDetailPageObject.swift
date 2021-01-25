//
//  RobotListPageObject.swift
//  JobOrderUITests
//
//  Created by admin on 2020/10/01.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest

class RobotDetailPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "robot_detail_view"
        static let orderbutton: String = "order_button"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    required init(application: XCUIApplication) {
        app = application
    }
    var backButton: XCUIElement {
        return app.navigationBars.buttons.element(boundBy: 2)
    }

    var orderButton: XCUIElement { return view.buttons[IDs.orderbutton] }
    var systemTab: XCUIElement {
        return app.segmentedControls.buttons.element(boundBy: 1)
    }
    var remarksTab: XCUIElement {
        return app.segmentedControls.buttons.element(boundBy: 2)
    }

    var workTab: XCUIElement {
        return app.segmentedControls.buttons.element(boundBy: 0)
    }

    func tapBackButton() -> RobotListPageObject {
        backButton.tap()
        return RobotListPageObject(application: app)
    }

    func tapSystemTab() -> RobotSystemTabPageObject {
        print("Robot tab count: -> " + String(app.segmentedControls.buttons.count))
        systemTab.tap()
        return RobotSystemTabPageObject(application: app)
    }

    func tapRemarksTab() -> RobotRemarksTabPageObject {
        remarksTab.tap()
        return RobotRemarksTabPageObject(application: app)
    }

    func tapWorkTab() -> RobotWorkTabPageObject {
        workTab.tap()
        return RobotWorkTabPageObject(application: app)
    }

    func tapOrderButton() -> JobSelectionPageObject {
        orderButton.tap()
        return JobSelectionPageObject(application: app)
    }
}
// MARK: - Assertion
extension RobotDetailPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
