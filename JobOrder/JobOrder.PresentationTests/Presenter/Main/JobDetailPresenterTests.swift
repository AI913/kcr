//
//  JobDetailPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class JobDetailPresenterTests: XCTestCase {

    private let stub = PresentationTestsStub()
    private let vc = JobDetailViewControllerProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let viewData = MainViewData.Job()
    private lazy var presenter = JobDetailPresenter(useCase: data,
                                                    vc: vc,
                                                    viewData: viewData)
    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_displayName() {
        let param = "test1"

        XCTContext.runActivity(named: "Dataが未設定の場合") { _ in
            presenter.data.id = nil
            data.jobs = stub.jobs
            XCTAssertNil(presenter.displayName, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Jobsが未設定の場合") { _ in
            presenter.data.id = param
            data.jobs = nil
            XCTAssertNil(presenter.displayName, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Jobが存在する場合") { _ in
            presenter.data.id = param
            data.jobs = stub.jobs
            XCTAssertEqual(presenter.displayName, stub.job1().name, "正しい値が取得できていない: \(stub.job1())")
        }
    }

    func test_overview() {
        let param = "test1"

        XCTContext.runActivity(named: "Dataが未設定の場合") { _ in
            presenter.data.id = nil
            data.jobs = stub.jobs
            XCTAssertNil(presenter.overview, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Jobsが未設定の場合") { _ in
            presenter.data.id = param
            data.jobs = nil
            XCTAssertNil(presenter.overview, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Jobが存在する場合") { _ in
            presenter.data.id = param
            data.jobs = stub.jobs
            XCTAssertEqual(presenter.overview, stub.job1().overview, "正しい値が取得できていない: \(stub.job1())")
        }
    }

    func test_remarks() {
        let param = "test1"

        XCTContext.runActivity(named: "Dataが未設定の場合") { _ in
            presenter.data.id = nil
            data.jobs = stub.jobs
            XCTAssertNil(presenter.remarks, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Jobsが未設定の場合") { _ in
            presenter.data.id = param
            data.jobs = nil
            XCTAssertNil(presenter.remarks, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Jobが存在する場合") { _ in
            presenter.data.id = param
            data.jobs = stub.jobs
            XCTAssertEqual(presenter.remarks, stub.job1().remarks, "正しい値が取得できていない: \(stub.job1())")
        }
    }

    func test_tapOrderButton() {
        presenter.tapOrderButton()
        XCTAssertEqual(vc.launchOrderEntryCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

}
