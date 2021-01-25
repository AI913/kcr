import XCTest

class TaskDetailExecutionLogPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "taskdetail_view"
        static let cancelbutton: String = "cancel_button"
        static let backButton: String = "Back"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }
    var cancelButton: XCUIElement { return app.navigationBars.buttons[IDs.cancelbutton] }
    var backButton: XCUIElement { return app.navigationBars.buttons[IDs.backButton] }

    required init(application: XCUIApplication) {
        app = application
    }

    func tapCancelButton() -> RobotWorkTabPageObject {
        cancelButton.tap()
        return RobotWorkTabPageObject(application: app)
    }
    func tapBackButton( from: PageObject ) -> PageObject {
        backButton.forceTapElement()
        return from
    }
}
// MARK: - Assertion
extension TaskDetailExecutionLogPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
