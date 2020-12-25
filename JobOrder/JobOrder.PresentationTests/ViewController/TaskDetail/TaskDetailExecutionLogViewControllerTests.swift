//
//  TaskDetailExecutionLogViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by 藤井一暢 on 2020/12/15.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class TaskDetailExecutionLogViewControllerTests: XCTestCase {

    private lazy var mock = TaskDetailExecutionLogPresenterProtocolMock()
    private let vc = StoryboardScene.TaskDetail.taskDetailExecutionLog.instantiate()

    override func setUpWithError() throws {
        vc.presenter = mock
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.tableView, "tableViewがOutletに接続されていない")
        XCTAssertNotNil(vc.prevButton, "prevButtonがOutletに接続されていない")
        XCTAssertNotNil(vc.nextButton, "nextButtonがOutletに接続されていない")
        XCTAssertNotNil(vc.pageLabel, "pageLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.robotLabel, "robotLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.jobLabel, "robotLabelがOutletに接続されていない")
    }

    func test_actions() throws {
        let prevButton = try XCTUnwrap(vc.prevButton, "Unwrap失敗")
        let nextButton = try XCTUnwrap(vc.nextButton, "Unwrap失敗")
        XCTContext.runActivity(named: "Prevボタン") { _ in
            XCTAssertNoThrow(prevButton.sendActions(for: .touchUpInside), "タップで例外発生: \(prevButton)")
            XCTAssertEqual(mock.viewPrevPageCallCount, 1, "前ページへの更新が行われない")
            XCTAssertFalse(prevButton.isEnabled, "ボタンが押下禁止にならない")
        }
        XCTContext.runActivity(named: "Nextボタン") { _ in
            XCTAssertNoThrow(nextButton.sendActions(for: .touchUpInside), "タップで例外発生: \(nextButton)")
            XCTAssertEqual(mock.viewNextPageCallCount, 1, "次ページへの更新が行われない")
            XCTAssertFalse(nextButton.isEnabled, "ボタンが押下禁止にならない")
        }
    }

    func test_viewWillAppear() {
        XCTAssertEqual(mock.viewWillAppearCallCount, 1, "viewWillAppearがsetUpWithErrorで呼ばれていない")
        XCTAssertEqual(mock.canGoPrevCallCount, 1, "画面表示で前ページの遷移可否確認が行われない")
        XCTAssertEqual(mock.canGoNextCallCount, 1, "画面表示で次ページの遷移可否確認が行われない")
        XCTAssertEqual(mock.pageTextCallCount, 1, "画面表示でページネーションの状態確認が行われない")
    }

    func test_showErrorAlert() {
        vc.showErrorAlert(NSError(domain: "Error", code: -1, userInfo: nil))
        XCTAssertTrue(vc.presentedViewController is UIAlertController, "アラートが表示されない")
    }
}
