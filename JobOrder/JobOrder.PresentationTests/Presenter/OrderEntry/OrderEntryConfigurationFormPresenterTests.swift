//
//  OrderEntryConfigurationFormPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation

class OrderEntryConfigurationFormPresenterTests: XCTestCase {

    private let vc = OrderEntryConfigurationFormViewControllerProtocolMock()
    private let viewData = OrderEntryViewData(nil, nil)
    private lazy var presenter = OrderEntryConfigurationFormPresenter(vc: vc,
                                                                      viewData: viewData)

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_startCondition() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.data.form.startCondition = nil
            XCTAssertNil(presenter.startCondition, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "設定済みの場合") { _ in
            presenter.data.form.startCondition = OrderEntryViewData.Form.StartCondition(key: "immediately")
            XCTAssertEqual(presenter.startCondition, "immediately", "正常に値が設定されていない")
        }

        XCTContext.runActivity(named: "想定外の値が設定されていた場合") { _ in
            presenter.data.form.startCondition = OrderEntryViewData.Form.StartCondition(key: "test")
            XCTAssertEqual(presenter.startCondition, "Unknown", "正常に値が設定されていない")
        }
    }

    func test_exitCondition() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.data.form.exitCondition = nil
            XCTAssertNil(presenter.exitCondition, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "設定済みの場合") { _ in
            presenter.data.form.exitCondition = OrderEntryViewData.Form.ExitCondition(key: "specifiedNumberOfTimes")
            XCTAssertEqual(presenter.exitCondition, "specifiedNumberOfTimes", "正常に値が設定されていない")
        }

        XCTContext.runActivity(named: "想定外の値が設定されていた場合") { _ in
            presenter.data.form.exitCondition = OrderEntryViewData.Form.ExitCondition(key: "test")
            XCTAssertEqual(presenter.exitCondition, "Unknown", "正常に値が設定されていない")
        }
    }

    func test_isEnabledContinueButton() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(presenter.isEnabledContinueButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "設定済みの場合") { _ in
            presenter.data.form.numberOfRuns = 1
            XCTAssertTrue(presenter.isEnabledContinueButton, "無効になってはいけない")
        }
    }

    func test_numberOfRuns() {
        let param = 1

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(presenter.numberOfRuns, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "設定済みの場合") { _ in
            presenter.data.form.numberOfRuns = param
            XCTAssertEqual(presenter.numberOfRuns, "\(param)", "正しい値が取得できていない: \(param)")
        }

        XCTContext.runActivity(named: "\(param)を設定した場合") { _ in
            presenter.data.form.numberOfRuns = 0
            presenter.numberOfRuns = String(param)
            XCTAssertEqual(presenter.data.form.numberOfRuns, param, "正しい値が取得できていない: \(param)")
        }

        XCTContext.runActivity(named: "数字以外を設定した場合") { _ in
            presenter.data.form.numberOfRuns = 0
            presenter.numberOfRuns = "test"
            XCTAssertEqual(presenter.data.form.numberOfRuns, 0, "正しい値が取得できていない")
        }
    }

    func test_remarks() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(presenter.remarks, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "設定済みの場合") { _ in
            presenter.data.form.remarks = param
            XCTAssertEqual(presenter.remarks, param, "正しい値が取得できていない: \(param)")
        }

        XCTContext.runActivity(named: "\(param)を設定した場合") { _ in
            presenter.remarks = param
            XCTAssertEqual(presenter.data.form.remarks, param, "正しい値が取得できていない: \(param)")
        }
    }

    func test_tapIncrementNumberOfRunsButton() {

        XCTContext.runActivity(named: "1回ボタンをタップした場合") { _ in
            let param = 1
            presenter.data.form.numberOfRuns = 0
            presenter.tapIncrementNumberOfRunsButton(num: param)
            XCTAssertEqual(presenter.data.form.numberOfRuns, param, "正しい値が設定できていない: \(param)")
        }

        XCTContext.runActivity(named: "5回ボタンをタップした場合") { _ in
            let param = 5
            presenter.data.form.numberOfRuns = 0
            presenter.tapIncrementNumberOfRunsButton(num: param)
            XCTAssertEqual(presenter.data.form.numberOfRuns, param, "正しい値が設定できていない: \(param)")
        }

        XCTContext.runActivity(named: "10回ボタンをタップした場合") { _ in
            let param = 10
            presenter.data.form.numberOfRuns = 0
            presenter.tapIncrementNumberOfRunsButton(num: param)
            XCTAssertEqual(presenter.data.form.numberOfRuns, param, "正しい値が設定できていない: \(param)")
        }
    }

    func test_tapClearNumberOfRunsButton() {

        XCTContext.runActivity(named: "Clearボタンをタップした場合") { _ in
            presenter.data.form.numberOfRuns = 5
            presenter.tapClearNumberOfRunsButton()
            XCTAssertEqual(presenter.data.form.numberOfRuns, 0, "正しい値が設定できていない")
        }
    }

    func test_tapContinueButton() {
        presenter.tapContinueButton()
        XCTAssertEqual(vc.transitionToConfirmScreenCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }
}
