import XCTest

class AboutPageObject: PageObject {

    private enum IDs {
        static let rootElement: String = "about_view"
        static let aboutButton: String = "about_button"
    }

    let app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    required init(application: XCUIApplication) {
        self.app = application
    }
    var BackButton: XCUIElement {
        return app.navigationBars.buttons.element(boundBy: 0)
    }
    func tapBackButton() -> SettingsPageObject {
        BackButton.tap()
        return SettingsPageObject(application: app)
    }
}

// MARK: - Assertion
extension AboutPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
