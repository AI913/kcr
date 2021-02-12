//
//  DataTranslator.swift
//  JobOrder.Domain
//
//  Created by Yu Suzuki on 2020/04/10.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import JobOrder_API
import JobOrder_Data

struct DataTranslator {

    /// JobAPIから取得した結果をDBへ保存する構造体に変換する
    /// - Parameter entity: APIから取得したデータ
    /// - Returns: DBへ保存するデータ
    func toData(jobEntity: JobOrder_API.JobAPIEntity.Data?) -> JobOrder_Data.JobEntity? {
        guard let entity = jobEntity else { return nil }

        var actions = [JobOrder_Data.JobAction]()
        _ = entity.actions.map {
            let action = JobOrder_Data.JobAction()
            action.index = $0.index
            action.id = $0.id
            // action.parameter = $0.parameter
            action._catch = $0._catch
            action.then = $0.then
            actions.append(action)
        }

        let requirements = [JobOrder_Data.JobRequirement]()
        //        _ = entity.requirements.map {
        //            let requirement = JobOrder_Data.Requirement()
        //            requirements.append(requirement)
        //        }

        let job = JobOrder_Data.JobEntity(actions: actions, requirements: requirements)
        job.id = entity.id
        job.name = entity.name
        job.entryPoint = entity.entryPoint
        job.overview = entity.overview
        job.remarks = entity.remarks
        job.version = entity.version
        job.createTime = entity.createTime
        job.creator = entity.creator
        job.updateTime = entity.updateTime
        job.updator = entity.updator
        return job
    }

    /// RobotAPIから取得した結果をDBへ保存する構造体に変換する
    /// - Parameter entity: APIから取得したデータ
    /// - Returns: DBへ保存するデータ
    func toData(robotEntity: JobOrder_API.RobotAPIEntity.Data?, state: String?) -> JobOrder_Data.RobotEntity? {
        guard let entity = robotEntity else { return nil }

        let robot = JobOrder_Data.RobotEntity()
        robot.id = entity.id
        robot.name = entity.name
        robot.type = entity.type
        robot.locale = entity.locale
        robot.isSimulator = entity.isSimulator
        robot.maker = entity.maker
        robot.model = entity.model
        robot.modelClass = entity.modelClass
        robot.serial = entity.serial
        robot.overview = entity.overview
        robot.remarks = entity.remarks
        robot.version = entity.version
        robot.createTime = entity.createTime
        robot.creator = entity.creator
        robot.updateTime = entity.updateTime
        robot.updator = entity.updator
        robot.thingName = entity.awsKey?.thingName
        robot.thingArn = entity.awsKey?.thingArn
        // APIから取得しない値は指定データをコピーする
        robot.state = state
        return robot
    }

    /// ActionLibraryAPIから取得した結果をDBへ保存する構造体に変換する
    /// - Parameter entity: APIから取得したデータ
    /// - Returns: DBへ保存するデータ
    func toData(actionLibraryEntity: JobOrder_API.ActionLibraryAPIEntity.Data?) -> JobOrder_Data.ActionLibraryEntity? {
        guard let entity = actionLibraryEntity else { return nil }

        let requirements = [JobOrder_Data.ActionLibraryRequirement]()

        let actionLibrary = JobOrder_Data.ActionLibraryEntity(requirements: requirements)
        actionLibrary.id = entity.id
        actionLibrary.name = entity.name
        actionLibrary.imagePath = entity.imagePath
        actionLibrary.overview = entity.overview
        actionLibrary.remarks = entity.remarks
        actionLibrary.version = entity.version
        actionLibrary.createTime = entity.createTime
        actionLibrary.creator = entity.creator
        actionLibrary.updateTime = entity.updateTime
        actionLibrary.updator = entity.updator
        return actionLibrary
    }

    /// AILibraryAPIから取得した結果をDBへ保存する構造体に変換する
    /// - Parameter entity: APIから取得したデータ
    /// - Returns: DBへ保存するデータ
    func toData(aiLibraryEntity: JobOrder_API.AILibraryAPIEntity.Data?) -> JobOrder_Data.AILibraryEntity? {
        guard let entity = aiLibraryEntity else { return nil }

        let requirements = [JobOrder_Data.AILibraryRequirement]()

        let aiLibrary = JobOrder_Data.AILibraryEntity(requirements: requirements)
        aiLibrary.id = entity.id
        aiLibrary.name = entity.name
        aiLibrary.type = entity.type
        aiLibrary.imagePath = entity.imagePath
        aiLibrary.overview = entity.overview
        aiLibrary.remarks = entity.remarks
        aiLibrary.version = entity.version
        aiLibrary.createTime = entity.createTime
        aiLibrary.creator = entity.creator
        aiLibrary.updateTime = entity.updateTime
        aiLibrary.updator = entity.updator
        return aiLibrary
    }

    func toData(model: DataManageModel.Input.Task?) -> JobOrder_API.TaskAPIEntity.Input.Data? {
        guard let model = model else { return nil }
        return JobOrder_API.TaskAPIEntity.Input.Data(jobId: model.jobId,
                                                     robotIds: model.robotIds,
                                                     start: TaskAPIEntity.Start(condition: model.start.condition),
                                                     exit: TaskAPIEntity.Exit(condition: model.exit.condition, option: TaskAPIEntity.Exit.Option(numberOfRuns: model.exit.option.numberOfRuns ?? 0)))
    }

    func toData(model: DataManageModel.Input.Job?) -> JobOrder_API.JobAPIEntity.Input.Data? {
        guard let model = model else { return nil }

        let parameterTranslator = { (parameter: DataManageModel.Input.Job.Action.Parameter?) -> JobOrder_API.JobAPIEntity.Input.Data.Action.Parameter? in
            guard let parameter = parameter else { return nil }
            return JobOrder_API.JobAPIEntity.Input.Data.Action.Parameter(aiLibraryId: parameter.aiLibraryId,
                                                                         aiLibraryObjectId: parameter.aiLibraryObjectId)
        }

        let actionTranslator = { (actions: [DataManageModel.Input.Job.Action]) -> [JobOrder_API.JobAPIEntity.Input.Data.Action] in
            actions.map { JobOrder_API.JobAPIEntity.Input.Data.Action(index: $0.index,
                                                                      actionLibraryId: $0.actionLibraryId,
                                                                      parameter: parameterTranslator($0.parameter),
                                                                      catch: $0.catch,
                                                                      then: $0.then) }
        }

        let requirementTranslator = { (requirements: [DataManageModel.Input.Job.Requirement]?) -> [JobOrder_API.JobAPIEntity.Input.Data.Requirement]? in
            guard let requirements = requirements else { return nil }
            return requirements.map { JobOrder_API.JobAPIEntity.Input.Data.Requirement(type: $0.type,
                                                                                       subtype: $0.subtype,
                                                                                       id: $0.id,
                                                                                       versionId: $0.versionId) }
        }

        return JobOrder_API.JobAPIEntity.Input.Data(name: model.name,
                                                    actions: actionTranslator(model.actions),
                                                    entryPoint: model.entryPoint,
                                                    overview: model.overview,
                                                    remarks: model.remarks,
                                                    requirements: requirementTranslator(model.requirements))
    }

}
