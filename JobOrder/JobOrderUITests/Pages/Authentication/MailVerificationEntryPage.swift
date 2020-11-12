//
//  MailVerificationEntryPageObject.swift
//  JobOrderUITests
//
//  Created by Yu Suzuki on 2020/06/08.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest

class MailVerificationEntryPageObject: PageObject {
    private enum IDs {
        static let rootElement: String = "mail_verification_entry_view"
    }

    let app: XCUIApplication
    var view: XCUIElement { return app.otherElements[IDs.rootElement] }

    required init(application: XCUIApplication) {
        self.app = application
    }
}

// MARK: - Assertion
extension MailVerificationEntryPageObject {
    var existsPage: Bool {
        return view.exists
    }
}
