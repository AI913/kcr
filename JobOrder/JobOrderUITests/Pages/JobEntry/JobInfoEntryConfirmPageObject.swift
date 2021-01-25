import XCTest

class JobInfoEntryConfirmPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "confirm_view"
        static let createbutton: String = "create_button"
    }
    var app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }
    var createButton: XCUIElement {
        return app.buttons[IDs.createbutton]
    }

    required init(application: XCUIApplication) {
        app = application
    }

    func tapCreateButton() -> JobListPageObject {
        createButton.tap()
        return JobListPageObject(application: app)
    }
}
// MARK: - Assertion
extension JobInfoEntryConfirmPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
