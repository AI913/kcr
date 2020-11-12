//
//  JobListViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class JobListViewControllerTests: XCTestCase {

    private let mock = JobListPresenterProtocolMock()
    private let vc = StoryboardScene.Main.jobList.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.addButtonItem, "addButtonItemがOutletに接続されていない")
    }

    func test_actions() throws {
        let addButtonItem = try XCTUnwrap(vc.addButtonItem, "Unwrap失敗")
        XCTAssertNoThrow(addButtonItem.target?.perform(addButtonItem.action, with: nil), "タップで例外発生: \(addButtonItem)")
    }

    func test_updateSearchResults() {
        vc.updateSearchResults(for: UISearchController())
        XCTAssertEqual(mock.filterAndSortCallCount, 1, "Presenterのメソッドが呼ばれない")
    }

}
