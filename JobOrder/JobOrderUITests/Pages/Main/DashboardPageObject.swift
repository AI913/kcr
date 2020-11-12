import XCTest

class DashboardPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "dashboard_view"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    required init(application: XCUIApplication) {
        app = application
    }
}
// MARK: - Assertion
extension DashboardPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
