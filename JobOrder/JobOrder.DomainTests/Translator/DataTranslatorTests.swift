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
import SwiftCheck

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
        let model: DataManageModel.Input.Task? = nil
        let data = translator.toData(model: model)

        XCTAssertNil(data, "値を取得できてはいけない")
    }

    func test_toDataWithJobInput() {
        let translator = DataTranslator()

        property("DataManageModel.Input.JobをJobOrder_API.JobAPIEntity.Input.Dataに変換した場合") <- forAll { (model: DataManageModel.Input.Job) in
            guard let data = translator.toData(model: model) else { return false }
            return model == data
        }
    }

    func test_toDataWithoutJobInput() {
        let translator = DataTranslator()
        let model: DataManageModel.Input.Job? = nil
        let data = translator.toData(model: model)

        XCTAssertNil(data, "値を取得できてはいけない")
    }
}

extension DataManageModel.Input.Job {
    static func == (lhs: DataManageModel.Input.Job, rhs: JobOrder_API.JobAPIEntity.Input.Data) -> Bool {
        let isEqualRequirements = { (lhs: [DataManageModel.Input.Job.Requirement]?, rhs: [JobOrder_API.JobAPIEntity.Input.Data.Requirement]?) -> Bool in
            switch (lhs, rhs) {
            case let (lhs?, rhs?):
                return lhs.elementsEqual(rhs, by: { $0.type == $1.type && $0.subtype == $1.subtype && $0.id == $1.id && $0.versionId == $1.versionId })
            case (nil, nil): return true
            default: return false
            }
        }
        let isEqualParameter = { (lhs: DataManageModel.Input.Job.Action.Parameter?, rhs: JobOrder_API.JobAPIEntity.Input.Data.Action.Parameter?) -> Bool in
            switch (lhs, rhs) {
            case let (lhs?, rhs?):
                return lhs.aiLibraryId == rhs.aiLibraryId && lhs.aiLibraryObjectId == rhs.aiLibraryObjectId
            case (nil, nil): return true
            default: return false
            }
        }
        return lhs.name == rhs.name &&
            lhs.actions.elementsEqual(rhs.actions, by: {
                $0.index == $1.index &&
                    $0.actionLibraryId == $1.actionLibraryId &&
                    isEqualParameter($0.parameter, $1.parameter) &&
                    $0.catch == $1.catch &&
                    $0.then == $1.then
            }) &&
            lhs.entryPoint == rhs.entryPoint &&
            lhs.overview == rhs.overview &&
            lhs.remarks == rhs.remarks &&
            isEqualRequirements(lhs.requirements, rhs.requirements)
    }
}
