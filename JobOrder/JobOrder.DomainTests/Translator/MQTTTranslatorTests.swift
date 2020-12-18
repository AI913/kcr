//
//  MQTTTranslatorTests.swift
//  JobOrder.DomainTests
//
//  Created by Yu Suzuki on 2020/08/03.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Domain
@testable import JobOrder_API

class MQTTTranslatorTests: XCTestCase {

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_toData() {
        let translator = MQTTTranslator()
        var model = MQTTModel.Input.CreateJob()

        model.jobId = "jobId"
        model.robotIds = ["robotIds"]
        model.startCondition = JobOrder_Domain.MQTTModel.Input.CreateJob.StartCondition(key: "immediately")
        model.exitCondition = JobOrder_Domain.MQTTModel.Input.CreateJob.ExitCondition(key: "specifiedNumberOfTimes")
        model.numberOfRuns = 1
        model.remarks = "remarks"
        let data = translator.toData(model: model)
        XCTAssertEqual(data?.jobDataId, "jobId", "値が取得できていない")
        XCTAssertEqual(data?.startCondition, "immediately", "値が取得できていない")
        XCTAssertEqual(data?.exitCondition, "specifiedNumberOfTimes", "値が取得できていない")
        XCTAssertEqual(data?.numberOfRuns, 1, "値が取得できていない")
    }

    func test_toDataWithoutModel() {
        let translator = MQTTTranslator()
        let data = translator.toData(model: nil)

        XCTAssertNil(data, "値を取得できてはいけない")
    }
}
