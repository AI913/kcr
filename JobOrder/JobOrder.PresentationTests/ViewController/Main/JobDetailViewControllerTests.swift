//
//  JobDetailViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class JobDetailViewControllerTests: XCTestCase {

    private let data = MainViewData.Job()
    private lazy var mock = JobDetailPresenterProtocolMock(data: data)
    private let vc = StoryboardScene.Main.jobDetail.instantiate()

    override func setUpWithError() throws {
        vc.presenter = mock

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.displayNameLabel, "displayNameLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.overviewLabel, "overviewLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.orderButton, "orderButtonがOutletに接続されていない")
        XCTAssertNotNil(vc.segmentedControl, "segmentedControlがOutletに接続されていない")
        XCTAssertNotNil(vc.containerView, "containerViewがOutletに接続されていない")
        XCTAssertNotNil(vc.containerViewHeight, "containerViewHeightがOutletに接続されていない")
    }

    func test_actions() throws {
        let orderButton = try XCTUnwrap(vc.orderButton, "Unwrap失敗")
        XCTAssertNoThrow(orderButton.sendActions(for: .touchUpInside), "タップで例外発生: \(orderButton)")
    }

    func test_inject() {
        let param = "test"
        vc.inject(viewData: MainViewData.Job(id: param))
        XCTAssertEqual(vc.viewData.id, param, "正常に値が設定されていない")
    }

    func test_viewWillAppear() throws {
        let displayNameLabel = try XCTUnwrap(vc.displayNameLabel, "Unwrap失敗")
        let overviewLabel = try XCTUnwrap(vc.overviewLabel, "Unwrap失敗")
        let param = "test"

        XCTContext.runActivity(named: "Job未選択の場合") { _ in
            mock.data = MainViewData.Job(id: nil)
            mock.displayName = param
            mock.overview = param
            mock.remarks = param
            vc.viewWillAppear(true)
            XCTAssertNotEqual(displayNameLabel.text, param, "テキストを設定してはいけない: \(displayNameLabel)")
            XCTAssertNotEqual(overviewLabel.text, param, "テキストを設定してはいけない: \(overviewLabel)")
        }

        XCTContext.runActivity(named: "Job選択済みの場合") { _ in
            mock.data = MainViewData.Job(id: param)
            mock.displayName = param
            mock.overview = param
            mock.remarks = param
            vc.viewWillAppear(true)
            XCTAssertEqual(displayNameLabel.text, param, "テキストが設定されていない: \(displayNameLabel)")
            XCTAssertEqual(overviewLabel.text, param, "テキストが設定されていない: \(overviewLabel)")
        }
    }

    func test_tapOrderButton() {
        vc.orderButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(mock.tapOrderButtonCallCount, 1, "Presenterのメソッドが呼ばれない")
    }

}
