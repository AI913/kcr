//
//  TaskDetailViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by admin on 2020/11/11.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class TaskDetailViewControllerTests: XCTestCase {

    private let mock = TaskDetailTaskInformationPresenterProtocolMock()
    private let vc = StoryboardScene.TaskDetail.taskDetail.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.cancelTaskButton, "cancelTaskButtonがOutletに接続されていない")
        XCTAssertNotNil(vc.jobValueLabel, "jobValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.createdAtValueLabel, "createdAtValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.lastUpdatedAtValueLabel, "lastUpdatedAtValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.robotsValueLabel, "robotsValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.startedAtValueLabel, "startedAtValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.exitedAtValueLabel, "exitedAtValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.durationValueLabel, "durationValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.statusImageView, "statusImageViewがOutletに接続されていない")
        XCTAssertNotNil(vc.statusValueLabel, "statusValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.pieChartView, "pieChartViewがOutletに接続されていない")
        XCTAssertNotNil(vc.CircularProgress, "CircularProgressがOutletに接続されていない")
    }

    func test_actions() throws {
        let cancelTaskButton = try XCTUnwrap(vc.cancelTaskButton, "Unwrap失敗")
        XCTAssertNoThrow(cancelTaskButton.sendActions(for: .touchUpInside), "タップで例外発生: \(cancelTaskButton)")
    }

    func test_inject() {
        let param1 = "TaskTest"
        let param2 = "RobotTest"
        vc.inject(jobId: param1, robotId: param2)
        XCTAssertEqual(vc.taskId, param1, "正常に値が設定されていない")
        XCTAssertEqual(vc.robotId, param2, "正常に値が設定されていない")
    }

    func test_viewWillAppear() {
        let param1 = "TaskTest"
        let param2 = "RobotTest"
        vc.inject(jobId: param1, robotId: param2)
        vc.presenter = mock
        vc.viewWillAppear(true)

        print(mock.viewWillAppearCallCount)
        XCTAssertEqual(mock.viewWillAppearCallCount, 1, "Presenterのメソッドが呼ばれない")
    }

    func test_tapOrderButton() {
        vc.cancelTaskButton.sendActions(for: .touchUpInside)
        //TODO:未実装
    }

    func test_showErrorAlert() {
        vc.showErrorAlert(NSError(domain: "Error", code: -1, userInfo: nil))
        XCTAssertTrue(vc.presentedViewController is UIAlertController, "アラートが表示されない")
    }
}
