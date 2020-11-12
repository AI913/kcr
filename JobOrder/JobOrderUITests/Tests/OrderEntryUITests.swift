//
//  OrderEntryUITests.swift
//  JobOrderUITests
//
//  Created by 藤井一暢 on 2020/10/20.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest

class OrderEntryUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    override func tearDownWithError() throws {}

    func testCancelOrderEntryViaRobotDetail() throws {
        let jobSelectionPage = jobSelectionPageViaRobotDetail()

        XCTContext.runActivity(named: "Job選択画面でキャンセルする") { _ in
            let robotDetailPage = jobSelectionPage
                .tapCancelButtonToRobotDetail()
                .waitExists(self, RobotDetailPageObject.self)
            XCTAssertFalse(jobSelectionPage.existsPage, "Job選択画面が閉じられていなかった")
            XCTAssertTrue(robotDetailPage.existsPage, "Robot画面に戻っていなかった")
        }
    }

    func testCancelOrderEntryViaJobDetail() throws {
        let robotSelectionPage = robotSelectionPageViaJobDetail()

        XCTContext.runActivity(named: "Robot選択画面でJob選択画面に戻る") { _ in
            let jobSelectionPage = robotSelectionPage
                .tapSelectJobButton()
                .waitExists(self, JobSelectionPageObject.self)
            XCTAssertTrue(jobSelectionPage.existsPage, "Job選択画面に戻っていなかった")

            XCTContext.runActivity(named: "Job選択画面でキャンセルする") { _ in
                let jobDetailPage = jobSelectionPage
                    .tapCancelButtonToJobDetail()
                    .waitExists(self, JobDetailPageObject.self)
                XCTAssertFalse(jobSelectionPage.existsPage, "Job選択画面が閉じられていなかった")
                XCTAssertTrue(jobDetailPage.existsPage, "Job画面に戻っていなかった")
            }
        }
    }

    func testOrderEntryViaRobotDetail() throws {
        let jobSelectionPage = jobSelectionPageViaRobotDetail()

        XCTContext.runActivity(named: "Job選択画面でJobを選択して次へ") { _ in
            let jobIndex = 0

            let robotSelectionPage = jobSelectionPage
                .tapJobCell(at: jobIndex)
                .tapContinueButton()
                .waitExists(self, RobotSelectionPageObject.self)
            XCTAssertTrue(robotSelectionPage.existsPage, "Robot選択画面に遷移しなかった")

            XCTContext.runActivity(named: "Robot選択画面で何も変更せずそのまま次へ") { _ in
                let configurationPage = robotSelectionPage
                    .tapContinueButton()
                    .waitExists(self, OrderConfigurationPageObject.self)
                XCTAssertTrue(configurationPage.existsPage, "Order設定画面に遷移しなかった")

                XCTContext.runActivity(named: "Order設定画面で項目を入力して次へ") { _ in
                    let numOfRun = 123
                    let remark = "some text"

                    let confirmPage = configurationPage
                        .enterNumOfRun(numOfRun)
                        .dismissKeyboardIfPresented()
                        .enterRemark(remark)
                        .dismissKeyboardIfPresented()
                        .tapContinueButton()
                        .waitExists(self, OrderConfirmPageObject.self)
                    XCTAssertTrue(confirmPage.existsPage, "Order確認画面に遷移しなかった")

                    XCTContext.runActivity(named: "Order確認して次へ") { _ in
                        XCTAssertEqual(confirmPage.numOfRunLabel.label, String(numOfRun), "Num Of Runsの設定が反映されていなかった")
                        XCTAssertEqual(confirmPage.remarkLabel.label, remark, "Remarksの設定が反映されていなかった")

                        let completePage = confirmPage
                            .tapSendButton()
                            .waitExists(self, OrderCompletePageObject.self)
                        XCTAssertTrue(completePage.existsPage, "Order完了画面に遷移しなかった")

                        XCTContext.runActivity(named: "Order完了") { _ in
                            let robotDetailPage = completePage
                                .tapCloseButtonToRobotDetail()
                                .waitExists(self, RobotDetailPageObject.self)
                            XCTAssertFalse(completePage.existsPage, "Order完了画面が閉じられていなかった")
                            XCTAssertTrue(robotDetailPage.existsPage, "Robot画面に戻っていなかった")
                        }
                    }
                }
            }
        }
    }

    func testOrderEntryViaJobDetail() throws {
        let robotSelectionPage = robotSelectionPageViaJobDetail()

        XCTContext.runActivity(named: "Robot選択画面で選択して次へ") { _ in
            let robotIndex = 0

            let configurationPage = robotSelectionPage
                .tapRobotCell(at: robotIndex)
                .tapContinueButton()
                .waitExists(self, OrderConfigurationPageObject.self)
            XCTAssertTrue(configurationPage.existsPage, "Order設定画面に遷移しなかった")

            XCTContext.runActivity(named: "Order設定画面で項目を入力して次へ") { _ in
                let numOfRun = 123
                let remark = "some text"

                let confirmPage = configurationPage
                    .enterNumOfRun(numOfRun)
                    .dismissKeyboardIfPresented()
                    .enterRemark(remark)
                    .dismissKeyboardIfPresented()
                    .tapContinueButton()
                    .waitExists(self, OrderConfirmPageObject.self)
                XCTAssertTrue(confirmPage.existsPage, "Order確認画面に遷移しなかった")

                XCTContext.runActivity(named: "Order確認して次へ") { _ in
                    XCTAssertEqual(confirmPage.numOfRunLabel.label, String(numOfRun), "Num Of Runsの設定が反映されていなかった")
                    XCTAssertEqual(confirmPage.remarkLabel.label, remark, "Remarksの設定が反映されていなかった")

                    let completePage = confirmPage
                        .tapSendButton()
                        .waitExists(self, OrderCompletePageObject.self)
                    XCTAssertTrue(completePage.existsPage, "Order完了画面に遷移しなかった")

                    XCTContext.runActivity(named: "Order完了") { _ in
                        let jobDetailPage = completePage
                            .tapCloseButtonToJobDetail()
                            .waitExists(self, JobDetailPageObject.self)
                        XCTAssertFalse(completePage.existsPage, "Order完了画面が閉じられていなかった")
                        XCTAssertTrue(jobDetailPage.existsPage, "Job画面に戻っていなかった")
                    }
                }
            }
        }
    }

    func testCancelDeeplyOrderEntryViaRobotDetail() throws {
        let jobIndex = 0
        let numOfRun = 123
        let remark = "some text"
        // Robot画面からJobOrder確認画面まで進める
        let confirmPage = jobSelectionPageViaRobotDetail()
            .tapJobCell(at: jobIndex)
            .tapContinueButton()
            .waitExists(self, RobotSelectionPageObject.self)
            .tapContinueButton()
            .waitExists(self, OrderConfigurationPageObject.self)
            .enterNumOfRun(numOfRun)
            .dismissKeyboardIfPresented()
            .enterRemark(remark)
            .dismissKeyboardIfPresented()
            .tapContinueButton()
            .waitExists(self, OrderConfirmPageObject.self)

        XCTContext.runActivity(named: "Order確認から前の画面に戻る") { _ in
            let backedConfigurationPage = confirmPage
                .tapOrderConfigurationButton()
                .waitExists(self, OrderConfigurationPageObject.self)
            XCTAssertFalse(confirmPage.existsPage, "Order確認画面が閉じられていなかった")
            XCTAssertTrue(backedConfigurationPage.existsPage, "Order設定画面に戻っていなかった")

            XCTContext.runActivity(named: "Order設定から前の画面に戻る") { _ in
                let backedRobotSelectionPage = backedConfigurationPage
                    .tapSelectRobotButton()
                    .waitExists(self, RobotSelectionPageObject.self)
                XCTAssertFalse(backedConfigurationPage.existsPage, "Order設定画面が閉じられていなかった")
                XCTAssertTrue(backedRobotSelectionPage.existsPage, "Robot選択画面に戻っていなかった")

                XCTContext.runActivity(named: "Robot選択から前の画面に戻る") { _ in
                    let backedJobSelectionPage = backedRobotSelectionPage
                        .tapSelectJobButton()
                        .waitExists(self, JobSelectionPageObject.self)
                    XCTAssertFalse(backedRobotSelectionPage.existsPage, "Robot選択画面が閉じられていなかった")
                    XCTAssertTrue(backedJobSelectionPage.existsPage, "Job選択画面に戻っていなかった")

                    XCTContext.runActivity(named: "Job選択から前の画面に戻る") { _ in
                        let robotDetailPage = backedJobSelectionPage
                            .tapCancelButtonToRobotDetail()
                            .waitExists(self, RobotDetailPageObject.self)
                        XCTAssertFalse(backedJobSelectionPage.existsPage, "Job選択画面が閉じられていなかった")
                        XCTAssertTrue(robotDetailPage.existsPage, "Robot画面に戻っていなかった")
                    }
                }
            }
        }
    }

    func testCancelDeeplyOrderEntryViaJobDetail() throws {
        let robotIndex = 0
        let numOfRun = 123
        let remark = "some text"
        // Job画面からJobOrder確認画面まで進める
        let confirmPage = robotSelectionPageViaJobDetail()
            .tapRobotCell(at: robotIndex)
            .tapContinueButton()
            .waitExists(self, OrderConfigurationPageObject.self)
            .enterNumOfRun(numOfRun)
            .dismissKeyboardIfPresented()
            .enterRemark(remark)
            .dismissKeyboardIfPresented()
            .tapContinueButton()
            .waitExists(self, OrderConfirmPageObject.self)

        XCTContext.runActivity(named: "Order確認から前の画面に戻る") { _ in
            let backedConfigurationPage = confirmPage
                .tapOrderConfigurationButton()
                .waitExists(self, OrderConfigurationPageObject.self)
            XCTAssertFalse(confirmPage.existsPage, "Order確認画面が閉じられていなかった")
            XCTAssertTrue(backedConfigurationPage.existsPage, "Order設定画面に戻っていなかった")

            XCTContext.runActivity(named: "Order設定から前の画面に戻る") { _ in
                let backedRobotSelectionPage = backedConfigurationPage
                    .tapSelectRobotButton()
                    .waitExists(self, RobotSelectionPageObject.self)
                XCTAssertFalse(backedConfigurationPage.existsPage, "Order設定画面が閉じられていなかった")
                XCTAssertTrue(backedRobotSelectionPage.existsPage, "Robot選択画面に戻っていなかった")

                XCTContext.runActivity(named: "Robot選択から前の画面に戻る") { _ in
                    let backedJobSelectionPage = backedRobotSelectionPage
                        .tapSelectJobButton()
                        .waitExists(self, JobSelectionPageObject.self)
                    XCTAssertFalse(backedRobotSelectionPage.existsPage, "Robot選択画面が閉じられていなかった")
                    XCTAssertTrue(backedJobSelectionPage.existsPage, "Job選択画面に戻っていなかった")

                    XCTContext.runActivity(named: "Job選択から前の画面に戻る") { _ in
                        let jobDetailPage = backedJobSelectionPage
                            .tapCancelButtonToJobDetail()
                            .waitExists(self, JobDetailPageObject.self)
                        XCTAssertFalse(backedJobSelectionPage.existsPage, "Job選択画面が閉じられていなかった")
                        XCTAssertTrue(jobDetailPage.existsPage, "Job画面に戻っていなかった")
                    }
                }
            }
        }
    }
}

// MARK: - Private Function

extension OrderEntryUITests {
    private func jobSelectionPageViaRobotDetail(by index: Int = 0) -> JobSelectionPageObject {
        let app = XCUIApplication()
        // ログインする
        AuthenticationUITests.Login()
        sleep(1)

        let jobSelectionPage = MainPageObject(application: app)
            .tapTabRobotButton()	// ロボットタブを選択する
            .waitExists(self, RobotListPageObject.self)
            .tapCell(index: index)	// ロボット一覧から１つ詳細を選ぶ
            .waitExists(self, RobotDetailPageObject.self)
            .tapOrderButton()		// Order jobボタンをタップする
            .waitExists(self, JobSelectionPageObject.self)	// ジョブ選択画面を待つ

        return jobSelectionPage
    }

    private func robotSelectionPageViaJobDetail(by index: Int = 0) -> RobotSelectionPageObject {
        let app = XCUIApplication()
        // ログインする
        AuthenticationUITests.Login()
        sleep(1)

        let robotSelectionPage = MainPageObject(application: app)
            .tapTabJobButton()		// ジョブタブを選択する
            .waitExists(self, JobListPageObject.self)
            .tapCell(index: index)	// ジョブ一覧から１つ詳細を選ぶ
            .waitExists(self, JobDetailPageObject.self)
            .tapOrderButton()		// Order jobボタンをタップする
            .waitExists(self, RobotSelectionPageObject.self)	// ロボット選択画面を待つ

        return robotSelectionPage
    }
}
