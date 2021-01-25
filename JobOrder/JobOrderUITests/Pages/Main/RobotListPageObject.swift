//
//  RobotListPageObject.swift
//  JobOrderUITests
//
//  Created by admin on 2020/10/01.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest

class RobotListPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "robot_listview"
        static let cells: String = "robot_listcell"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.tables[IDs.rootElement] }

    required init(application: XCUIApplication) {
        app = application
    }

    var cells: XCUIElementQuery { return view.cells.matching(identifier: IDs.cells) }

    func tapCell(index: Int) -> RobotDetailPageObject {
        //assert(Cells.count > 0, "識別子「robot_listcell」を持つTableCellが格納されていない")
        //assert(index < Cells.count, "識別子「robot_listcell」を持つセルの数が指定されたインデックス(" + String(index) + ")より少ない")
        cells.element(boundBy: index).tap()

        return RobotDetailPageObject(application: app)
    }
}
// MARK: - Assertion
extension RobotListPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
