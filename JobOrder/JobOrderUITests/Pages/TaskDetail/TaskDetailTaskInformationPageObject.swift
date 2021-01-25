import XCTest

class TaskDetailTaskInformationPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "taskdetail_view"
        static let cancelbutton: String = "cancel_button"
        static let cancelTaskButton: String = "cancel_task_button"
        static let showDetailButton: String = "show_detail_button"
        static let backButton: String = "Back"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }
    var cancelButton: XCUIElement { return app.navigationBars.buttons[IDs.cancelbutton] }
    var cancelTaskButton: XCUIElement { return app.buttons[IDs.cancelTaskButton] }
    var showDetailButton: XCUIElement { return app.buttons[IDs.showDetailButton] }
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
    func tapCancelTaskButton() -> RobotWorkTabPageObject {
        cancelTaskButton.tap()
        return RobotWorkTabPageObject(application: app) // 未使用
    }
    func tapShowDetailButton() -> TaskDetailExecutionLogPageObject {
        showDetailButton.tap()
        return TaskDetailExecutionLogPageObject(application: app)
    }
}
// MARK: - Assertion
extension TaskDetailTaskInformationPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
