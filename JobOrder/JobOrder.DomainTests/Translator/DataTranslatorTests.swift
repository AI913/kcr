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
@testable import JobOrder_Data
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

    func test_toEntityWithTaskInput() {
        let translator = DataTranslator()
        let model = DataManageModel.Input.Task.arbitrary.suchThat({ $0.exit.option.numberOfRuns != nil }).generate
        guard let data = translator.toEntity(taskModel: model) else {
            XCTFail("値が取得できていない: \(model)")
            return
        }

        XCTAssertEqual(model.jobId, data.jobId, "値が取得できていない: \(model)")
        XCTAssertEqual(model.robotIds, data.robotIds, "値が取得できていない: \(model)")
        XCTAssertEqual(model.start, JobOrder_Domain.DataManageModel.Input.Task.Start(condition: data.start.condition), "値が取得できていない: \(model)")
        XCTAssertEqual(model.exit, JobOrder_Domain.DataManageModel.Input.Task.Exit(condition: data.exit.condition, option: JobOrder_Domain.DataManageModel.Input.Task.Exit.Option(numberOfRuns: data.exit.option.numberOfRuns)), "値が取得できていない: \(model)")
    }

    func test_toEntityWithoutTaskInput() {
        let translator = DataTranslator()
        let data = translator.toEntity(taskModel: nil)

        XCTAssertNil(data, "値を取得できてはいけない")
    }

    func test_toEntityWithJobInput() {
        let translator = DataTranslator()

        property("DataManageModel.Input.JobをJobOrder_API.JobAPIEntity.Input.Dataに変換した場合") <- forAll { (model: DataManageModel.Input.Job) in
            guard let data = translator.toEntity(jobModel: model) else { return false }
            return model == data
        }
    }

    func test_toEntityWithoutJobInput() {
        let translator = DataTranslator()
        let data = translator.toEntity(jobModel: nil)

        XCTAssertNil(data, "値を取得できてはいけない")
    }

    func test_toModelSyncData() throws {
        let translator = DataTranslator()
        let isEqual = { (model: DataManageModel.Output.SyncData, data: ([JobOrder_Data.JobEntity]?, [JobOrder_Data.RobotEntity]?, [JobOrder_Data.ActionLibraryEntity]?, [JobOrder_Data.AILibraryEntity]?)) -> Bool in
            if !isEqualArray(model.jobs, data.0, isEqual: { $0 == $1 }) { return false }
            if !isEqualArray(model.robots, data.1, isEqual: { $0 == $1 }) { return false }
            if !isEqualArray(model.actionLibraries, data.2, isEqual: { $0 == $1 }) { return false }
            if !isEqualArray(model.aiLibraries, data.3, isEqual: { $0 == $1 }) { return false }
            return true
        }

        let jobEntities = JobOrder_Data.JobEntity.arbitrary.sample
        let robotEntities = JobOrder_Data.RobotEntity.arbitrary.sample
        let actionLibraryEntities = JobOrder_Data.ActionLibraryEntity.arbitrary.sample
        let aiLibraryEntities = JobOrder_Data.AILibraryEntity.arbitrary.sample

        let model = translator.toModel(jobEntities: jobEntities, robotEntities: robotEntities, actionLibraryEntities: actionLibraryEntities, aiLibraryEntities: aiLibraryEntities)
        XCTAssertTrue(isEqual(model, (jobEntities, robotEntities, actionLibraryEntities, aiLibraryEntities)), "正しい値が取得できない")
    }

    func test_toModelJobEntity() throws {
        let translator = DataTranslator()
        property("JobOrder_API.JobAPIEntity.Dataをドメインモデルに変換した場合") <- forAll { (data: JobOrder_API.JobAPIEntity.Data) in
            let model = translator.toModel(data)
            return model == data
        }
    }

    func test_toModelJobData() throws {
        let translator = DataTranslator()
        property("JobOrder_Data.JobEntityをドメインモデルに変換した場合") <- forAll { (data: JobOrder_Data.JobEntity) in
            let model = translator.toModel(data)
            return model == data
        }
    }

    func test_toModelRobotData() throws {
        let translator = DataTranslator()
        property("JobOrder_API.RobotAPIEntity.Dataをドメインモデルに変換した場合") <- forAll { (data: JobOrder_API.RobotAPIEntity.Data) in
            let model = translator.toModel(data)
            return model == data
        }
    }

    func test_toModelRobotEntity() throws {
        let translator = DataTranslator()
        property("JobOrder_Data.RobotEntityをドメインモデルに変換した場合") <- forAll { (data: JobOrder_Data.RobotEntity) in
            let model = translator.toModel(data)
            return model == data
        }
    }

    func test_toModelCommandData() throws {
        let translator = DataTranslator()
        property("JobOrder_API.CommandEntity.Dataをドメインモデルに変換した場合") <- forAll { (data: JobOrder_API.CommandEntity.Data) in
            let model = translator.toModel(data)
            return model == data
        }
    }

    func test_toModelTaskEntity() throws {
        let translator = DataTranslator()
        property("JobOrder_API.TaskAPIEntity.Dataをドメインモデルに変換した場合") <- forAll { (data: JobOrder_API.TaskAPIEntity.Data) in
            let model = translator.toModel(data)
            return model == data
        }
    }

    func test_toModelSwconfAssetEntity() throws {
        let translator = DataTranslator()
        let isEqual = {(model: DataManageModel.Output.System, data: (robotSwconf: JobOrder_API.RobotAPIEntity.Swconf, robotAssets: [JobOrder_API.RobotAPIEntity.Asset])) -> Bool in
            if !isEqualElement(model.softwareConfiguration, data.0, isEqual: { $0 == $1 }) { return false }
            if !isEqualArray(model.hardwareConfigurations, data.1, isEqual: { $0 == $1 }) { return false }
            return true
        }

        let robotSwconf = JobOrder_API.RobotAPIEntity.Swconf.arbitrary.generate
        let robotAssets = JobOrder_API.RobotAPIEntity.Asset.arbitrary.sample

        let model = translator.toModel(robotSwconf: robotSwconf, robotAssets: robotAssets)
        XCTAssertTrue(isEqual(model, (robotSwconf, robotAssets)), "正しい値が取得できない")
    }

    func test_toModelActionLibraryData() throws {
        let translator = DataTranslator()
        property("JobOrder_Data.ActionLibraryEntityをドメインモデルに変換した場合") <- forAll { (data: JobOrder_Data.ActionLibraryEntity) in
            let model = translator.toModel(data)
            return model == data
        }
    }

    func test_toModelAILibraryData() throws {
        let translator = DataTranslator()
        property("JobOrder_Data.AILibraryEntityをドメインモデルに変換した場合") <- forAll { (data: JobOrder_Data.AILibraryEntity) in
            let model = translator.toModel(data)
            return model == data
        }
    }

    func test_toModelInputTaskEntity() throws {
        let translator = DataTranslator()
        property("JobOrder_API.TaskAPIEntity.Input.Dataをドメインモデルに変換した場合") <- forAll { (data: JobOrder_API.TaskAPIEntity.Input.Data) in
            let model = translator.toModel(data)
            return model == data
        }
    }

    func test_toModelInputTask() throws {
        let translator = DataTranslator()
        property("JobOrder_API.TaskAPIEntity.Input.Dataをドメインモデルに変換した場合") <- forAll { (jobId: String, robotIds: [String], startCondition: String, exitCondition: String, numberOfRuns: Int) in
            let model = translator.toModel(jobId: jobId,
                                           robotIds: robotIds,
                                           startCondition: startCondition,
                                           exitCondition: exitCondition,
                                           numberOfRuns: numberOfRuns)
            return model.jobId == jobId &&
                model.robotIds == robotIds &&
                model.start == DataManageModel.Input.Task.Start(condition: startCondition) &&
                model.exit == DataManageModel.Input.Task.Exit(
                    condition: exitCondition,
                    option: DataManageModel.Input.Task.Exit.Option(numberOfRuns: numberOfRuns))
        }
    }
}
