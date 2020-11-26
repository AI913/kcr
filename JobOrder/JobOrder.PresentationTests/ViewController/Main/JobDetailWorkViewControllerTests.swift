//
//  JobDetailWorkViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by 藤井一暢 on 2020/11/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class JobDetailWorkViewControllerTests: XCTestCase {

    private let data = MainViewData.Job()
    private lazy var mock = JobDetailWorkPresenterProtocolMock(data: data)
    private let vc = StoryboardScene.Main.jobDetailWork.instantiate()

    override func setUpWithError() throws {
        vc.presenter = mock
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.taskTableView, "taskTableViewがOutletに接続されていない")
        XCTAssertNotNil(vc.historyTableView, "historyTableViewがOutletに接続されていない")
        XCTAssertNotNil(vc.taskTableViewHeight, "taskTableViewHeightがOutletに接続されていない")
        XCTAssertNotNil(vc.historyTableViewHeight, "historyTableViewHeightがOutletに接続されていない")
    }

    func test_actions() throws {
        let seeAllButton = try XCTUnwrap(vc.seeAllButton, "Unwrap失敗")
        XCTAssertNoThrow(seeAllButton.sendActions(for: .touchUpInside), "タップで例外発生: \(seeAllButton)")
    }

    func test_inject() {
        let param = "test"
        vc.inject(viewData: MainViewData.Job(id: param))
        XCTAssertEqual(vc.viewData.id, param, "正常に値が設定されていない")
    }

    func test_viewWillAppear() {
        XCTAssertEqual(mock.viewWillAppearCallCount, 1, "viewWillAppearがsetUpWithErrorで呼ばれていない")
    }

    func test_showErrorAlert() {
        vc.showErrorAlert(NSError(domain: "Error", code: -1, userInfo: nil))
        XCTAssertTrue(vc.presentedViewController is UIAlertController, "アラートが表示されない")
    }

    func test_set() {
        let param: CGFloat = 1.0
        vc.set(height: param)
        XCTAssertEqual(vc.initialHeight, param, "正常に呼ばれること")
    }

}
