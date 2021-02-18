//
//  MailVerificationCompleteViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/07/30.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class MailVerificationCompleteViewControllerTests: XCTestCase {

    private let vc = StoryboardScene.Authentication.mailVerificationComplete.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.closeButton, "closeButtonがOutletに接続されていない")
    }

    func test_actions() throws {
        let closeButton = try XCTUnwrap(vc.closeButton, "Unwrap失敗")
        XCTAssertNoThrow(closeButton.sendActions(for: .touchUpInside), "タップで例外発生: \(closeButton)")
    }
}
