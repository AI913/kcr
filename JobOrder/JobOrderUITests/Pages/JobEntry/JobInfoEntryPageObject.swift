import XCTest

class JobInfoEntryPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "jobentry_view"
        static let cancelbutton: String = "cancel_button"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }
    var CancelButton: XCUIElement {
        return app.navigationBars.buttons[IDs.cancelbutton]
    }

    required init(application: XCUIApplication) {
        app = application
    }

    func tapCancelButton() -> RobotWorkTabPageObject {
        CancelButton.tap()
        return RobotWorkTabPageObject(application: app)
    }
}
// MARK: - Assertion
extension JobInfoEntryPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
