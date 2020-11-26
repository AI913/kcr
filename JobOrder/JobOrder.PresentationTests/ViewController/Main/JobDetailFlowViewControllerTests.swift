//
//  JobDetailFlowViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by 藤井一暢 on 2020/11/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class JobDetailFlowViewControllerTests: XCTestCase {

    private let mock = JobDetailFlowPresenterProtocolMock()
    private let vc = StoryboardScene.Main.jobDetailFlow.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
    }

    func test_actions() throws {
    }

    func test_inject() {
        let param = "test"
        vc.inject(viewData: MainViewData.Job(id: param))
        XCTAssertEqual(vc.viewData.id, param, "正常に値が設定されていない")
    }

    func test_viewWillAppear() {
        vc.viewWillAppear(true)
        XCTAssertEqual(mock.viewWillAppearCallCount, 1, "Presenterのメソッドが呼ばれない")
    }

    func test_set() {
        let param: CGFloat = 1.0
        vc.set(height: param)
        XCTAssertEqual(vc.initialHeight, param, "正常に呼ばれること")
    }

}
