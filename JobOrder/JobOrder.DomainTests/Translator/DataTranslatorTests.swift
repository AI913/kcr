//
//  DataTranslatorTests.swift
//  JobOrder.DomainTests
//
//  Created by Yu Suzuki on 2020/08/03.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Domain
@testable import JobOrder_API

class DataTranslatorTests: XCTestCase {

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_toDataWithJob() {
        let translator = DataTranslator()
        let entity = JobAPIEntity.Data.arbitrary.generate
        let data = translator.toData(jobEntity: entity)

        XCTAssertEqual(data?.id, entity.id, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.name, entity.name, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.entryPoint, entity.entryPoint, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.overview, entity.overview, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.remarks, entity.remarks, "値が取得できていない: \(entity)")
        // XCTAssertEqual(data?.requirements, entity.requirements, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.version, entity.version, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.createTime, entity.createTime, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.creator, entity.creator, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.updateTime, entity.updateTime, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.updator, entity.updator, "値が取得できていない: \(entity)")
    }

    func test_toDataWithoutJob() {
        let translator = DataTranslator()
        let data = translator.toData(jobEntity: nil)

        XCTAssertNil(data, "値を取得できてはいけない")
    }

    func test_toDataWithRobot() {
        let translator = DataTranslator()
        let entity = RobotAPIEntity.Data.arbitrary.generate
        let data = translator.toData(robotEntity: entity, state: "state")

        XCTAssertEqual(data?.id, entity.id, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.name, entity.name, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.type, entity.type, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.locale, entity.locale, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.isSimulator, entity.isSimulator, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.maker, entity.maker, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.model, entity.model, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.modelClass, entity.modelClass, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.serial, entity.serial, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.overview, entity.overview, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.remarks, entity.remarks, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.version, entity.version, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.createTime, entity.createTime, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.creator, entity.creator, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.updateTime, entity.updateTime, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.updator, entity.updator, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.thingName, entity.awsKey?.thingName, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.thingArn, entity.awsKey?.thingArn, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.state, "state", "値が取得できていない: \(entity)")
    }

    func test_toDataWithoutRobot() {
        let translator = DataTranslator()
        let data = translator.toData(robotEntity: nil, state: "state")

        XCTAssertNil(data, "値を取得できてはいけない")
    }

    func test_toDataWithActionLibrary() {
        let translator = DataTranslator()
        let entity = ActionLibraryAPIEntity.Data.arbitrary.generate
        let data = translator.toData(actionLibraryEntity: entity)

        XCTAssertEqual(data?.id, entity.id, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.name, entity.name, "値が取得できていない: \(entity)")
        // XCTAssertEqual(data?.requirements, entity.requirements, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.imagePath, entity.imagePath, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.overview, entity.overview, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.remarks, entity.remarks, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.version, entity.version, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.createTime, entity.createTime, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.creator, entity.creator, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.updateTime, entity.updateTime, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.updator, entity.updator, "値が取得できていない: \(entity)")
    }

    func test_toDataWithoutActionLibrary() {
        let translator = DataTranslator()
        let data = translator.toData(actionLibraryEntity: nil)

        XCTAssertNil(data, "値を取得できてはいけない")
    }

    func test_toDataWithAILibrary() {
        let translator = DataTranslator()
        let entity = AILibraryAPIEntity.Data.arbitrary.generate
        let data = translator.toData(aiLibraryEntity: entity)

        XCTAssertEqual(data?.id, entity.id, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.name, entity.name, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.type, entity.type, "値が取得できていない: \(entity)")
        // XCTAssertEqual(data?.requirements, entity.requirements, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.imagePath, entity.imagePath, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.overview, entity.overview, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.remarks, entity.remarks, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.version, entity.version, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.createTime, entity.createTime, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.creator, entity.creator, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.updateTime, entity.updateTime, "値が取得できていない: \(entity)")
        XCTAssertEqual(data?.updator, entity.updator, "値が取得できていない: \(entity)")
    }

    func test_toDataWithoutAILibrary() {
        let translator = DataTranslator()
        let data = translator.toData(aiLibraryEntity: nil)

        XCTAssertNil(data, "値を取得できてはいけない")
    }

    func test_toDataWithTaskInput() {
        let translator = DataTranslator()
        let model = DataManageModel.Input.Task()
        guard let data = translator.toData(model: model) else {
            XCTFail("値が取得できていない: \(model)")
            return
        }

        XCTAssertEqual(model.jobId, data.jobId, "値が取得できていない: \(model)")
        XCTAssertEqual(model.robotIds, data.robotIds, "値が取得できていない: \(model)")
        XCTAssertEqual(model.start, JobOrder_Domain.DataManageModel.Input.Task.Start(data.start), "値が取得できていない: \(model)")
        XCTAssertEqual(model.exit, JobOrder_Domain.DataManageModel.Input.Task.Exit(data.exit), "値が取得できていない: \(model)")
    }

    func test_toDataWithoutTaskInput() {
        let translator = DataTranslator()
        let data = translator.toData(model: nil)

        XCTAssertNil(data, "値を取得できてはいけない")
    }
}
