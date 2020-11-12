import XCTest

class RobotRemarksTabPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "remarkstab_view"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    required init(application: XCUIApplication) {
        app = application
    }

}
// MARK: - Assertion
extension RobotRemarksTabPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
