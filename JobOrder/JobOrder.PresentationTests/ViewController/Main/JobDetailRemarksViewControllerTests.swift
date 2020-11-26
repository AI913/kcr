//
//  JobDetailRemarksViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by 藤井一暢 on 2020/11/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class JobDetailRemarksViewControllerTests: XCTestCase {

    private let data = MainViewData.Job()
    private lazy var mock = JobDetailRemarksPresenterProtocolMock(data: data)
    private let vc = StoryboardScene.Main.jobDetailRemarks.instantiate()

    override func setUpWithError() throws {
        vc.presenter = mock
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.remarksValueLabel, "remarksValueLabelがOutletに接続されていない")
    }

    func test_actions() throws {
    }

    func test_inject() {
        let param = "test"
        vc.inject(viewData: MainViewData.Job(id: param))
        XCTAssertEqual(vc.viewData.id, param, "正常に値が設定されていない")
    }

    func test_set() {
        let param: CGFloat = 1.0
        vc.set(height: param)
        XCTAssertEqual(vc.initialHeight, param, "正常に呼ばれること")
    }

}
