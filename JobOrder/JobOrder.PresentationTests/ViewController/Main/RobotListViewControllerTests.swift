//
//  RobotListViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class RobotListViewControllerTests: XCTestCase {

    private let mock = RobotListPresenterProtocolMock()
    private let vc = StoryboardScene.Main.robotList.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_updateSearchResults() {
        vc.updateSearchResults(for: UISearchController())
        XCTAssertEqual(mock.filterAndSortCallCount, 1, "Presenterのメソッドが呼ばれない")
    }
}
