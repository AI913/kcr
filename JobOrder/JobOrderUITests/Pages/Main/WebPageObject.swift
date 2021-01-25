import XCTest

class WebPageObject: PageObject {

    private enum IDs {
        static let rootElement: String = "web_view"
    }

    let app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    required init(application: XCUIApplication) {
        self.app = application
    }
    var backButton: XCUIElement {
        return app.navigationBars.buttons.element(boundBy: 0)
    }
    func tapBackButton() -> SettingsPageObject {
        backButton.tap()
        return SettingsPageObject(application: app)
    }
}

// MARK: - Assertion
extension WebPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
