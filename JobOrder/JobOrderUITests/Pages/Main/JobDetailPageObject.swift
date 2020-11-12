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
    var OrderButton: XCUIElement { return view.buttons[IDs.orderbutton] }
    var BackButton: XCUIElement { return app.navigationBars.buttons.element(boundBy: 2) }

    func tapOrderButton() -> RobotSelectionPageObject {
        OrderButton.tap()
        return RobotSelectionPageObject(application: app)
    }

    func tapBackButton() -> JobListPageObject {
        BackButton.tap()
        return JobListPageObject(application: app)
    }
}
// MARK: - Assertion
extension JobDetailPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
