//
//  TaskDetailViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by admin on 2020/11/11.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class TaskDetailRobotSelectionViewControllerTests: XCTestCase {

    private let mock = TaskDetailRobotSelectionPresenterProtocolMock()
    private let vc = StoryboardScene.TaskDetail.robotSelect.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.cancelAllTasksButton, "cancelTaskButtonがOutletに接続されていない")
        XCTAssertNotNil(vc.jobNameLabel, "jobValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.createdAtValueLabel, "createdAtValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.updatedAtLabel, "lastUpdatedAtValueLabelがOutletに接続されていない")
    }

    func test_actions() throws {
        let cancelAllTasksButton = try XCTUnwrap(vc.cancelAllTasksButton, "Unwrap失敗")
        XCTAssertNoThrow(cancelAllTasksButton.sendActions(for: .touchUpInside), "タップで例外発生: \(cancelAllTasksButton)")
    }

    func test_inject() {
        let param1 = "TaskTest"
        vc.inject(taskId: param1)
        XCTAssertEqual(vc.taskId, param1, "正常に値が設定されていない")
    }

    func test_viewWillAppear() {
        let param1 = "TaskTest"
        vc.inject(taskId: param1)
        vc.presenter = mock
        vc.viewWillAppear(true)

        print(mock.viewWillAppearCallCount)
        XCTAssertEqual(mock.viewWillAppearCallCount, 1, "Presenterのメソッドが呼ばれない")
    }

    func test_tapOrderButton() {
        vc.cancelAllTasksButton.sendActions(for: .touchUpInside)
        //TODO:未実装
    }

    func test_showErrorAlert() {
        vc.showErrorAlert(NSError(domain: "Error", code: -1, userInfo: nil))
        XCTAssertTrue(vc.presentedViewController is UIAlertController, "アラートが表示されない")
    }
}
