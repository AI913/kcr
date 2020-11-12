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

        sleep(1)
        XCTContext.runActivity(named: "Space名を設定する") { _ in
            let name = "test"
            let authPage = PasswordAuthenticationPageObject(application: app)
            let page = (authPage.existsPage ? authPage.tapSettings() : ConnectionSettingsPageObject(application: app))
                .enterSpace(name)
                .tapSaveButton()
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
                _ = PasswordAuthenticationPageObject(application: app)
                    .enterIdentifier(identifier)
                    .enterPassword(password)
                    .tapSignInButton()

                sleep(3)
                XCTAssertTrue(PasswordAuthenticationPageObject(application: app).existsPage)
            }
            XCTContext.runActivity(named: "サインイン成功した時はMain画面へ遷移する") { _ in
                let password = "Kyocera8!"
                let page = PasswordAuthenticationPageObject(application: app)
                    .enterIdentifier(identifier)
                    .enterPassword(password)
                    .tapSignInButton()

                sleep(3)
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

            sleep(1)
            XCTAssertTrue(page.existsPage)
        }
    }

    private func checkSpaceName() {
        let app = XCUIApplication()

        sleep(1)
        XCTContext.runActivity(named: "Space名が未設定の場合は設定する") { _ in
            let name = "test"
            let page = ConnectionSettingsPageObject(application: app)
            if page.existsPage {
                XCTAssertTrue(
                    page.enterSpace(name)
                        .tapSaveButton()
                        .existsPage)
            }
        }
    }

    public static func Login() {
        let app = XCUIApplication()
        sleep(1)
        XCTContext.runActivity(named: "Space名が未設定の場合は設定する") { _ in
            let name = "test"
            let page = ConnectionSettingsPageObject(application: app)
            if page.existsPage {
                XCTAssertTrue(
                    page.enterSpace(name)
                        .tapSaveButton()
                        .existsPage)
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
                sleep(3)
            }
        }
    }
}
