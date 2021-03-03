//
//  ActionEntryConfigurationRemarksViewControllerTests.swift
//  JobOrderUITests
//
//  Created by frontarc on 2021/03/02.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class ActionEntryConfigurationRemarksViewControllerTests: XCTestCase {

    private let mock = ActionEntryConfigurationRemarksPresenterProtocolMock()
    private let vc = StoryboardScene.ActionEntry.actionEntryRemarks.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.remarksTextView, "remarksTextViewがOutletに接続されていない")
    }

}
