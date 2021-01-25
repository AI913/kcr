import XCTest

class JobRemarksTabPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "jobdetail_remarkstab_view"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    required init(application: XCUIApplication) {
        app = application
    }
}
// MARK: - Assertion
extension JobRemarksTabPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
