//
//  AuthenticationUITests.swift
//  JobOrderUITests
//
//  Created by Yu Suzuki on 2020/06/05.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest

class AuthenticationUITests: JobOrderUITests {

    func testSignIn() throws {

        XCTContext.runActivity(named: "サインインする") { _ in
            XCTContext.runActivity(named: "サインイン失敗した時はアラートを表示する") { _ in
                let page = signInError()
                XCTAssert(page.invalidAlert.waitForExistence(timeout: 3), "Alertを表示できなかった")
            }
            XCTContext.runActivity(named: "サインイン成功した時はMain画面へ遷移する") { _ in
                let page = signIn()
                XCTAssertTrue(page.isExists, "画面遷移できなかった")
            }
        }
    }

    func testForgotYourPassword() throws {
        let app = XCUIApplication()
        _ = setSpace()

        XCTContext.runActivity(named: "パスワードを再設定する") { _ in
            let page = PasswordAuthenticationPageObject(application: app)
                .tapForgotYourPasswordButton()
                .waitExists(MailVerificationEntryPageObject.self)
            XCTAssertTrue(page.existsPage, "画面遷移できなかった")
        }
    }

    func testToSettings() throws {
        let app = XCUIApplication()
        _ = setSpace()

        XCTContext.runActivity(named: "設定画面へ遷移する") { _ in
            let page = PasswordAuthenticationPageObject(application: app).tapSettings().waitExists(ConnectionSettingsPageObject.self)
            XCTAssertTrue(page.existsPage, "画面遷移できなかった")
        }
        XCTContext.runActivity(named: "戻る") { _ in
            let page = ConnectionSettingsPageObject(application: app).tapBackButton().waitExists(PasswordAuthenticationPageObject.self)
            XCTAssertTrue(page.existsPage, "画面遷移できなかった")
        }
    }

    func testResetAlert() throws {
        let app = XCUIApplication()
        _ = setSpace()

        XCTContext.runActivity(named: "設定画面へ遷移する") { _ in
            let page = PasswordAuthenticationPageObject(application: app).tapSettings().waitExists(ConnectionSettingsPageObject.self)
            XCTAssertTrue(page.existsPage, "画面遷移できなかった")
        }
        XCTContext.runActivity(named: "リセットボタン押下でアラート表示") { _ in
            let page = ConnectionSettingsPageObject(application: app).tapResetButton()
            XCTAssertTrue(page.alert.waitForExistence(timeout: 3), "Alertを表示できなかった")
        }
        XCTContext.runActivity(named: "アラートのキャンセルボタン押下") { _ in
            let page = ConnectionSettingsPageObject(application: app).tapAlertCancelButton().waitExists(ConnectionSettingsPageObject.self)
            XCTAssertTrue(page.existsPage, "画面遷移できなかった")
        }
        XCTContext.runActivity(named: "リセットボタン押下でアラート表示") { _ in
            let page = ConnectionSettingsPageObject(application: app).tapResetButton()
            XCTAssertTrue(page.waitForExistence(timeout: 3), "Alertを表示できなかった")
        }
        XCTContext.runActivity(named: "アラートのOKボタン押下で戻る") { _ in
            let page = ConnectionSettingsPageObject(application: app).tapAlertOkButton().waitExists(PasswordAuthenticationPageObject.self)
            XCTAssertTrue(page.existsPage, "画面遷移できなかった")
        }
    }
}
