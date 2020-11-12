import XCTest

class RobotSystemTabPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "systemtab_view"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    required init(application: XCUIApplication) {
        app = application
    }
}
// MARK: - Assertion
extension RobotSystemTabPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
