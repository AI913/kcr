import XCTest

class JobListPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "joblist_view"
        static let cells: String = "joblist_cell"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.tables[IDs.rootElement] }

    required init(application: XCUIApplication) {
        app = application
    }

    var cells: XCUIElementQuery { return view.cells.matching(identifier: IDs.cells) }

    func tapCell(index: Int) -> JobDetailPageObject {
        //assert(cells.count > 0, "識別子「joblist_cell」を持つTableCellが格納されていない")
        //assert(index < cells.count, "識別子「joblist_cell」を持つセルの数が指定されたインデックス(" + String(index) + ")より少ない")
        cells.element(boundBy: index).tap()

        return JobDetailPageObject(application: app)
    }
}
// MARK: - Assertion
extension JobListPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
