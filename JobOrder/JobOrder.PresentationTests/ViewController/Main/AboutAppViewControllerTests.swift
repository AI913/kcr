//
//  AboutAppViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class AboutAppViewControllerTests: XCTestCase {

    private let mock = AboutAppPresenterProtocolMock()
    private let vc = StoryboardScene.Main.aboutApp.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.appNameLabel, "appNameLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.appVersionLabel, "appVersionLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.thingNameLabel, "thingNameLabelがOutletに接続されていない")
    }

    func test_actions() throws {}

}
