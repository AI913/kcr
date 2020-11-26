//
//  JobDetailFlowPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by 藤井一暢 on 2020/11/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class JobDetailFlowPresenterTests: XCTestCase {

    private let vc = JobDetailFlowViewControllerProtocolMock()
    private let viewData = MainViewData.Job()
    private lazy var presenter = JobDetailFlowPresenter(vc: vc, viewData: viewData)

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_viewWillAppear() {
        presenter.viewWillAppear()
    }

}
