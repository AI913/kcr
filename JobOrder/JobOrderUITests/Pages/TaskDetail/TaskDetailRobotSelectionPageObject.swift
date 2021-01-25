import XCTest

class TaskDetailRobotSelectionPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "taskdetail_view"
        static let cancelbutton: String = "cancel_button"
        static let cancelTasksButton: String = "cancel_tasks_button"
        static let robotViewLabel: String = "Robot View"
        static let robotCollectionLabel: String = "Robot Selection Collection View Cell"
        static let backButton: String = "Back"
        static let runHistoryButton: String = "Run history"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }
    var cancelButton: XCUIElement { return app.navigationBars.buttons[IDs.cancelbutton] }
    var cancelTasksButton: XCUIElement { return app.buttons[IDs.cancelTasksButton] }
    var backButton: XCUIElement { return app.navigationBars.buttons[IDs.backButton] }
    var runHistoryButton: XCUIElement { return app.navigationBars.buttons[IDs.runHistoryButton] }

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
    func tapRunHistoryButton() -> TaskDetailRunHistoryPageObject {
        runHistoryButton.forceTapElement()
        return TaskDetailRunHistoryPageObject( application: app )
    }
    func tapCancelTasksButton() -> TaskDetailRobotSelectionPageObject {
        cancelTasksButton.tap()
        return self
    }
    func tapRobot( index: Int ) -> TaskDetailTaskInformationPageObject {
        app.collectionViews.cells.element(boundBy: index).tap()
        return TaskDetailTaskInformationPageObject(application: app)
    }

}
// MARK: - Assertion
extension TaskDetailRobotSelectionPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
