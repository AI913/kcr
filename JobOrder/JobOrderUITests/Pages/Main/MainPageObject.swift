//
//  MainPageObject.swift
//  JobOrderUITests
//
//  Created by Yu Suzuki on 2020/06/08.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest

class MainPageObject: PageObject {

    private enum IDs {
        static let rootElement: String = "main_view"

        static let NaviBarButton: String = "settings_button"

        static let TabRobotButton: String = "robot_tabbutton"
        static let TabJobButton: String = "job_tabbutton"
        static let TabDashboardButton: String = "dashboard_tabbutton"
        static let AddJobButton: String = "addjob_button"
    }

    let app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    required init(application: XCUIApplication) {
        self.app = application
    }

    var tabRobotButton: XCUIElement { return app.tabBars.buttons[IDs.TabRobotButton] }
    var tabJobButton: XCUIElement { return app.tabBars.buttons[IDs.TabJobButton] }
    var tabDashboardButton: XCUIElement { return app.tabBars.buttons[IDs.TabDashboardButton] }
    var addButton: XCUIElement { return app.navigationBars.buttons[IDs.AddJobButton] }

    private var settingsButton: XCUIElement {
        return app.navigationBars.buttons[IDs.NaviBarButton]
    }

    var isExists: Bool {
        return tabbarButton(atIndex: 0) != nil
    }

    func tapTabRobotButton() -> RobotListPageObject {
        tabRobotButton.tap()
        return RobotListPageObject(application: app)
    }

    func tapTabJobButton() -> JobListPageObject {
        tabJobButton.tap()
        return JobListPageObject(application: app)
    }

    func tapTabDashboardButton() -> DashboardPageObject {
        tabDashboardButton.tap()
        return DashboardPageObject(application: app)
    }

    func tapSettingButton() -> SettingsPageObject {
        settingsButton.tap()
        return SettingsPageObject(application: app)
    }

    func tapAddJobButton() -> JobInfoEntryPageObject {
        addButton.tap()
        return JobInfoEntryPageObject(application: app)
    }

    private func tabbarButton(atIndex index: Int) -> XCUIElement? {
        return app.tabBars.element(boundBy: index)
    }
}

// MARK: - Assertion
extension MainPageObject {
    var existsPage: Bool {
        return view.exists
    }
}

// MARK: - Waitable
extension MainPageObject {
    func waitForExistence(timeout: TimeInterval = 3) -> Bool {
        return isExists
    }
}
