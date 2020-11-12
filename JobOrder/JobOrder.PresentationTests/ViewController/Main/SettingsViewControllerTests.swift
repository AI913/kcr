//
//  SettingsViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class SettingsViewControllerTests: XCTestCase {

    private let mock = SettingsPresenterProtocolMock()
    private let vc = StoryboardScene.Main.settings.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.accountidentifierLabel, "accountidentifierLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.accountRemarksLabel, "accountRemarksLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.menuTable, "menuTableがOutletに接続されていない")
        XCTAssertNotNil(vc.indicator, "indicatorがOutletに接続されていない")
    }

    func test_actions() throws {}

    func test_viewWillAppear() throws {
        let accountidentifierLabel = try XCTUnwrap(vc.accountidentifierLabel, "Unwrap失敗")
        let param = "test"
        vc.accountidentifierLabel.text = nil

        mock.emailHandler = { completion in
            completion(param)
        }
        vc.viewWillAppear(true)
        XCTAssertEqual(mock.emailCallCount, 1, "Presenterのメソッドが呼ばれない")
        XCTAssertEqual(accountidentifierLabel.text, param, "テキストが設定されていない: \(accountidentifierLabel)")
    }

    func test_viewWillAppearWithoutEmail() throws {
        let accountidentifierLabel = try XCTUnwrap(vc.accountidentifierLabel, "Unwrap失敗")
        vc.accountidentifierLabel.text = nil

        mock.emailHandler = { completion in }
        vc.viewWillAppear(true)
        XCTAssertEqual(mock.emailCallCount, 1, "Presenterのメソッドが呼ばれない")
        XCTAssertNil(vc.accountidentifierLabel.text, "テキストを設定してはいけない: \(accountidentifierLabel)")
    }

    func test_processing() throws {
        let indicator = try XCTUnwrap(vc.indicator, "Unwrap失敗")

        XCTContext.runActivity(named: "処理中の場合") { _ in
            vc.changedProcessing(true)
            XCTAssertTrue(indicator.isAnimating, "インジケータが動作していない: \(indicator)")
        }

        XCTContext.runActivity(named: "処理中でない場合") { _ in
            vc.changedProcessing(false)
            XCTAssertFalse(indicator.isAnimating, "インジケータが動作してはいけない: \(indicator)")
        }
    }

    func test_showAlert() {
        vc.showErrorAlert(NSError(domain: "Error", code: -1, userInfo: nil))
        XCTAssertTrue(vc.presentedViewController is UIAlertController, "アラートが表示されない")
    }
}
