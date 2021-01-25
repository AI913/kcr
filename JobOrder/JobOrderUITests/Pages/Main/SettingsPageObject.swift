//
//  SettingsPageObject.swift
//  JobOrderUITests
//
//  Created by frontarc on 2020/09/29.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest

class SettingsPageObject: PageObject {

    private enum IDs {
        static let rootElement: String = "settings_view"
        static let rootTable: String = "setting_table"
    }

    private enum Indexs {
        static let SignOut: Int = 2
        static let WebRTC: Int = 4
        static let AboutThisApp: Int = 6
    }

    let app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    required init(application: XCUIApplication) {
        self.app = application
    }

    var backButton: XCUIElement {
        return app.navigationBars.buttons.element(boundBy: 0)
    }

    var rootTable: XCUIElement { return view.tables[IDs.rootTable] }
    var cells: XCUIElementQuery { return rootTable.cells }

    func tapBackButton() -> MainPageObject {
        backButton.tap()
        return MainPageObject(application: app)
    }

    func tapAboutButton() -> AboutPageObject {
        return tapCells(index: Indexs.AboutThisApp) as! AboutPageObject
    }
    func tapWebButton() -> WebPageObject {

        return tapCells(index: Indexs.WebRTC) as! WebPageObject
    }

    func tapSignoutButton() -> PasswordAuthenticationPageObject {
        return tapCells(index: Indexs.SignOut) as! PasswordAuthenticationPageObject
    }

    private func tapCells(index: Int) -> PageObject {
        //assert(Cells.count > 0, "識別子「setting_table」を持つテーブルにセルが格納されていない")
        //assert(index < Cells.count, "識別子「setting_table」を持つテーブルのセル数が指定されたインデックス(" + String(index) + ")より少ない")

        cells.element(boundBy: index).tap()
        var result: PageObject?
        switch index {
        case Indexs.SignOut:
            result = PasswordAuthenticationPageObject(application: app)
        case Indexs.WebRTC:
            result = WebPageObject(application: app)
        case Indexs.AboutThisApp:
            result = AboutPageObject(application: app)
        default:
            assert(false, "テスト対象外のインデックスが指定されている")
        }
        return result!
    }
}

// MARK: - Assertion
extension SettingsPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
