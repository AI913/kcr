import XCTest

class JobFlowTabPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "jobdetail_flowtab_view"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    required init(application: XCUIApplication) {
        app = application
    }
}
// MARK: - Assertion
extension JobFlowTabPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
