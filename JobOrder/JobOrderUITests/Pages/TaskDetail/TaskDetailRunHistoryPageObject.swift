import XCTest

class TaskDetailRunHistoryPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "run_history_view"
        static let cancelbutton: String = "cancel_button"
        static let historyTable: String = "history_table"
    }
    private enum Patterns {
        static let assign: String = "アサイン"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }
    var cancelButton: XCUIElement {
        return app.navigationBars.buttons[IDs.cancelbutton]
    }
    var historyCells: XCUIElementQuery { return app.tables[IDs.historyTable].cells }

    required init(application: XCUIApplication) {
        app = application
    }

    func tapCancelButton() -> JobWorkTabPageObject {
        cancelButton.tap()
        return JobWorkTabPageObject(application: app)
    }

    func tapHistoryCells(index: Int) -> PageObject {
        return tapcell(e: historyCells.element(boundBy: index))
    }
    private func tapcell( e: XCUIElement ) -> PageObject {
        e.tap()
        let label = e.children(matching: .staticText).element(boundBy: 0).label
        let regex = try! NSRegularExpression(pattern: Patterns.assign)
        return (regex.firstMatch(in: label, range: NSRange(0..<label.count)) != nil) ?
            TaskDetailRobotSelectionPageObject(application: app)
            : TaskDetailTaskInformationPageObject(application: app)
    }
}
// MARK: - Assertion
extension TaskDetailRunHistoryPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
