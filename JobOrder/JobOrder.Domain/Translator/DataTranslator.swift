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
            //action.parameter = $0.parameter
            action._catch = $0._catch
            action.then = $0.then
            actions.append(action)
        }

        let job = JobOrder_Data.JobEntity(actions: actions)
        job.id = entity.id
        job.name = entity.name
        job.entryPoint = entity.entryPoint
        job.overview = entity.overview
        job.remarks = entity.remarks
        job.requirements = entity.requirements
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

        let actionLibrary = JobOrder_Data.ActionLibraryEntity()
        actionLibrary.id = entity.id
        actionLibrary.name = entity.name
        actionLibrary.requirements = entity.requirements
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

        let aiLibrary = JobOrder_Data.AILibraryEntity()
        aiLibrary.id = entity.id
        aiLibrary.name = entity.name
        aiLibrary.type = entity.type
        aiLibrary.requirements = entity.requirements
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
}
