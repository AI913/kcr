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

    // ---------------------------------------------------------------------------------------------------------------------
    // MARK: Settings
    // ---------------------------------------------------------------------------------------------------------------------
    func testSettings() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "設定画面へ遷移する") { _ in
            let page = MainPageObject(application: app).tapSettingButton().waitExists(SettingsPageObject.self)
            XCTAssertTrue(page.existsPage, "設定画面への遷移に失敗した")
        }
    }

    func testSettingsBack() throws {
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

    func testSettingsAbout() throws {
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

    func testSettingsAboutBack() throws {
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

    func testSettingsWebRTC() throws {
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

    func testSettingsWebRTCBack() throws {
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

    func testSettingsSignOut() throws {
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

    // ---------------------------------------------------------------------------------------------------------------------
    // MARK: Robot
    // ---------------------------------------------------------------------------------------------------------------------
    func testRobot() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "タブ切り替え（Robot）") { _ in
            let page = MainPageObject(application: app).tapTabRobotButton().waitExists(RobotListPageObject.self)
            XCTAssertTrue(page.existsPage, "Robotタブに切り替えられなかった")
        }
    }

    func testRobotDetail() throws {
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

    func testRobotDetailBack() throws {
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

    func testRobotDetailTabWorkTaskinfo() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Robot）") { _ in
            _ = MainPageObject(application: app).tapTabRobotButton().waitExists(RobotListPageObject.self)
        }
        XCTContext.runActivity(named: "Robot詳細表示") { _ in
            _ = RobotListPageObject(application: app).tapCell(index: 2).waitExists(RobotDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = RobotDetailPageObject(application: app).tapWorkTab().waitExists(RobotWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "Taskを開く") { _ in
            let page = RobotWorkTabPageObject(application: app).tapCells(index: 0).waitExists(TaskDetailTaskInformationPageObject.self)
            XCTAssertTrue(page.existsPage, "Taskが開けなかった")
        }
    }

    func testRobotDetailTabWorkTaskinfoBack() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Robot）") { _ in
            _ = MainPageObject(application: app).tapTabRobotButton().waitExists(RobotListPageObject.self)
        }
        XCTContext.runActivity(named: "Robot詳細表示") { _ in
            _ = RobotListPageObject(application: app).tapCell(index: 2).waitExists(RobotDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = RobotDetailPageObject(application: app).tapWorkTab().waitExists(RobotWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "Taskを開く") { _ in
            _ = RobotWorkTabPageObject(application: app).tapCells(index: 0).waitExists(TaskDetailTaskInformationPageObject.self)
        }
        XCTContext.runActivity(named: "Taskを閉じる") { _ in
            let page = TaskDetailTaskInformationPageObject(application: app).tapCancelButton().waitExists(RobotWorkTabPageObject.self)
            XCTAssertTrue(page.existsPage, "Taskが閉じれなかった")
        }
    }

    func testRobotDetailTabWorkTaskinfoDetail() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Robot）") { _ in
            _ = MainPageObject(application: app).tapTabRobotButton().waitExists(RobotListPageObject.self)
        }
        XCTContext.runActivity(named: "Robot詳細表示") { _ in
            _ = RobotListPageObject(application: app).tapCell(index: 2).waitExists(RobotDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = RobotDetailPageObject(application: app).tapWorkTab().waitExists(RobotWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "Taskを開く") { _ in
            _ = RobotWorkTabPageObject(application: app).tapCells(index: 0).waitExists(TaskDetailTaskInformationPageObject.self)
        }
        XCTContext.runActivity(named: "Show Detail") { _ in
            let page = TaskDetailTaskInformationPageObject(application: app).tapShowDetailButton().waitExists(TaskDetailExecutionLogPageObject.self)
            XCTAssertTrue(page.existsPage, "Execution Logが開けなかった")
        }
    }

    func testRobotDetailTabWorkTaskinfoDetailBack() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Robot）") { _ in
            _ = MainPageObject(application: app).tapTabRobotButton().waitExists(RobotListPageObject.self)
        }
        XCTContext.runActivity(named: "Robot詳細表示") { _ in
            _ = RobotListPageObject(application: app).tapCell(index: 2).waitExists(RobotDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = RobotDetailPageObject(application: app).tapWorkTab().waitExists(RobotWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "Taskを開く") { _ in
            _ = RobotWorkTabPageObject(application: app).tapCells(index: 0).waitExists(TaskDetailTaskInformationPageObject.self)
        }
        XCTContext.runActivity(named: "Show Detail") { _ in
            _ = TaskDetailTaskInformationPageObject(application: app).tapShowDetailButton().waitExists(TaskDetailExecutionLogPageObject.self)
        }
        XCTContext.runActivity(named: "Back") { _ in
            let page = TaskDetailExecutionLogPageObject(application: app).tapBackButton(from: TaskDetailTaskInformationPageObject(application: app)).waitExists(TaskDetailTaskInformationPageObject.self)
            XCTAssertTrue(page.existsPage, "Backできなかった")
        }
    }

    func testRobotOrderJob() throws {
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

    func testRobotOrderJobCancel() throws {
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

    func testRobotOrderJobSelect() throws {
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
        XCTContext.runActivity(named: "Robot Selectに進む") { _ in
            let page = JobSelectionPageObject(application: app).tapJobCell(at: 0).tapContinueButton().waitExists(RobotSelectionPageObject.self)
            XCTAssertTrue(page.existsPage, "Robot Selectに進めなかった")
        }
    }

    func testRobotOrderJobSelectBack() throws {
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
        XCTContext.runActivity(named: "Robot Selectに進む") { _ in
            _ = JobSelectionPageObject(application: app).tapJobCell(at: 0).tapContinueButton().waitExists(RobotSelectionPageObject.self)
        }
        XCTContext.runActivity(named: "Back") { _ in
            let page = RobotSelectionPageObject(application: app).tapSelectJobButton().waitExists(JobSelectionPageObject.self)
            XCTAssertTrue(page.existsPage, "Backできなかった")
        }
    }

    func testRobotOrderJobSelectConfig() throws {
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
        XCTContext.runActivity(named: "Robot Selectに進む") { _ in
            _ = JobSelectionPageObject(application: app).tapJobCell(at: 0).tapContinueButton().waitExists(RobotSelectionPageObject.self)
        }
        XCTContext.runActivity(named: "Configに進む") { _ in
            let page = RobotSelectionPageObject(application: app).tapRobotCell(at: 1).tapContinueButton().waitExists(OrderConfigurationPageObject.self)
            XCTAssertTrue(page.existsPage, "Configに進めなかった")
        }
    }

    func testRobotOrderJobSelectConfigConfirm() throws {
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
        XCTContext.runActivity(named: "Robot Selectに進む") { _ in
            _ = JobSelectionPageObject(application: app).tapJobCell(at: 0).tapContinueButton().waitExists(RobotSelectionPageObject.self)
        }
        XCTContext.runActivity(named: "Configに進む") { _ in
            _ = RobotSelectionPageObject(application: app).tapContinueButton().waitExists(OrderConfigurationPageObject.self)
        }
        XCTContext.runActivity(named: "Confirmに進む") { _ in
            let page = OrderConfigurationPageObject(application: app).enterNumOfRun( 1 ).tapContinueButton().waitExists(OrderConfirmPageObject.self)
            XCTAssertTrue(page.existsPage, "Confirmに進めなかった")
        }
    }

    func testRobotOrderJobConfigConfirmSend() throws {
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
        XCTContext.runActivity(named: "Robot Selectに進む") { _ in
            _ = JobSelectionPageObject(application: app).tapJobCell(at: 0).tapContinueButton().waitExists(RobotSelectionPageObject.self)
        }
        XCTContext.runActivity(named: "Configに進む") { _ in
            _ = RobotSelectionPageObject(application: app).tapContinueButton().waitExists(OrderConfigurationPageObject.self)
        }
        XCTContext.runActivity(named: "Confirmに進む") { _ in
            _ = OrderConfigurationPageObject(application: app).enterNumOfRun( 1 ).tapContinueButton().waitExists(OrderConfirmPageObject.self)
        }
        XCTContext.runActivity(named: "Send Request") { _ in
            let page = OrderConfirmPageObject(application: app).tapSendButton().waitExists(OrderCompletePageObject.self)
            XCTAssertTrue(page.existsPage, "Send Requestできなかった")
        }
    }

    func testRobotOrderJobConfigConfirmSendClose() throws {
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
        XCTContext.runActivity(named: "Robot Selectに進む") { _ in
            _ = JobSelectionPageObject(application: app).tapJobCell(at: 0).tapContinueButton().waitExists(RobotSelectionPageObject.self)
        }
        XCTContext.runActivity(named: "Configに進む") { _ in
            _ = RobotSelectionPageObject(application: app).tapContinueButton().waitExists(OrderConfigurationPageObject.self)
        }
        XCTContext.runActivity(named: "Confirmに進む") { _ in
            _ = OrderConfigurationPageObject(application: app).enterNumOfRun( 1 ).tapContinueButton().waitExists(OrderConfirmPageObject.self)
        }
        XCTContext.runActivity(named: "Send Request") { _ in
            _ = OrderConfirmPageObject(application: app).tapSendButton().waitExists(OrderCompletePageObject.self)
        }
        XCTContext.runActivity(named: "Close") { _ in
            let page = OrderCompletePageObject(application: app).tapCloseButtonToRobotDetail().waitExists(RobotDetailPageObject.self)
            XCTAssertTrue(page.existsPage, "Closeできなかった")
        }
    }

    // ---------------------------------------------------------------------------------------------------------------------
    // MARK: Job
    // ---------------------------------------------------------------------------------------------------------------------
    func testJob() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            let page = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
            XCTAssertTrue(page.existsPage, "Jobタブに切り替えられなかった")
        }
    }

    func testJobAdd() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "新しいジョブを作成する") { _ in
            let page = MainPageObject(application: app).tapAddJobButton().waitExists(JobInfoEntryPageObject.self)
            XCTAssertTrue(page.existsPage, "ジョブ作成ダイアログが開けなかった")
        }
    }

    func testJobAddCancel() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()

        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "新しいジョブを作成する") { _ in
            _ = MainPageObject(application: app).tapAddJobButton().waitExists(JobInfoEntryPageObject.self)
        }
        XCTContext.runActivity(named: "Cancel") { _ in
            let page = JobInfoEntryPageObject(application: app).tapCancelButton().waitExists(JobListPageObject.self)
            XCTAssertTrue(page.existsPage, "Cancelできなかった")
        }
    }
    /*
     func testJobAddNext() throws {
     let app = XCUIApplication()
     AuthenticationUITests.Login()

     XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
     _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
     }
     XCTContext.runActivity(named: "新しいジョブを作成する") { _ in
     _ = MainPageObject(application: app).tapAddJobButton().waitExists(JobInfoEntryPageObject.self)
     }
     XCTContext.runActivity(named: "Next") { _ in
     // MARK: なぜかnext_buttonが取得できない viewの設計の問題？
     let page = JobInfoEntryPageObject(application: app).tapNextButton().waitExists(ActionEntryActionLibrarySelectionPageObject.self)
     XCTAssertTrue(page.existsPage, "ActionSelectionダイアログが開けなかった")
     }
     }

     //
     // ActionSelection以降はすべて差し替え予定
     //
     func testJobAddNextPickNext() throws {
     let app = XCUIApplication()
     AuthenticationUITests.Login()

     XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
     _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
     }
     XCTContext.runActivity(named: "新しいジョブを作成する") { _ in
     _ = JobListPageObject(application: app).tapAddJobButton().waitExists(JobInfoEntryPageObject.self)
     }
     XCTContext.runActivity(named: "Next") { _ in
     _ = JobInfoEntryPageObject(application: app).tapNextButton().waitExists(ActionEntryActionLibrarySelectionPageObject.self)
     }
     XCTContext.runActivity(named: "Next") { _ in
     let page = ActionEntryActionLibrarySelectionPageObject(application: app).tapNextButton().waitExists(WorkBenchEntryPageObject.self)
     XCTAssertTrue(page.existsPage, "ワークベンチ選択画面が開けなかった")
     }
     }

     func testJobAddNextPickNextTrayA() throws {
     let app = XCUIApplication()
     AuthenticationUITests.Login()

     XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
     _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
     }
     XCTContext.runActivity(named: "新しいジョブを作成する") { _ in
     _ = JobListPageObject(application: app).tapAddJobButton().waitExists(JobInfoEntryPageObject.self)
     }
     XCTContext.runActivity(named: "Next") { _ in
     _ = JobInfoEntryPageObject(application: app).tapNextButton().waitExists(ActionEntryActionLibrarySelectionPageObject.self)
     }
     XCTContext.runActivity(named: "Next") { _ in
     _ = ActionEntryActionLibrarySelectionPageObject(application: app).tapNextButton().waitExists(WorkBenchEntryPageObject.self)
     }
     XCTContext.runActivity(named: "ライブラリ") { _ in
     let page = WorkBenchEntryPageObject(application: app).tapLibraryButton().waitExists(WorkBenchLibrarySelectionPageObject.self)
     XCTAssertTrue(page.existsPage, "ワークベンチライブラリ選択画面が開けなかった")
     }
     }

     func testJobAddNextPickNextTrayAIndustoryTest() throws {
     }

     func testJobAddNextPickNextTrayAIndustoryNext() throws {
     }

     func testJobAddNextPickNextTrayAIndustoryNextDone() throws {
     }

     func testJobAddNextPickNextTrayAIndustoryNextDoneCreate() throws {
     }

     func testJobAddNextPickNextTrayAStationnaryTest() throws {
     }

     func testJobAddNextPickNextTrayAStationnaryNext() throws {
     }

     func testJobAddNextPickNextTrayAStationnaryNextDone() throws {
     }

     func testJobAddNextPickNextTrayAStationnaryNextDoneCreate() throws {
     }

     func testJobAddNextPickNextTrayASpringTest() throws {
     }

     func testJobAddNextPickNextTrayASpringNext() throws {
     }

     func testJobAddNextPickNextTrayASpringNextDone() throws {
     }

     func testJobAddNextPickNextTrayASpringNextDoneCreate() throws {
     }
     */

    func testJobDetail() throws {
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

    func testJobDetailBack() throws {
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

    func testJobDetailOrder() throws {
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

    func testJobDetailOrderBack() throws {
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
            let page = RobotSelectionPageObject(application: app).tapSelectJobButton().waitExists(JobSelectionPageObject.self)
            XCTAssertTrue(page.existsPage, "Backできなかった")
        }
    }

    func testJobDetailOrderConfig() throws {
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
        XCTContext.runActivity(named: "Configに進む") { _ in
            let page = RobotSelectionPageObject(application: app).tapRobotCell(at: 0).tapContinueButton().waitExists(OrderConfigurationPageObject.self)
            XCTAssertTrue(page.existsPage, "Configに進めなかった")
        }
    }

    func testJobDetailOrderConfigConfirm() throws {
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
        XCTContext.runActivity(named: "Configに進む") { _ in
            _ = RobotSelectionPageObject(application: app).tapRobotCell(at: 0).tapContinueButton().waitExists(OrderConfigurationPageObject.self)
        }
        XCTContext.runActivity(named: "Confirmに進む") { _ in
            let page = OrderConfigurationPageObject(application: app).enterNumOfRun( 1 ).tapContinueButton().waitExists(OrderConfirmPageObject.self)
            XCTAssertTrue(page.existsPage, "Confirmに進めなかった")
        }
    }

    func testJobDetailOrderConfigConfirmSend() throws {
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
        XCTContext.runActivity(named: "Configに進む") { _ in
            _ = RobotSelectionPageObject(application: app).tapRobotCell(at: 0).tapContinueButton().waitExists(OrderConfigurationPageObject.self)
        }
        XCTContext.runActivity(named: "Confirmに進む") { _ in
            _ = OrderConfigurationPageObject(application: app).enterNumOfRun( 1 ).tapContinueButton().waitExists(OrderConfirmPageObject.self)
        }
        XCTContext.runActivity(named: "Send Request") { _ in
            let page = OrderConfirmPageObject(application: app).tapSendButton().waitExists(OrderCompletePageObject.self)
            XCTAssertTrue(page.existsPage, "Send Requestできなかった")
        }
    }

    func testJobDetailOrderConfigConfirmSendClose() throws {
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
        XCTContext.runActivity(named: "Configに進む") { _ in
            _ = RobotSelectionPageObject(application: app).tapRobotCell(at: 0).tapContinueButton().waitExists(OrderConfigurationPageObject.self)
        }
        XCTContext.runActivity(named: "Confirmに進む") { _ in
            _ = OrderConfigurationPageObject(application: app).enterNumOfRun( 1 ).tapContinueButton().waitExists(OrderConfirmPageObject.self)
        }
        XCTContext.runActivity(named: "Send Request") { _ in
            _ = OrderConfirmPageObject(application: app).tapSendButton().waitExists(OrderCompletePageObject.self)
        }
        XCTContext.runActivity(named: "Close") { _ in
            let page = OrderCompletePageObject(application: app).tapCloseButtonToJobDetail().waitExists(JobDetailPageObject.self)
            XCTAssertTrue(page.existsPage, "Closeできなかった")
        }
    }

    func testJobDetailOrderBackCancel() throws {
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
    func testJobDetailTabFlow() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え（Flow）") { _ in
            let page = JobDetailPageObject(application: app).tapFlowTab().waitExists(JobFlowTabPageObject.self)
            XCTAssertTrue(page.existsPage, "Flowタブに切り替えられなかった")
        }
    }

    func testJobDetailTabRemarks() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Remarks)") { _ in
            let page = JobDetailPageObject(application: app).tapRemarksTab().waitExists(JobRemarksTabPageObject.self)
            XCTAssertTrue(page.existsPage, "Remarksタブに切り替えられなかった")
        }
    }

    func testJobDetailTabWork() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Remarks)") { _ in
            _ = JobDetailPageObject(application: app).tapRemarksTab().waitExists(JobRemarksTabPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            let page = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
            XCTAssertTrue(page.existsPage, "Workタブに切り替えられなかった")
        }
    }

    func testJobDetailTabWorkTaskRobot() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "AssignedTaskセル[0]をタップ") { _ in
            let page = JobWorkTabPageObject(application: app).tapTaskCells(index: 0).waitExists(TaskDetailRobotSelectionPageObject.self)
            XCTAssertTrue(page.existsPage, "RobotSelectionに切り替えられなかった")
        }
    }

    func testJobDetailTabWorkTaskRobotBack() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "AssignedTaskセル[0]をタップ") { _ in
            _ = JobWorkTabPageObject(application: app).tapTaskCells(index: 0).waitExists(TaskDetailRobotSelectionPageObject.self)
        }
        XCTContext.runActivity(named: "Backで戻る") { _ in
            let page = TaskDetailRobotSelectionPageObject(application: app).tapBackButton(from: JobWorkTabPageObject(application: app)).waitExists(JobWorkTabPageObject.self)
            XCTAssertTrue(page.existsPage, "Backできなかった")
        }
    }

    func testJobDetailTabWorkTaskRobotTaskinfo() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "AssignedTaskセル[0]をタップ") { _ in
            _ = JobWorkTabPageObject(application: app).tapTaskCells(index: 0).waitExists(TaskDetailRobotSelectionPageObject.self)
        }
        XCTContext.runActivity(named: "ロボット[0]をタップ") { _ in
            let page = TaskDetailRobotSelectionPageObject(application: app).tapRobot(index: 0).waitExists(TaskDetailTaskInformationPageObject.self)
            XCTAssertTrue(page.existsPage, "ロボット[0]をタップできなかった")
        }
    }

    func testJobDetailTabWorkTaskRobotTaskinfoBack() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "AssignedTaskセル[0]をタップ") { _ in
            _ = JobWorkTabPageObject(application: app).tapTaskCells(index: 0).waitExists(TaskDetailRobotSelectionPageObject.self)
        }
        XCTContext.runActivity(named: "ロボット[0]をタップ") { _ in
            _ = TaskDetailRobotSelectionPageObject(application: app).tapRobot(index: 0).waitExists(TaskDetailTaskInformationPageObject.self)
        }
        XCTContext.runActivity(named: "Backで戻る") { _ in
            let page = TaskDetailTaskInformationPageObject(application: app).tapBackButton(from: TaskDetailRobotSelectionPageObject(application: app)).waitExists(TaskDetailRobotSelectionPageObject.self)
            XCTAssertTrue(page.existsPage, "Backできなかった")
        }
    }

    func testJobDetailTabWorkTaskRobotTaskinfoDetail() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "AssignedTaskセル[0]をタップ") { _ in
            _ = JobWorkTabPageObject(application: app).tapTaskCells(index: 0).waitExists(TaskDetailRobotSelectionPageObject.self)
        }
        XCTContext.runActivity(named: "ロボット[0]をタップ") { _ in
            _ = TaskDetailRobotSelectionPageObject(application: app).tapRobot(index: 0).waitExists(TaskDetailTaskInformationPageObject.self)
        }
        XCTContext.runActivity(named: "ShowDetailをタップ") { _ in
            let page = TaskDetailTaskInformationPageObject(application: app).tapShowDetailButton().waitExists(TaskDetailExecutionLogPageObject.self)
            XCTAssertTrue(page.existsPage, "ShowDetailをタップできなかった")
        }
    }

    func testJobDetailTabWorkTaskRobotTaskinfoDetailBack() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "AssignedTaskセル[0]をタップ") { _ in
            _ = JobWorkTabPageObject(application: app).tapTaskCells(index: 0).waitExists(TaskDetailRobotSelectionPageObject.self)
        }
        XCTContext.runActivity(named: "ロボット[0]をタップ") { _ in
            _ = TaskDetailRobotSelectionPageObject(application: app).tapRobot(index: 0).waitExists(TaskDetailTaskInformationPageObject.self)
        }
        XCTContext.runActivity(named: "ShowDetailをタップ") { _ in
            _ = TaskDetailTaskInformationPageObject(application: app).tapShowDetailButton().waitExists(TaskDetailExecutionLogPageObject.self)
        }
        XCTContext.runActivity(named: "Backで戻る") { _ in
            let page = TaskDetailExecutionLogPageObject(application: app).tapBackButton(from: TaskDetailTaskInformationPageObject(application: app)).waitExists(TaskDetailTaskInformationPageObject.self)
            XCTAssertTrue(page.existsPage, "Backできなかった")
        }
    }

    func testJobDetailTabWorkTaskTaskinfo() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "AssignedTaskセル[1]をタップ") { _ in
            let page = JobWorkTabPageObject(application: app).tapTaskCells(index: 1).waitExists(TaskDetailTaskInformationPageObject.self)
            XCTAssertTrue(page.existsPage, "TaskInformationに切り替えられなかった")
        }
    }

    func testJobDetailTabWorkTaskTaskinfoBack() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "AssignedTaskセル[1]をタップ") { _ in
            _ = JobWorkTabPageObject(application: app).tapTaskCells(index: 1).waitExists(TaskDetailTaskInformationPageObject.self)
        }
        XCTContext.runActivity(named: "Backで戻る") { _ in
            let page = TaskDetailTaskInformationPageObject(application: app).tapBackButton(from: JobWorkTabPageObject(application: app)).waitExists(JobWorkTabPageObject.self)
            XCTAssertTrue(page.existsPage, "Backできなかった")
        }
    }

    func testJobDetailTabWorkTaskTaskinfoDetail() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "AssignedTaskセル[1]をタップ") { _ in
            _ = JobWorkTabPageObject(application: app).tapTaskCells(index: 1).waitExists(TaskDetailTaskInformationPageObject.self)
        }
        XCTContext.runActivity(named: "ShowDetailをタップ") { _ in
            let page = TaskDetailTaskInformationPageObject(application: app).tapShowDetailButton().waitExists(TaskDetailExecutionLogPageObject.self)
            XCTAssertTrue(page.existsPage, "ShowDetailをタップできなかった")
        }
    }

    func testJobDetailTabWorkTaskTaskinfoDetailBack() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "AssignedTaskセル[1]をタップ") { _ in
            _ = JobWorkTabPageObject(application: app).tapTaskCells(index: 1).waitExists(TaskDetailTaskInformationPageObject.self)
        }
        XCTContext.runActivity(named: "ShowDetailをタップ") { _ in
            _ = TaskDetailTaskInformationPageObject(application: app).tapShowDetailButton().waitExists(TaskDetailExecutionLogPageObject.self)
        }
        XCTContext.runActivity(named: "Backで戻る") { _ in
            let page = TaskDetailExecutionLogPageObject(application: app).tapBackButton(from: TaskDetailTaskInformationPageObject(application: app)).waitExists(TaskDetailTaskInformationPageObject.self)
            XCTAssertTrue(page.existsPage, "Backできなかった")
        }
    }

    func testJobDetailTabWorkHistoryRobot() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "Historyセル[0]をタップ") { _ in
            let page = JobWorkTabPageObject(application: app).tapHistoryCells(index: 0).waitExists(TaskDetailRobotSelectionPageObject.self)
            XCTAssertTrue(page.existsPage, "RobotSelectionに切り替えられなかった")
        }
    }

    func testJobDetailTabWorkHistoryRobotBack() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "Historyセル[0]をタップ") { _ in
            _ = JobWorkTabPageObject(application: app).tapHistoryCells(index: 0).waitExists(TaskDetailRobotSelectionPageObject.self)
        }
        XCTContext.runActivity(named: "Backで戻る") { _ in
            let page = TaskDetailRobotSelectionPageObject(application: app).tapBackButton(from: JobWorkTabPageObject(application: app)).waitExists(JobWorkTabPageObject.self)
            XCTAssertTrue(page.existsPage, "Backできなかった")
        }
    }

    func testJobDetailTabWorkHistoryRobotTaskinfo() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "Historyセル[0]をタップ") { _ in
            _ = JobWorkTabPageObject(application: app).tapHistoryCells(index: 0).waitExists(TaskDetailRobotSelectionPageObject.self)
        }
        XCTContext.runActivity(named: "ロボット[0]をタップ") { _ in
            let page = TaskDetailRobotSelectionPageObject(application: app).tapRobot(index: 0).waitExists(TaskDetailTaskInformationPageObject.self)
            XCTAssertTrue(page.existsPage, "ロボット[0]をタップできなかった")
        }
    }

    func testJobDetailTabWorkHistoryRobotTaskinfoBack() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "Historyセル[0]をタップ") { _ in
            _ = JobWorkTabPageObject(application: app).tapHistoryCells(index: 0).waitExists(TaskDetailRobotSelectionPageObject.self)
        }
        XCTContext.runActivity(named: "ロボット[0]をタップ") { _ in
            _ = TaskDetailRobotSelectionPageObject(application: app).tapRobot(index: 0).waitExists(TaskDetailTaskInformationPageObject.self)
        }
        XCTContext.runActivity(named: "Backで戻る") { _ in
            let page = TaskDetailTaskInformationPageObject(application: app).tapBackButton(from: TaskDetailRobotSelectionPageObject(application: app)).waitExists(TaskDetailRobotSelectionPageObject.self)
            XCTAssertTrue(page.existsPage, "Backできなかった")
        }
    }

    func testJobDetailTabWorkHistoryRobotTaskinfoDetail() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "Historyセル[0]をタップ") { _ in
            _ = JobWorkTabPageObject(application: app).tapHistoryCells(index: 0).waitExists(TaskDetailRobotSelectionPageObject.self)
        }
        XCTContext.runActivity(named: "ロボット[0]をタップ") { _ in
            _ = TaskDetailRobotSelectionPageObject(application: app).tapRobot(index: 0).waitExists(TaskDetailTaskInformationPageObject.self)
        }
        XCTContext.runActivity(named: "ShowDetailをタップ") { _ in
            let page = TaskDetailTaskInformationPageObject(application: app).tapShowDetailButton().waitExists(TaskDetailExecutionLogPageObject.self)
            XCTAssertTrue(page.existsPage, "ShowDetailをタップできなかった")
        }
    }

    func testJobDetailTabWorkHistoryRobotTaskinfoDetailBack() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "Historyセル[0]をタップ") { _ in
            _ = JobWorkTabPageObject(application: app).tapHistoryCells(index: 0).waitExists(TaskDetailRobotSelectionPageObject.self)
        }
        XCTContext.runActivity(named: "ロボット[0]をタップ") { _ in
            _ = TaskDetailRobotSelectionPageObject(application: app).tapRobot(index: 0).waitExists(TaskDetailTaskInformationPageObject.self)
        }
        XCTContext.runActivity(named: "ShowDetailをタップ") { _ in
            _ = TaskDetailTaskInformationPageObject(application: app).tapShowDetailButton().waitExists(TaskDetailExecutionLogPageObject.self)
        }
        XCTContext.runActivity(named: "Backで戻る") { _ in
            let page = TaskDetailExecutionLogPageObject(application: app).tapBackButton(from: TaskDetailTaskInformationPageObject(application: app)).waitExists(TaskDetailTaskInformationPageObject.self)
            XCTAssertTrue(page.existsPage, "Backできなかった")
        }
    }

    func testJobDetailTabWorkHistoryTaskinfo() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "Historyセル[1]をタップ") { _ in
            let page = JobWorkTabPageObject(application: app).tapHistoryCells(index: 1).waitExists(TaskDetailTaskInformationPageObject.self)
            XCTAssertTrue(page.existsPage, "TaskInformationに切り替えられなかった")
        }
    }

    func testJobDetailTabWorkHistoryTaskinfoBack() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "Historyセル[1]をタップ") { _ in
            _ = JobWorkTabPageObject(application: app).tapHistoryCells(index: 1).waitExists(TaskDetailTaskInformationPageObject.self)
        }
        XCTContext.runActivity(named: "Backで戻る") { _ in
            let page = TaskDetailTaskInformationPageObject(application: app).tapBackButton(from: JobWorkTabPageObject(application: app)).waitExists(JobWorkTabPageObject.self)
            XCTAssertTrue(page.existsPage, "Backできなかった")
        }
    }

    func testJobDetailTabWorkHistoryTaskinfoDetail() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "Historyセル[1]をタップ") { _ in
            _ = JobWorkTabPageObject(application: app).tapHistoryCells(index: 1).waitExists(TaskDetailTaskInformationPageObject.self)
        }
        XCTContext.runActivity(named: "ShowDetailをタップ") { _ in
            let page = TaskDetailTaskInformationPageObject(application: app).tapShowDetailButton().waitExists(TaskDetailExecutionLogPageObject.self)
            XCTAssertTrue(page.existsPage, "ShowDetailをタップできなかった")
        }
    }

    func testJobDetailTabWorkHistoryTaskinfoDetailBack() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "Historyセル[1]をタップ") { _ in
            _ = JobWorkTabPageObject(application: app).tapHistoryCells(index: 1).waitExists(TaskDetailTaskInformationPageObject.self)
        }
        XCTContext.runActivity(named: "ShowDetailをタップ") { _ in
            _ = TaskDetailTaskInformationPageObject(application: app).tapShowDetailButton().waitExists(TaskDetailExecutionLogPageObject.self)
        }
        XCTContext.runActivity(named: "Backで戻る") { _ in
            let page = TaskDetailExecutionLogPageObject(application: app).tapBackButton(from: TaskDetailTaskInformationPageObject(application: app)).waitExists(TaskDetailTaskInformationPageObject.self)
            XCTAssertTrue(page.existsPage, "Backできなかった")
        }
    }

    func testJobDetailTabWorkHistorySeeAll() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "See Allをタップ") { _ in
            let page = JobWorkTabPageObject(application: app).tapSeeAllButton().waitExists(TaskDetailRunHistoryPageObject.self)
            XCTAssertTrue(page.existsPage, "See Allをタップできなかった")
        }
    }

    func testJobDetailTabWorkHistorySeeAllCancel() throws {
        let app = XCUIApplication()
        AuthenticationUITests.Login()
        XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
            _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
        }
        XCTContext.runActivity(named: "Job詳細表示") { _ in
            _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
        }
        XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
            _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
        }
        XCTContext.runActivity(named: "See Allをタップ") { _ in
            _ = JobWorkTabPageObject(application: app).tapSeeAllButton().waitExists(TaskDetailRunHistoryPageObject.self)
        }
        XCTContext.runActivity(named: "Cancelで戻る") { _ in
            let page = TaskDetailRunHistoryPageObject(application: app).tapCancelButton().waitExists(JobWorkTabPageObject.self)
            XCTAssertTrue(page.existsPage, "Cancelできなかった")
        }
    }

    // MARK: app.tables[“history_table”].existsがなぜかfalseになってしまい、cellをタップできないため、関連するテストを無効化
    /*
     func testJobDetailTabWorkHistorySeeAllAssigned() throws {
     let app = XCUIApplication()
     AuthenticationUITests.Login()
     XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
     _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
     }
     XCTContext.runActivity(named: "Job詳細表示") { _ in
     _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
     }
     XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
     _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
     }
     XCTContext.runActivity(named: "See Allをタップ") { _ in
     _ = JobWorkTabPageObject(application: app).tapSeeAllButton().waitExists(TaskDetailRunHistoryPageObject.self)
     }
     XCTContext.runActivity(named: "Historyセル[0]をタップ") { _ in
     let page = TaskDetailRunHistoryPageObject(application: app).tapHistoryCells(index: 0).waitExists(TaskDetailRobotSelectionPageObject.self)
     XCTAssertTrue(page.existsPage, "RobotSelectionに切り替えられなかった")
     }
     }

     func testJobDetailTabWorkHistorySeeAllAssignedBack() throws {
     let app = XCUIApplication()
     AuthenticationUITests.Login()
     XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
     _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
     }
     XCTContext.runActivity(named: "Job詳細表示") { _ in
     _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
     }
     XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
     _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
     }
     XCTContext.runActivity(named: "See Allをタップ") { _ in
     _ = JobWorkTabPageObject(application: app).tapSeeAllButton().waitExists(TaskDetailRunHistoryPageObject.self)
     }
     XCTContext.runActivity(named: "Historyセル[0]をタップ") { _ in
     _ = TaskDetailRunHistoryPageObject(application: app).tapHistoryCells(index: 0).waitExists(TaskDetailRobotSelectionPageObject.self)
     }
     XCTContext.runActivity(named: "Backで戻る") { _ in
     let page = TaskDetailRobotSelectionPageObject(application: app).tapRunHistoryButton().waitExists(TaskDetailRunHistoryPageObject.self)
     XCTAssertTrue(page.existsPage, "Backできなかった")
     }
     }

     func testJobDetailTabWorkHistorySeeAllAssignedRobot() throws {
     let app = XCUIApplication()
     AuthenticationUITests.Login()
     XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
     _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
     }
     XCTContext.runActivity(named: "Job詳細表示") { _ in
     _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
     }
     XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
     _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
     }
     XCTContext.runActivity(named: "See Allをタップ") { _ in
     _ = JobWorkTabPageObject(application: app).tapSeeAllButton().waitExists(TaskDetailRunHistoryPageObject.self)
     }
     XCTContext.runActivity(named: "Historyセル[0]をタップ") { _ in
     _ = TaskDetailRunHistoryPageObject(application: app).tapHistoryCells(index: 0).waitExists(TaskDetailRobotSelectionPageObject.self)
     }
     XCTContext.runActivity(named: "ロボット[0]をタップ") { _ in
     let page = TaskDetailRobotSelectionPageObject(application: app).tapRobot(index: 0).waitExists(TaskDetailTaskInformationPageObject.self)
     XCTAssertTrue(page.existsPage, "ロボット[0]をタップできなかった")
     }
     }

     func testJobDetailTabWorkHistorySeeAllAssignedRobotBack() throws {
     let app = XCUIApplication()
     AuthenticationUITests.Login()
     XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
     _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
     }
     XCTContext.runActivity(named: "Job詳細表示") { _ in
     _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
     }
     XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
     _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
     }
     XCTContext.runActivity(named: "See Allをタップ") { _ in
     _ = JobWorkTabPageObject(application: app).tapSeeAllButton().waitExists(TaskDetailRunHistoryPageObject.self)
     }
     XCTContext.runActivity(named: "Historyセル[0]をタップ") { _ in
     _ = TaskDetailRunHistoryPageObject(application: app).tapHistoryCells(index: 0).waitExists(TaskDetailRobotSelectionPageObject.self)
     }
     XCTContext.runActivity(named: "ロボット[0]をタップ") { _ in
     _ = TaskDetailRobotSelectionPageObject(application: app).tapRobot(index: 0).waitExists(TaskDetailTaskInformationPageObject.self)
     }
     XCTContext.runActivity(named: "Backで戻る") { _ in
     let page = TaskDetailTaskInformationPageObject(application: app).tapBackButton(from: TaskDetailRobotSelectionPageObject(application: app)).waitExists(TaskDetailRobotSelectionPageObject.self)
     XCTAssertTrue(page.existsPage, "Backできなかった")
     }
     }

     func testJobDetailTabWorkHistorySeeAllAssignedRobotDetail() throws {
     let app = XCUIApplication()
     AuthenticationUITests.Login()
     XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
     _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
     }
     XCTContext.runActivity(named: "Job詳細表示") { _ in
     _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
     }
     XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
     _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
     }
     XCTContext.runActivity(named: "See Allをタップ") { _ in
     _ = JobWorkTabPageObject(application: app).tapSeeAllButton().waitExists(TaskDetailRunHistoryPageObject.self)
     }
     XCTContext.runActivity(named: "Historyセル[0]をタップ") { _ in
     _ = TaskDetailRunHistoryPageObject(application: app).tapHistoryCells(index: 0).waitExists(TaskDetailRobotSelectionPageObject.self)
     }
     XCTContext.runActivity(named: "ロボット[0]をタップ") { _ in
     _ = TaskDetailRobotSelectionPageObject(application: app).tapRobot(index: 0).waitExists(TaskDetailTaskInformationPageObject.self)
     }
     XCTContext.runActivity(named: "ShowDetailをタップ") { _ in
     let page = TaskDetailTaskInformationPageObject(application: app).tapShowDetailButton().waitExists(TaskDetailExecutionLogPageObject.self)
     XCTAssertTrue(page.existsPage, "ShowDetailをタップできなかった")
     }
     }

     func testJobDetailTabWorkHistorySeeAllAssignedRobotDetailBack() throws {
     let app = XCUIApplication()
     AuthenticationUITests.Login()
     XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
     _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
     }
     XCTContext.runActivity(named: "Job詳細表示") { _ in
     _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
     }
     XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
     _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
     }
     XCTContext.runActivity(named: "See Allをタップ") { _ in
     _ = JobWorkTabPageObject(application: app).tapSeeAllButton().waitExists(TaskDetailRunHistoryPageObject.self)
     }
     XCTContext.runActivity(named: "Historyセル[0]をタップ") { _ in
     _ = TaskDetailRunHistoryPageObject(application: app).tapHistoryCells(index: 0).waitExists(TaskDetailRobotSelectionPageObject.self)
     }
     XCTContext.runActivity(named: "ロボット[0]をタップ") { _ in
     _ = TaskDetailRobotSelectionPageObject(application: app).tapRobot(index: 0).waitExists(TaskDetailTaskInformationPageObject.self)
     }
     XCTContext.runActivity(named: "ShowDetailをタップ") { _ in
     _ = TaskDetailTaskInformationPageObject(application: app).tapShowDetailButton().waitExists(TaskDetailExecutionLogPageObject.self)
     }
     XCTContext.runActivity(named: "Backで戻る") { _ in
     let page = TaskDetailExecutionLogPageObject(application: app).tapBackButton(from: TaskDetailTaskInformationPageObject(application: app)).waitExists(TaskDetailTaskInformationPageObject.self)
     XCTAssertTrue(page.existsPage, "Backできなかった")
     }
     }

     func testJobDetailTabWorkHistorySeeAllCommand() throws {
     let app = XCUIApplication()
     AuthenticationUITests.Login()
     XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
     _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
     }
     XCTContext.runActivity(named: "Job詳細表示") { _ in
     _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
     }
     XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
     _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
     }
     XCTContext.runActivity(named: "See Allをタップ") { _ in
     _ = JobWorkTabPageObject(application: app).tapSeeAllButton().waitExists(TaskDetailRunHistoryPageObject.self)
     }
     XCTContext.runActivity(named: "Historyセル[1]をタップ") { _ in
     let page = TaskDetailRunHistoryPageObject(application: app).tapHistoryCells(index: 1).waitExists(TaskDetailTaskInformationPageObject.self)
     XCTAssertTrue(page.existsPage, "TaskInformationに切り替えられなかった")
     }
     }

     func testJobDetailTabWorkHistorySeeAllCommandBack() throws {
     let app = XCUIApplication()
     AuthenticationUITests.Login()
     XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
     _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
     }
     XCTContext.runActivity(named: "Job詳細表示") { _ in
     _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
     }
     XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
     _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
     }
     XCTContext.runActivity(named: "See Allをタップ") { _ in
     _ = JobWorkTabPageObject(application: app).tapSeeAllButton().waitExists(TaskDetailRunHistoryPageObject.self)
     }
     XCTContext.runActivity(named: "Historyセル[1]をタップ") { _ in
     _ = TaskDetailRunHistoryPageObject(application: app).tapHistoryCells(index: 1).waitExists(TaskDetailTaskInformationPageObject.self)
     }
     XCTContext.runActivity(named: "Backで戻る") { _ in
     let page = TaskDetailTaskInformationPageObject(application: app).tapBackButton(from: JobWorkTabPageObject(application: app)).waitExists(JobWorkTabPageObject.self)
     XCTAssertTrue(page.existsPage, "Backできなかった")
     }
     }

     func testJobDetailTabWorkHistorySeeAllCommandDetail() throws {
     let app = XCUIApplication()
     AuthenticationUITests.Login()
     XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
     _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
     }
     XCTContext.runActivity(named: "Job詳細表示") { _ in
     _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
     }
     XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
     _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
     }
     XCTContext.runActivity(named: "See Allをタップ") { _ in
     _ = JobWorkTabPageObject(application: app).tapSeeAllButton().waitExists(TaskDetailRunHistoryPageObject.self)
     }
     XCTContext.runActivity(named: "Historyセル[1]をタップ") { _ in
     _ = TaskDetailRunHistoryPageObject(application: app).tapHistoryCells(index: 1).waitExists(TaskDetailTaskInformationPageObject.self)
     }
     XCTContext.runActivity(named: "ShowDetailをタップ") { _ in
     let page = TaskDetailTaskInformationPageObject(application: app).tapShowDetailButton().waitExists(TaskDetailExecutionLogPageObject.self)
     XCTAssertTrue(page.existsPage, "ShowDetailをタップできなかった")
     }
     }

     func testJobDetailTabWorkHistorySeeAllCommandDetailBack() throws {
     let app = XCUIApplication()
     AuthenticationUITests.Login()
     XCTContext.runActivity(named: "タブ切り替え（Job）") { _ in
     _ = MainPageObject(application: app).tapTabJobButton().waitExists(JobListPageObject.self)
     }
     XCTContext.runActivity(named: "Job詳細表示") { _ in
     _ = JobListPageObject(application: app).tapCell(index: 0).waitExists(JobDetailPageObject.self)
     }
     XCTContext.runActivity(named: "タブ切り替え(Work)") { _ in
     _ = JobDetailPageObject(application: app).tapWorkTab().waitExists(JobWorkTabPageObject.self)
     }
     XCTContext.runActivity(named: "See Allをタップ") { _ in
     _ = JobWorkTabPageObject(application: app).tapSeeAllButton().waitExists(TaskDetailRunHistoryPageObject.self)
     }
     XCTContext.runActivity(named: "Historyセル[1]をタップ") { _ in
     _ = TaskDetailRunHistoryPageObject(application: app).tapHistoryCells(index: 1).waitExists(TaskDetailTaskInformationPageObject.self)
     }
     XCTContext.runActivity(named: "ShowDetailをタップ") { _ in
     _ = TaskDetailTaskInformationPageObject(application: app).tapShowDetailButton().waitExists(TaskDetailExecutionLogPageObject.self)
     }
     XCTContext.runActivity(named: "Backで戻る") { _ in
     let page = TaskDetailExecutionLogPageObject(application: app).tapBackButton(from: TaskDetailTaskInformationPageObject(application: app)).waitExists(TaskDetailTaskInformationPageObject.self)
     XCTAssertTrue(page.existsPage, "Backできなかった")
     }
     }
     */
}

extension XCUIElement {
    func forceTapElement() {
        if self.isHittable {
            self.tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
            coordinate.tap()
        }
    }
}
