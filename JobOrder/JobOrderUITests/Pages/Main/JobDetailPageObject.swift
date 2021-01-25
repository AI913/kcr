import XCTest

class JobDetailPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "jobdetail_view"
        static let cells: String = "jobdetail_cell"
        static let orderbutton: String = "order_button"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    required init(application: XCUIApplication) {
        app = application
    }
    var orderButton: XCUIElement { return view.buttons[IDs.orderbutton] }
    var backButton: XCUIElement { return app.navigationBars.buttons.element(boundBy: 2) }
    var flowTab: XCUIElement {
        return app.segmentedControls.buttons.element(boundBy: 1)
    }
    var remarksTab: XCUIElement {
        return app.segmentedControls.buttons.element(boundBy: 2)
    }
    var workTab: XCUIElement {
        return app.segmentedControls.buttons.element(boundBy: 0)
    }

    func tapOrderButton() -> RobotSelectionPageObject {
        orderButton.tap()
        return RobotSelectionPageObject(application: app)
    }

    func tapBackButton() -> JobListPageObject {
        backButton.tap()
        return JobListPageObject(application: app)
    }

    func tapFlowTab() -> JobFlowTabPageObject {
        flowTab.tap()
        return JobFlowTabPageObject(application: app)
    }

    func tapRemarksTab() -> JobRemarksTabPageObject {
        remarksTab.tap()
        return JobRemarksTabPageObject(application: app)
    }

    func tapWorkTab() -> JobWorkTabPageObject {
        workTab.tap()
        return JobWorkTabPageObject(application: app)
    }
}
// MARK: - Assertion
extension JobDetailPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
