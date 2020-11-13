//
//  MainUITests.swift
//  JobOrderUITests
//
//  Created by admin on 2020/09/29.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest

class MainUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    override func tearDownWithError() throws {
    }

    func testMainToSetting() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "設定画面へ遷移する") { _ in
            let page = MainPageObject(application: app).tapSettingButton().waitExists(SettingsPageObject.self)
            XCTAssertTrue(page.existsPage, "設定画面への遷移に失敗した")
        }
    }

    func testSettingsBackToMain() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "設定画面へ遷移する") { _ in
            _ = MainPageObject(application: app).tapSettingButton().waitExists(SettingsPageObject.self)
        }
        XCTContext.runActivity(named: "設定から戻る") { _ in
            let page = SettingsPageObject(application: app).tapBackButton().waitExists(MainPageObject.self)
            XCTAssertTrue(page.isExists, "設定画面からメイン画面へ戻れなかった")
        }
    }

    func testSettingPageToAboutPage() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "設定画面へ遷移する") { _ in
            _ = MainPageObject(application: app).tapSettingButton().waitExists(SettingsPageObject.self)
        }
        XCTContext.runActivity(named: "設定画面からAboutThisApp画面に遷移する") { _ in
            let page = SettingsPageObject(application: app).tapAboutButton().waitExists(AboutPageObject.self)
            XCTAssertTrue(page.existsPage, "設定画面からAboutThisApp画面への遷移に失敗した")
        }
    }

    func testAboutBackToSettings() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "設定画面へ遷移する") { _ in
            _ = MainPageObject(application: app).tapSettingButton().waitExists(SettingsPageObject.self)
        }
        XCTContext.runActivity(named: "設定ページからAboutThisApp画面に遷移する") { _ in
            _ = SettingsPageObject(application: app).tapAboutButton().waitExists(AboutPageObject.self)
        }
        XCTContext.runActivity(named: "AboutThisApp画面から設定画面に戻る") { _ in
            let page = AboutPageObject(application: app).tapBackButton().waitExists(SettingsPageObject.self)
            XCTAssertTrue(page.existsPage, "AboutThisApp画面から設定画面に戻れなかった")
        }
    }

    func testSettingPageToWebRTC() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "設定画面へ遷移する") { _ in
            _ = MainPageObject(application: app).tapSettingButton().waitExists(SettingsPageObject.self)
        }
        XCTContext.runActivity(named: "設定画面からWebRTC画面に遷移する") { _ in
            let page = SettingsPageObject(application: app).tapWebButton().waitExists(WebPageObject.self)
            XCTAssertTrue(page.existsPage, "設定画面からWebRTC画面への遷移に失敗した")
        }
    }

    func testWebRTCBackToSettings() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "設定画面へ遷移する") { _ in
            _ = MainPageObject(application: app).tapSettingButton().waitExists(SettingsPageObject.self)
        }
        XCTContext.runActivity(named: "設定画面からWebRTC画面に遷移する") { _ in
            _ = SettingsPageObject(application: app).tapWebButton().waitExists(WebPageObject.self)
        }
        XCTContext.runActivity(named: "WebRTC画面から設定画面に戻る") { _ in
            let page = WebPageObject(application: app).tapBackButton().waitExists(SettingsPageObject.self)
            XCTAssertTrue(page.existsPage, "WebRTC画面から設定画面に戻れなかった")
        }
    }

    func testSignOut() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "設定画面へ遷移する") { _ in
            _ = MainPageObject(application: app).tapSettingButton().waitExists(SettingsPageObject.self)
        }
        XCTContext.runActivity(named: "ログアウトする") { _ in
            let page = SettingsPageObject(application: app).tapSignoutButton().waitExists(PasswordAuthenticationPageObject.self)
            XCTAssertTrue(page.existsPage, "ログアウトに失敗した")
        }
    }

    func testChangeTabRobot() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "タブ切り替え（Robot）") { _ in
            let page = MainPageObject(application: app).tapTabRobotButton().waitExists(RobotListPageObject.self)
            XCTAssertTrue(page.existsPage, "Robotタブに切り替えられなかった")
        }
    }

    func testChangeTabJob() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            let page = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
            XCTAssertTrue(page.existsPage, "Jobタブに切り替えられなかった")
        }
    }

    func testChangeTabDashboard() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え（Dashboard）") { _ in
            let page = MainPageObject(application: app).tapTabDashboardButton().waitExists(DashboardPageObject.self)
            XCTAssertTrue(page.existsPage, "Dashboardタブに切り替えられなかった")
        }
    }

    func testShowRobotDetail() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "タブ切り替え（Robot）") { _ in
            _ = MainPageObject(application: app).tapTabRobotButton().waitExists(RobotListPageObject.self)
        }
        XCTContext.runActivity(named: "Robot詳細表示") { _ in
            let page = RobotListPageObject(application: app).tapCell(index: 0).waitExists(RobotDetailPageObject.self)
            XCTAssertTrue(page.existsPage, "Robot詳細が表示できなかった")
        }
    }

    func testRobotDetailBackToRobot() throws {
        if UIDevice.current.userInterfaceIdiom == .pad {
            throw XCTSkip("iPadは一覧と詳細の画面が連結している為、試験不要")
        }

        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Robot）") { _ in
            _ = MainPageObject(application: app).tapTabRobotButton().waitExists(RobotListPageObject.self)
        }
        XCTContext.runActivity(named: "Robot詳細表示") { _ in
            _ = RobotListPageObject(application: app).tapCell(index: 0).waitExists(RobotDetailPageObject.self)
        }
        XCTContext.runActivity(named: "Robot詳細から一覧へ戻る") { _ in
            let page = RobotDetailPageObject(application: app).tapBackButton().waitExists(RobotListPageObject.self)
            XCTAssertTrue(page.existsPage, "Robot詳細から一覧へ戻れなかった")
        }
    }

    func testRobotDetailTabSystem() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Robot）") { _ in
            _ = MainPageObject(application: app).tapTabRobotButton().waitExists(RobotListPageObject.self)
        }
        XCTContext.runActivity(named: "Robot詳細表示") { _ in
            _ = RobotListPageObject(application: app).tapCell(index: 0).waitExists(RobotDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え（System）") { _ in
            let page = RobotDetailPageObject(application: app).tapSystemTab().waitExists(RobotSystemTabPageObject.self)
            XCTAssertTrue(page.existsPage, "Systemタブに切り替えられなかった")
        }
    }

    func testRobotDetailTabRemarks() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Robot）") { _ in
            _ = MainPageObject(application: app).tapTabRobotButton().waitExists(RobotListPageObject.self)
        }
        XCTContext.runActivity(named: "Robot詳細表示") { _ in
            _ = RobotListPageObject(application: app).tapCell(index: 0).waitExists(RobotDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Remarks)") { _ in
            let page = RobotDetailPageObject(application: app).tapRemarksTab().waitExists(RobotRemarksTabPageObject.self)
            XCTAssertTrue(page.existsPage, "Remarksタブに切り替えられなかった")
        }
    }

    func testRobotDetailTabWork() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Robot）") { _ in
            _ = MainPageObject(application: app).tapTabRobotButton().waitExists(RobotListPageObject.self)
        }
        XCTContext.runActivity(named: "Robot詳細表示") { _ in
            _ = RobotListPageObject(application: app).tapCell(index: 0).waitExists(RobotDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Remarks)") { _ in
            _ = RobotDetailPageObject(application: app).tapRemarksTab().waitExists(RobotRemarksTabPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            let page = RobotDetailPageObject(application: app).tapWorkTab().waitExists(RobotWorkTabPageObject.self)
            XCTAssertTrue(page.existsPage, "Workタブに切り替えられなかった")
        }
    }

    func testWorkTabJobInfo() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Robot）") { _ in
            _ = MainPageObject(application: app).tapTabRobotButton().waitExists(RobotListPageObject.self)
        }
        XCTContext.runActivity(named: "Robot詳細表示") { _ in
            _ = RobotListPageObject(application: app).tapCell(index: 2).waitExists(RobotDetailPageObject.self)
        }
        XCTContext.runActivity(named: "Taskを開く") { _ in
            let page = RobotWorkTabPageObject(application: app).tapCells(index: 0).waitExists(TaskDetailPageObject.self)
            XCTAssertTrue(page.existsPage, "Taskが開けなかった")
        }
    }

    func testWorkTabJobInfoBack() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Robot）") { _ in
            _ = MainPageObject(application: app).tapTabRobotButton().waitExists(RobotListPageObject.self)
        }
        XCTContext.runActivity(named: "Robot詳細表示") { _ in
            _ = RobotListPageObject(application: app).tapCell(index: 2).waitExists(RobotDetailPageObject.self)
        }
        XCTContext.runActivity(named: "Taskを開く") { _ in
            _ = RobotWorkTabPageObject(application: app).tapCells(index: 0).waitExists(TaskDetailPageObject.self)
        }
        XCTContext.runActivity(named: "Taskを閉じる") { _ in
            let page = TaskDetailPageObject(application: app).tapCancelButton().waitExists(RobotWorkTabPageObject.self)
            XCTAssertTrue(page.existsPage, "Taskが閉じれなかった")
        }
    }

    func testAddJob() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "新しいジョブを作成する") { _ in
            let page = JobListPageObject(application: app).tapAddJobButton().waitExists(JobInfoEntryPageObject.self)
            XCTAssertTrue(page.existsPage, "ジョブ作成ダイアログが開けなかった")
        }
    }

    func testJobOrder() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "タブ切り替え（Robot）") { _ in
            _ = MainPageObject(application: app).tapTabRobotButton().waitExists(RobotListPageObject.self)
        }
        XCTContext.runActivity(named: "Robot詳細表示") { _ in
            _ = RobotListPageObject(application: app).tapCell(index: 0).waitExists(RobotDetailPageObject.self)
        }
        XCTContext.runActivity(named: "Orderダイアログを開く") { _ in
            let page = RobotDetailPageObject(application: app).tapOrderButton().waitExists(JobSelectionPageObject.self)
            XCTAssertTrue(page.existsPage, "Orderダイアログが開けなかった")
        }
    }

    func testJobOrderCancelled() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "タブ切り替え（Robot）") { _ in
            _ = MainPageObject(application: app).tapTabRobotButton().waitExists(RobotListPageObject.self)
        }
        XCTContext.runActivity(named: "Robot詳細表示") { _ in
            _ = RobotListPageObject(application: app).tapCell(index: 0).waitExists(RobotDetailPageObject.self)
        }
        XCTContext.runActivity(named: "Orderダイアログを開く") { _ in
            _ = RobotDetailPageObject(application: app).tapOrderButton().waitExists(JobSelectionPageObject.self)
        }
        XCTContext.runActivity(named: "Orderダイアログを閉じる") { _ in
            let page = JobSelectionPageObject(application: app).tapCancelButtonToRobotDetail().waitExists(RobotDetailPageObject.self)
            XCTAssertTrue(page.existsPage, "Orderダイアログが閉じなかった")
        }
    }

    func testJobTabToJobDetail() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            let page = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
            XCTAssertTrue(page.existsPage, "Job詳細が表示できなかった")
        }
    }

    func testJobDetailBackToJobList() throws {
        if UIDevice.current.userInterfaceIdiom == .pad {
            throw XCTSkip("iPadは一覧と詳細の画面が連結している為、試験不要")
        }

        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細から一覧へ戻る") { _ in
            let page = JobDetailPageObject(application: app).tapBackButton().waitExists(JobListPageObject.self)
            XCTAssertTrue(page.existsPage, "Job詳細から一覧へ戻れなかった")
        }
    }

    func testJobDetailToRobotSelection() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "Orderダイアログを開く") { _ in
            let page = JobDetailPageObject(application: app).tapOrderButton().waitExists(RobotSelectionPageObject.self)
            XCTAssertTrue(page.existsPage, "Orderダイアログが開けなかった")
        }
    }

    func testRobotSelectionBackToJobList() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "Orderダイアログを開く") { _ in
            _ = JobDetailPageObject(application: app).tapOrderButton().waitExists(RobotSelectionPageObject.self)
        }
        XCTContext.runActivity(named: "Select A Job(ひとつ前に戻る)") { _ in
            _ = RobotSelectionPageObject(application: app).tapSelectJobButton().waitExists(JobSelectionPageObject.self)
        }
        XCTContext.runActivity(named: "Orderダイアログを閉じる") { _ in
            let page = JobSelectionPageObject(application: app).tapCancelButtonToJobDetail().waitExists(JobDetailPageObject.self)
            XCTAssertTrue(page.existsPage, "Orderダイアログが閉じなかった")
        }
    }
}
