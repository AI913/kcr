//
//  ActionEntryConfigurationViewControllerTests.swift
//  JobOrderUITests
//
//  Created by frontarc on 2021/03/02.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class ActionEntryConfigurationViewControllerTests: XCTestCase {

    private let mock = ActionEntryConfigurationPresenterProtocolMock()
    private let vc = StoryboardScene.ActionEntry.actionEntryForm.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.image, "imageがOutletに接続されていない")
        XCTAssertNotNil(vc.nameLabel, "nameLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.segmentedControl, "segmentedControlがOutletに接続されていない")
        XCTAssertNotNil(vc.containerView, "containerViewがOutletに接続されていない")
        XCTAssertNotNil(vc.containerViewHeight, "containerViewHeightがOutletに接続されていない")
        XCTAssertNotNil(vc.cancelButton, "cancelButtonがOutletに接続されていない")
    }

    func test_actions() throws {
        let infoButton = try XCTUnwrap(vc.infoButton, "Unwrap失敗")
        let segmentedControl = try XCTUnwrap(vc.segmentedControl, "Unwrap")
        let cancelButton = try XCTUnwrap(vc.cancelButton, "Unwrap失敗")
        XCTAssertNoThrow(infoButton.sendActions(for: .touchUpInside), "タップで例外発生: \(infoButton)")
        XCTAssertNoThrow(segmentedControl.sendActions(for: .valueChanged), "セグメント選択で例外発生: \(segmentedControl)")
        XCTAssertNoThrow(cancelButton.target?.perform(cancelButton.action, with: nil), "タップで例外発生: \(cancelButton)")
    }
}
