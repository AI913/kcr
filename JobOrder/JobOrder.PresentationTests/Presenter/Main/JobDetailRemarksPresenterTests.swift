//
//  JobDetailRemarksPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by 藤井一暢 on 2020/11/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class JobDetailRemarksPresenterTests: XCTestCase {

    private let vc = JobDetailRemarksViewControllerProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let viewData = MainViewData.Job()
    private lazy var presenter = JobDetailRemarksPresenter(dataUseCase: data, vc: vc, viewData: viewData)

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_remarks() {
        let jobs = DataManageModel.Output.Job.arbitrary.sample
        let obj = jobs.randomElement()!
        let param = obj.id

        XCTContext.runActivity(named: "Dataが未設定の場合") { _ in
            presenter.data.id = nil
            data.jobs = jobs
            XCTAssertNil(presenter.remarks, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Jobsが未設定の場合") { _ in
            presenter.data.id = param
            data.jobs = nil
            XCTAssertNil(presenter.remarks, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Jobsが存在する場合") { _ in
            presenter.data.id = param
            data.jobs = jobs
            XCTAssertEqual(presenter.remarks, obj.remarks, "正しい値が取得できていない: \(obj)")
        }
    }
}
