//
//  AboutAppPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/19.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class AboutAppPresenterTests: XCTestCase {

    private let vc = AboutAppViewControllerProtocolMock()
    private let settings = JobOrder_Domain.SettingsUseCaseProtocolMock()
    private lazy var presenter = AboutAppPresenter(useCase: settings,
                                                   vc: vc)
    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_thingName() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(presenter.thingName, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            settings.thingName = param
            XCTAssertEqual(presenter.thingName, param, "正しい値が取得できていない: \(param)")
        }
    }
}
