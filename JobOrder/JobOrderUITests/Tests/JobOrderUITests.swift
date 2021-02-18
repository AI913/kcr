//
//  JobOrderUITests.swift
//  JobOrderUITests
//
//  Created by Kento Tatsumi on 2020/03/03.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest

class JobOrderUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    override func tearDownWithError() throws {}
}

// MARK: - Startup
extension JobOrderUITests {

    func setSpace() -> MainPageObject {
        let app = XCUIApplication()
        let name = "dev1"
        let page = StartupPageObject(application: app)

        sleep(UInt32(3))
        guard page.existsPage else {
            return MainPageObject(application: app)
        }

        return page
            .enterSpace(name)
            .tapNextButton()
            .waitExists(MainPageObject.self)
    }
}

// MARK: - Authentication
extension JobOrderUITests {

    func signIn() -> MainPageObject {
        let app = XCUIApplication()
        let identifier = "joa_test"
        let password = "Kyocera1!"

        _ = setSpace()
        return PasswordAuthenticationPageObject(application: app)
            .enterIdentifier(identifier)
            .enterPassword(password)
            .tapSignInButton()
            .waitExists(MainPageObject.self)
    }

    func signInError() -> PasswordAuthenticationPageObject {
        let app = XCUIApplication()
        let identifier = "joa_test"
        let password = "Kyocera1"

        _ = setSpace()
        _ = PasswordAuthenticationPageObject(application: app)
            .enterIdentifier(identifier)
            .enterPassword(password)
            .tapSignInButton()
        return PasswordAuthenticationPageObject(application: app)
    }
}
