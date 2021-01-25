import XCTest

class TaskDetailPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "taskdetail_view"
        static let cancelbutton: String = "cancel_button"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }
    var cancelButton: XCUIElement {
        return app.navigationBars.buttons[IDs.cancelbutton]
    }

    required init(application: XCUIApplication) {
        app = application
    }

    func tapCancelButton() -> RobotWorkTabPageObject {
        cancelButton.tap()
        return RobotWorkTabPageObject(application: app)
    }
}
// MARK: - Assertion
extension TaskDetailPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
