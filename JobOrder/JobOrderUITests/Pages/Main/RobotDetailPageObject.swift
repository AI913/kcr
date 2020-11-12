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
    var BackButton: XCUIElement {
        return app.navigationBars.buttons.element(boundBy: 2)
    }

    var OrderButton: XCUIElement { return view.buttons[IDs.orderbutton] }
    var SystemTab: XCUIElement {
        return app.segmentedControls.buttons.element(boundBy: 1)
    }
    var RemarksTab: XCUIElement {
        return app.segmentedControls.buttons.element(boundBy: 2)
    }

    var WorkTab: XCUIElement {
        return app.segmentedControls.buttons.element(boundBy: 0)
    }

    func tapBackButton() -> RobotListPageObject {
        BackButton.tap()
        return RobotListPageObject(application: app)
    }

    func tapSystemTab() -> RobotSystemTabPageObject {
        print("Robot tab count: -> " + String(app.segmentedControls.buttons.count))
        SystemTab.tap()
        return RobotSystemTabPageObject(application: app)
    }

    func tapRemarksTab() -> RobotRemarksTabPageObject {
        RemarksTab.tap()
        return RobotRemarksTabPageObject(application: app)
    }

    func tapWorkTab() -> RobotWorkTabPageObject {
        WorkTab.tap()
        return RobotWorkTabPageObject(application: app)
    }

    func tapOrderButton() -> JobSelectionPageObject {
        OrderButton.tap()
        return JobSelectionPageObject(application: app)
    }
}
// MARK: - Assertion
extension RobotDetailPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
