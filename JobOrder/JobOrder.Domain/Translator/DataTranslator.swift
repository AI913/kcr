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

public struct DataTranslator {
    public init() {}

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

    /// TaskドメインモデルをAPIエンティティに変換する
    /// - Parameter taskModel: Taskドメインモデル
    /// - Returns: Task APIエンティティ
    func toEntity(taskModel: DataManageModel.Input.Task?) -> JobOrder_API.TaskAPIEntity.Input.Data? {
        guard let model = taskModel else { return nil }
        return JobOrder_API.TaskAPIEntity.Input.Data(jobId: model.jobId,
                                                     robotIds: model.robotIds,
                                                     start: TaskAPIEntity.Start(condition: model.start.condition),
                                                     exit: TaskAPIEntity.Exit(condition: model.exit.condition, option: TaskAPIEntity.Exit.Option(numberOfRuns: model.exit.option.numberOfRuns ?? 0)))
    }

    /// JobドメインモデルをAPIエンティティに変換する
    /// - Parameter jobModel: Jobドメインモデル
    /// - Returns: Job APIエンティティ
    func toEntity(jobModel: DataManageModel.Input.Job?) -> JobOrder_API.JobAPIEntity.Input.Data? {
        guard let model = jobModel else { return nil }

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

    /// 各データを元にSyncドメインモデルを構築する
    /// - Parameters:
    ///   - jobEntities: Jobデータ
    ///   - robotEntities: Robotデータ
    ///   - actionLibraryEntities: actionLibraryデータ
    ///   - aiLibraryEntities: aiLibraryデータ
    /// - Returns: Syncドメインモデル
    func toModel(jobEntities: [JobOrder_Data.JobEntity]?,
                 robotEntities: [JobOrder_Data.RobotEntity]?,
                 actionLibraryEntities: [JobOrder_Data.ActionLibraryEntity]?,
                 aiLibraryEntities: [JobOrder_Data.AILibraryEntity]?) -> DataManageModel.Output.SyncData {
        return DataManageModel.Output.SyncData(jobs: jobEntities?.map { self.toModel($0) },
                                               robots: robotEntities?.map { self.toModel($0) },
                                               actionLibraries: actionLibraryEntities?.map { self.toModel($0) },
                                               aiLibraries: aiLibraryEntities?.map { self.toModel($0) })
    }

    /// Jobデータをドメインモデルに変換する
    /// - Parameter job: Jobデータ
    /// - Returns: Jobドメインモデル
    func toModel(_ job: JobOrder_Data.JobEntity) -> DataManageModel.Output.Job {
        return DataManageModel.Output.Job(id: job.id,
                                          name: job.name,
                                          actions: job.actionsArray.map { self.toModel($0) },
                                          entryPoint: job.entryPoint,
                                          overview: job.overview,
                                          remarks: job.remarks,
                                          requirements: job.requirementsArray.map { self.toModel($0) },
                                          version: job.version,
                                          createTime: job.createTime,
                                          creator: job.creator,
                                          updateTime: job.updateTime,
                                          updator: job.updator)
    }

    /// JobActionデータをドメインモデルに変換する
    /// - Parameter action: JobActionデータ
    /// - Returns: Job.Actionドメインモデル
    func toModel(_ action: JobOrder_Data.JobAction) -> DataManageModel.Output.Job.Action {
        return DataManageModel.Output.Job.Action(index: action.index,
                                                 id: action.id,
                                                 parameter: nil,	// FIXME: TBD
                                                 _catch: action._catch,
                                                 then: action.then)
    }

    /// JobRequirementデータをドメインモデルに変換する
    /// - Parameter requirement: JobRequirementデータ
    /// - Returns: Job.Requirementドメインモデル
    func toModel(_ requirement: JobOrder_Data.JobRequirement) -> DataManageModel.Output.Job.Requirement {
        return DataManageModel.Output.Job.Requirement()	// FIXME: TBD
    }

    /// Job APIエンティティをドメインモデルに変換する
    /// - Parameter job: Job APIエンティティ
    /// - Returns: Jobドメインモデル
    func toModel(_ job: JobOrder_API.JobAPIEntity.Data) -> DataManageModel.Output.Job {
        return DataManageModel.Output.Job(id: job.id,
                                          name: job.name,
                                          actions: job.actions.map { self.toModel($0) },
                                          entryPoint: job.entryPoint,
                                          overview: job.overview,
                                          remarks: job.remarks,
                                          requirements: self.toModel(job.requirements),
                                          version: job.version,
                                          createTime: job.createTime,
                                          creator: job.creator,
                                          updateTime: job.updateTime,
                                          updator: job.updator)
    }

    /// Job.Action APIエンティティをドメインモデルに変換する
    /// - Parameter action: Job.Action APIエンティティ
    /// - Returns: Job.Actionドメインモデル
    func toModel(_ action: JobOrder_API.JobAPIEntity.Data.Action) -> DataManageModel.Output.Job.Action {
        return DataManageModel.Output.Job.Action(index: action.index,
                                                 id: action.id,
                                                 parameter: nil,	// FIXME: TBD
                                                 _catch: action._catch,
                                                 then: action.then)
    }

    /// Job.Requirement APIエンティティ配列をドメインモデル配列に変換する
    /// - Parameter requirements: Job.Requirement APIエンティティ配列
    /// - Returns: Job.Requirementドメインモデル配列
    func toModel(_ requirements: [JobOrder_API.JobAPIEntity.Data.Requirement]?) -> [DataManageModel.Output.Job.Requirement] {
        guard let requirements = requirements else { return [] }
        return requirements.map { self.toModel($0) }
    }

    /// Job.Requirement APIエンティティをドメインモデルに変換する
    /// - Parameter requirement: Job.Requirement APIエンティティ
    /// - Returns: Job.Requirementドメインモデル
    func toModel(_ requirement: JobOrder_API.JobAPIEntity.Data.Requirement) -> DataManageModel.Output.Job.Requirement {
        return DataManageModel.Output.Job.Requirement()	// FIXME: TBD
    }

    /// Robotデータをドメインモデルに変換する
    /// - Parameter robot: Robotデータ
    /// - Returns: Robotドメインモデル
    func toModel(_ robot: JobOrder_Data.RobotEntity) -> DataManageModel.Output.Robot {
        return DataManageModel.Output.Robot(id: robot.id,
                                            name: robot.name,
                                            type: robot.type,
                                            locale: robot.locale,
                                            isSimulator: robot.isSimulator,
                                            maker: robot.maker,
                                            model: robot.model,
                                            modelClass: robot.modelClass,
                                            serial: robot.serial,
                                            overview: robot.overview,
                                            remarks: robot.remarks,
                                            version: robot.version,
                                            createTime: robot.createTime,
                                            creator: robot.creator,
                                            updateTime: robot.updateTime,
                                            updator: robot.updator,
                                            thingName: robot.thingName,
                                            thingArn: robot.thingArn,
                                            state: DataManageModel.Output.Robot.State.toEnum(robot.state))
    }

    /// Robot APIエンティティをドメインモデルに変換する
    /// - Parameter robot: Robot APIエンティティ
    /// - Returns: Robotドメインモデル
    func toModel(_ robot: JobOrder_API.RobotAPIEntity.Data) -> DataManageModel.Output.Robot {
        return DataManageModel.Output.Robot(id: robot.id,
                                            name: robot.name,
                                            type: robot.type,
                                            locale: robot.locale,
                                            isSimulator: robot.isSimulator,
                                            maker: robot.maker,
                                            model: robot.model,
                                            modelClass: robot.modelClass,
                                            serial: robot.serial,
                                            overview: robot.overview,
                                            remarks: robot.remarks,
                                            version: robot.version,
                                            createTime: robot.createTime,
                                            creator: robot.creator,
                                            updateTime: robot.updateTime,
                                            updator: robot.updator,
                                            thingName: robot.awsKey?.thingName,
                                            thingArn: robot.awsKey?.thingArn,
                                            state: nil)
    }

    /// Command APIエンティティをドメインモデルに変換する
    /// - Parameter command: Command APIエンティティ
    /// - Returns: Commandドメインモデル
    func toModel(_ command: JobOrder_API.CommandEntity.Data) -> DataManageModel.Output.Command {
        return DataManageModel.Output.Command(taskId: command.taskId,
                                              robotId: command.robotId,
                                              started: command.started,
                                              exited: command.exited,
                                              execDuration: command.execDuration,
                                              receivedStartReort: command.receivedStartReort,
                                              receivedExitReort: command.receivedExitReort,
                                              status: command.status,
                                              resultInfo: command.resultInfo,
                                              success: command.success,
                                              fail: command.fail,
                                              error: command.error,
                                              robot: command.robot.map { self.toModel($0.robotInfo) },
                                              dataVersion: command.dataVersion,
                                              createTime: command.createTime,
                                              creator: command.creator,
                                              updateTime: command.updateTime,
                                              updator: command.updator)
    }

    /// Task APIエンティティをドメインモデルに変換する
    /// - Parameter task: Task APIエンティティ
    /// - Returns: Taskドメインモデル
    func toModel(_ task: JobOrder_API.TaskAPIEntity.Data) -> DataManageModel.Output.Task {
        return DataManageModel.Output.Task(id: task.id,
                                           jobId: task.jobId,
                                           robotIds: task.robotIds,
                                           exit: self.toModel(task.exit),
                                           job: self.toModel(task.job),
                                           createTime: task.createTime,
                                           creator: task.creator,
                                           updateTime: task.updateTime,
                                           updator: task.updator)
    }

    /// Task.Exit APIエンティティをドメインモデルに変換する
    /// - Parameter exit: Task.Exit APIエンティティ
    /// - Returns: Task.Exitドメインモデル
    func toModel(_ exit: JobOrder_API.TaskAPIEntity.Exit) -> DataManageModel.Output.Task.Exit {
        return DataManageModel.Output.Task.Exit(option: self.toModel(exit.option))
    }

    /// Task.Exit.Option APIエンティティをドメインモデルに変換する
    /// - Parameter option: Task.Exit.Option APIエンティティ
    /// - Returns: Task.Exit.Optionドメインモデル
    func toModel(_ option: JobOrder_API.TaskAPIEntity.Exit.Option) -> DataManageModel.Output.Task.Exit.Option {
        return DataManageModel.Output.Task.Exit.Option(numberOfRuns: option.numberOfRuns)
    }

    /// Robot Swconf/Asset APIエンティティからドメインモデルを構築する
    /// - Parameters:
    ///   - robotSwconf: Robot.Swconf APIエンティティ
    ///   - robotAssets: Robot.Asset APIエンティティ
    /// - Returns: Systemドメインモデル
    func toModel(robotSwconf: JobOrder_API.RobotAPIEntity.Swconf, robotAssets: [JobOrder_API.RobotAPIEntity.Asset]) -> DataManageModel.Output.System {
        /// ソフトウェア情報
        let distribution = "\(robotSwconf.operatingSystem?.distribution ?? "") \(robotSwconf.operatingSystem?.distributionVersion ?? "")"
        let system = "\(robotSwconf.operatingSystem?.system ?? "") \(robotSwconf.operatingSystem?.systemVersion ?? "")"
        var installs = [DataManageModel.Output.System.SoftwareConfiguration.Installed]()
        if let softwares = robotSwconf.softwares {
            for software in softwares {
                let installed = DataManageModel.Output.System.SoftwareConfiguration.Installed(name: software.displayName ?? "", version: software.displayVersion ?? "")
                installs.append(installed)
            }
        }
        let softwareConfiguration = DataManageModel.Output.System.SoftwareConfiguration(system: system, distribution: distribution, installs: installs)

        /// ハードウェア情報
        var hardwareConfigurations = [DataManageModel.Output.System.HardwareConfiguration]()
        for asset in robotAssets {
            let hardwareConfiguration = DataManageModel.Output.System.HardwareConfiguration(type: asset.type, model: asset.displayModel ?? "", maker: asset.displayMaker ?? "", serialNo: asset.displaySerial ?? "")
            hardwareConfigurations.append(hardwareConfiguration)
        }

        return DataManageModel.Output.System(softwareConfiguration: softwareConfiguration, hardwareConfigurations: hardwareConfigurations)
    }

    /// actionLibraryデータをドメインモデルに変換する
    /// - Parameter actionLibraryEntitiy: ActionLibraryデータ
    /// - Returns: ActionLibraryドメインモデル
    func toModel(_ actionLibraryEntitiy: JobOrder_Data.ActionLibraryEntity) -> DataManageModel.Output.ActionLibrary {
        return DataManageModel.Output.ActionLibrary(id: actionLibraryEntitiy.id,
                                                    name: actionLibraryEntitiy.name,
                                                    requirements: actionLibraryEntitiy.requirementsArray.map { self.toModel($0) },
                                                    imagePath: actionLibraryEntitiy.imagePath,
                                                    overview: actionLibraryEntitiy.overview,
                                                    remarks: actionLibraryEntitiy.remarks,
                                                    version: actionLibraryEntitiy.version,
                                                    createTime: actionLibraryEntitiy.createTime,
                                                    creator: actionLibraryEntitiy.creator,
                                                    updateTime: actionLibraryEntitiy.updateTime,
                                                    updator: actionLibraryEntitiy.updator)
    }

    /// actionLibraryRequirementデータをドメインモデルに変換する
    /// - Parameter requirement: ActionLibraryRequirementデータ
    /// - Returns: ActionLibrary.Requirementドメインモデル
    func toModel(_ requirement: JobOrder_Data.ActionLibraryRequirement) -> DataManageModel.Output.ActionLibrary.Requirement {
        return DataManageModel.Output.ActionLibrary.Requirement()
    }

    /// aiLibraryデータをドメインモデルに変換する
    /// - Parameter aiLibraryEntity: aiLibraryデータ
    /// - Returns: aiLibraryドメインモデル
    func toModel(_ aiLibraryEntity: JobOrder_Data.AILibraryEntity) -> DataManageModel.Output.AILibrary {
        return DataManageModel.Output.AILibrary(id: aiLibraryEntity.id,
                                                name: aiLibraryEntity.name,
                                                type: aiLibraryEntity.type,
                                                requirements: aiLibraryEntity.requirementsArray.map { self.toModel($0) },
                                                imagePath: aiLibraryEntity.imagePath,
                                                overview: aiLibraryEntity.overview,
                                                remarks: aiLibraryEntity.remarks,
                                                version: aiLibraryEntity.version,
                                                createTime: aiLibraryEntity.createTime,
                                                creator: aiLibraryEntity.creator,
                                                updateTime: aiLibraryEntity.updateTime,
                                                updator: aiLibraryEntity.updator)
    }

    /// aiLibraryRequirementデータをドメインモデルに変換する
    /// - Parameter requirement: aiLibraryRequirementデータ
    /// - Returns: aiLibrary.Requirementドメインモデル
    func toModel(_ requirement: JobOrder_Data.AILibraryRequirement) -> DataManageModel.Output.AILibrary.Requirement {
        return DataManageModel.Output.AILibrary.Requirement()
    }

    /// ExecutionLog APIエンティティをドメインモデルに変換する
    /// - Parameter executionLog: ExecutionLog APIエンティティ
    /// - Returns: ExecutionLogドメインモデル
    func toModel(_ executionLog: JobOrder_API.ExecutionEntity.LogData) -> DataManageModel.Output.ExecutionLog {
        return DataManageModel.Output.ExecutionLog(id: executionLog.id,
                                                   executedAt: executionLog.executedAt,
                                                   result: executionLog.result)
    }

    /// Task APIエンティティ(POST向け)をドメインモデルに変換する
    /// - Parameter task: Task APIエンティティ(Input)
    /// - Returns: Taskドメインモデル(Input)
    func toModel(_ task: JobOrder_API.TaskAPIEntity.Input.Data) -> DataManageModel.Input.Task {
        return DataManageModel.Input.Task(jobId: task.jobId,
                                          robotIds: task.robotIds,
                                          start: self.toModel(task.start),
                                          exit: self.toModel(task.exit))
    }

    /// Task.Start APIエンティティ(POST向け)をドメインモデルに変換する
    /// - Parameter start: Task.Start APIエンティティ(Input)
    /// - Returns: Task.Startドメインモデル(Input)
    func toModel(_ start: JobOrder_API.TaskAPIEntity.Start) -> DataManageModel.Input.Task.Start {
        return DataManageModel.Input.Task.Start(condition: start.condition)
    }

    /// Task.Exit APIエンティティ(POST向け)をドメインモデルに変換する
    /// - Parameter exit: Task.Exit APIエンティティ(Input)
    /// - Returns: Task.Exitドメインモデル(Input)
    func toModel(_ exit: JobOrder_API.TaskAPIEntity.Exit) -> DataManageModel.Input.Task.Exit {
        return DataManageModel.Input.Task.Exit(condition: exit.condition,
                                               option: self.toModel(exit.option))
    }

    /// Task.Exit.Option APIエンティティ(POST向け)をドメインモデルに変換する
    /// - Parameter option: Task.Exit.Option APIエンティティ(Input)
    /// - Returns: Task.Exit.Optionドメインモデル(Input)
    func toModel(_ option: JobOrder_API.TaskAPIEntity.Exit.Option) -> DataManageModel.Input.Task.Exit.Option {
        return DataManageModel.Input.Task.Exit.Option(numberOfRuns: option.numberOfRuns)
    }

    /// 各種パラメータからTask(Input)ドメインモデルを構築する
    public func toModel(jobId: String, robotIds: [String], startCondition: String, exitCondition: String, numberOfRuns: Int) -> DataManageModel.Input.Task {
        return DataManageModel.Input.Task(jobId: jobId,
                                          robotIds: robotIds,
                                          start: DataManageModel.Input.Task.Start(condition: startCondition),
                                          exit: DataManageModel.Input.Task.Exit(
                                            condition: exitCondition,
                                            option: DataManageModel.Input.Task.Exit.Option(numberOfRuns: numberOfRuns)))
    }
}
