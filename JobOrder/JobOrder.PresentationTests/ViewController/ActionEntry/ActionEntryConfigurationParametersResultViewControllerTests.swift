//
//  ActionEntryConfigurationParametersResultViewControllerTests.swift
//  JobOrderUITests
//
//  Created by frontarc on 2021/03/02.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class ActionEntryConfigurationParametersResultViewControllerTests: XCTestCase {

    private let mock = ActionEntryConfigurationParametersResultPresenterProtocolMock()
    private let vc = StoryboardScene.ActionEntry.actionEntryParameters.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.resultLabel, "resultLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.resultTable, "resultTableがOutletに接続されていない")
        XCTAssertNotNil(vc.completeButton, "completeButtonがOutletに接続されていない")
    }

    func test_actions() throws {
        let completeButton = try XCTUnwrap(vc.completeButton, "Unwrap失敗")
        XCTAssertNoThrow(completeButton.sendActions(for: .touchUpInside), "タップで例外発生: \(completeButton)")
    }
}
