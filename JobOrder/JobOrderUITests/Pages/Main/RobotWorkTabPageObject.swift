import XCTest

class RobotWorkTabPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "worktab_view"
        static let rootTable: String = "robotwork_table"
    }

    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }
    var RootTable: XCUIElement { return view.tables[IDs.rootTable] }
    var Cells: XCUIElementQuery { return RootTable.cells }

    required init(application: XCUIApplication) {
        app = application
    }
    func tapCells(index: Int) -> TaskDetailTaskInformationPageObject {
        //assert(Cells.count > 0, "識別子「robotwork_table」を持つテーブルにセルが格納されていない")
        //assert(index < Cells.count, "識別子「setting_table」を持つテーブルのセル数が指定されたインデックス(" + String(index) + ")より少ない")

        Cells.element(boundBy: index).tap()
        return TaskDetailTaskInformationPageObject(application: app)
    }
}
// MARK: - Assertion
extension RobotWorkTabPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
