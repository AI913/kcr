//
//  AuthenticationUITests.swift
//  JobOrderUITests
//
//  Created by Yu Suzuki on 2020/06/05.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest

class AuthenticationUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    override func tearDownWithError() throws {}

    func testSetSpace() throws {
        let app = XCUIApplication()

        AuthenticationUITests.waitConnectionSettingsPage()
        XCTContext.runActivity(named: "Space名を設定する") { _ in
            let name = "test"
            let authPage = PasswordAuthenticationPageObject(application: app)
            let page = (authPage.existsPage ? authPage.tapSettings() : ConnectionSettingsPageObject(application: app))
                .enterSpace(name)
                .tapSaveButton()
                .waitExists(PasswordAuthenticationPageObject.self)
            XCTAssertTrue(page.existsPage)
        }
    }

    func testSignIn() throws {
        let app = XCUIApplication()
        checkSpaceName()

        XCTContext.runActivity(named: "サインインする") { _ in
            let identifier = "200300137"
            XCTContext.runActivity(named: "サインイン失敗した時はアラートを表示する") { _ in
                let password = "Kyocera7!"
                let page = PasswordAuthenticationPageObject(application: app)
                _ = page
                    .enterIdentifier(identifier)
                    .enterPassword(password)
                    .tapSignInButton()

                XCTAssert(page.invalidAlert.waitForExistence(timeout: 3))
            }
            XCTContext.runActivity(named: "サインイン成功した時はMain画面へ遷移する") { _ in
                let password = "Kyocera8!"
                let page = PasswordAuthenticationPageObject(application: app)
                    .enterIdentifier(identifier)
                    .enterPassword(password)
                    .tapSignInButton()
                    .waitExists(MainPageObject.self, timeout: 10)

                XCTAssertTrue(page.isExists)
            }
        }
    }

    func testForgotYourPassword() throws {
        let app = XCUIApplication()
        checkSpaceName()

        XCTContext.runActivity(named: "パスワードを再設定する") { _ in
            let page = PasswordAuthenticationPageObject(application: app)
                .tapForgotYourPasswordButton()
                .waitExists(MailVerificationEntryPageObject.self)

            XCTAssertTrue(page.existsPage)
        }
    }

    private func checkSpaceName() {
        let app = XCUIApplication()

        AuthenticationUITests.waitConnectionSettingsPage()
        XCTContext.runActivity(named: "Space名が未設定の場合は設定する") { _ in
            let name = "test"
            let page = ConnectionSettingsPageObject(application: app)
            if page.existsPage {
                XCTAssertTrue(
                    page.enterSpace(name)
                        .tapSaveButton()
                        .waitForExistence())
            }
        }
    }

    private static func waitConnectionSettingsPage(timeout: TimeInterval = 1) {
        sleep(UInt32(timeout))
    }

    public static func Login() {
        let app = XCUIApplication()
        waitConnectionSettingsPage()
        XCTContext.runActivity(named: "Space名が未設定の場合は設定する") { _ in
            let name = "test"
            let page = ConnectionSettingsPageObject(application: app)
            if page.existsPage {
                XCTAssertTrue(
                    page.enterSpace(name)
                        .tapSaveButton()
                        .waitForExistence())
            }
        }
        XCTContext.runActivity(named: "サインインする") { _ in
            let identifier = "kenichi.aoki"
            XCTContext.runActivity(named: "サインイン成功した時はMain画面へ遷移する") { _ in
                let password = "Fa06215309!"
                _ = PasswordAuthenticationPageObject(application: app)
                    .enterIdentifier(identifier)
                    .enterPassword(password)
                    .tapSignInButton()
                    .waitExists(MainPageObject.self)
            }
        }
    }
}
