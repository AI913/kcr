import XCTest
import Foundation

class JobWorkTabPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "jobdetail_worktab_view"
        static let taskTable: String = "jobdetail_work_assignedtask_table"
        static let historyTable: String = "jobdetail_work_historytask_table"
        static let seeAllButton: String = "See All"
    }
    private enum Patterns {
        static let assign: String = "アサイン"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }
    var seeAllButton: XCUIElement { return view.buttons[IDs.seeAllButton] }
    var taskTable: XCUIElement { return view.tables[IDs.taskTable] }
    var taskCells: XCUIElementQuery { return taskTable.cells }
    var historyTable: XCUIElement { return view.tables[IDs.historyTable] }
    var historyCells: XCUIElementQuery { return historyTable.cells }

    required init(application: XCUIApplication) {
        app = application
    }
    func tapSeeAllButton() -> TaskDetailRunHistoryPageObject {
        seeAllButton.tap()
        return TaskDetailRunHistoryPageObject( application: app )
    }
    func tapTaskCells(index: Int) -> PageObject {
        return tapcell(e: taskCells.element(boundBy: index))
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
extension JobWorkTabPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
