//
//  DataManageModel+Equatable.swift
//  JobOrderTests
//
//  Created by 藤井一暢 on 2021/02/16.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
@testable import JobOrder_Domain
@testable import JobOrder_API
@testable import JobOrder_Data

// MARK: - Job情報
extension DataManageModel.Output.Job: Equatable {
    public static func == (lhs: DataManageModel.Output.Job, rhs: DataManageModel.Output.Job) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.actions == rhs.actions &&
            lhs.entryPoint == rhs.entryPoint &&
            lhs.overview == rhs.overview &&
            lhs.remarks == rhs.remarks &&
            lhs.requirements == rhs.requirements &&
            lhs.version == rhs.version &&
            lhs.createTime == rhs.createTime &&
            lhs.creator == rhs.creator &&
            lhs.updateTime == rhs.updateTime &&
            lhs.updator == rhs.updator
    }
}

extension DataManageModel.Output.Job.Action: Equatable {
    public static func == (lhs: DataManageModel.Output.Job.Action, rhs: DataManageModel.Output.Job.Action) -> Bool {
        return lhs.index == rhs.index &&
            lhs.id == rhs.id &&
            lhs.parameter == rhs.parameter &&
            lhs._catch == rhs._catch &&
            lhs.then == rhs.then
    }
}

extension DataManageModel.Output.Job.Action.Parameter: Equatable {
    public static func == (lhs: DataManageModel.Output.Job.Action.Parameter, rhs: DataManageModel.Output.Job.Action.Parameter) -> Bool {
        return true
    }
}

extension DataManageModel.Output.Job.Requirement: Equatable {
    public static func == (lhs: DataManageModel.Output.Job.Requirement, rhs: DataManageModel.Output.Job.Requirement) -> Bool {
        return true
    }

}

// MARK: - Robot情報
extension DataManageModel.Output.Robot: Equatable {
    public static func == (lhs: DataManageModel.Output.Robot, rhs: DataManageModel.Output.Robot) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.type == rhs.type &&
            lhs.model == rhs.model &&
            lhs.modelClass == rhs.modelClass &&
            lhs.maker == rhs.maker &&
            lhs.serial == rhs.serial &&
            lhs.overview == rhs.overview &&
            lhs.remarks == rhs.remarks &&
            lhs.thingName == rhs.thingName &&
            lhs.thingArn == rhs.thingArn &&
            lhs.state == rhs.state
    }
}

// MARK: - Command情報
extension DataManageModel.Output.Command: Equatable {
    public static func == (lhs: DataManageModel.Output.Command, rhs: DataManageModel.Output.Command) -> Bool {
        return lhs.taskId == rhs.taskId &&
            lhs.taskId == rhs.taskId &&
            lhs.robotId == rhs.robotId &&
            lhs.started == rhs.started &&
            lhs.exited == rhs.exited &&
            lhs.execDuration == rhs.execDuration &&
            lhs.receivedStartReort == rhs.receivedStartReort &&
            lhs.receivedExitReort == rhs.receivedExitReort &&
            lhs.status == rhs.status &&
            lhs.resultInfo == rhs.resultInfo &&
            lhs.success == rhs.success &&
            lhs.fail == rhs.fail &&
            lhs.error == rhs.error &&
            lhs.dataVersion == rhs.dataVersion &&
            lhs.createTime == rhs.createTime &&
            lhs.creator == rhs.creator &&
            lhs.updateTime == rhs.updateTime &&
            lhs.updator == rhs.updator
    }
}

// MARK: - Task情報
extension DataManageModel.Output.Task: Equatable {
    public static func == (lhs: DataManageModel.Output.Task, rhs: DataManageModel.Output.Task) -> Bool {
        return lhs.id == rhs.id &&
            lhs.jobId == rhs.jobId &&
            lhs.robotIds == rhs.robotIds &&
            lhs.exit == rhs.exit &&
            lhs.job == rhs.job &&
            lhs.createTime == rhs.createTime &&
            lhs.creator == rhs.creator &&
            lhs.updateTime == rhs.updateTime &&
            lhs.updator == rhs.updator
    }
}

extension DataManageModel.Output.Task.Exit: Equatable {
    public static func == (lhs: DataManageModel.Output.Task.Exit, rhs: DataManageModel.Output.Task.Exit) -> Bool {
        return lhs.option == rhs.option
    }
}

extension DataManageModel.Output.Task.Exit.Option: Equatable {
    public static func == (lhs: DataManageModel.Output.Task.Exit.Option, rhs: DataManageModel.Output.Task.Exit.Option) -> Bool {
        return lhs.numberOfRuns == rhs.numberOfRuns
    }
}

extension DataManageModel.Input.Task: Equatable {
    public static func == (lhs: DataManageModel.Input.Task, rhs: DataManageModel.Input.Task) -> Bool {
        return lhs.jobId == rhs.jobId &&
            lhs.robotIds == rhs.robotIds &&
            lhs.start == rhs.start &&
            lhs.exit == rhs.exit
    }
}

extension DataManageModel.Input.Task.Start: Equatable {
    public static func == (lhs: DataManageModel.Input.Task.Start, rhs: DataManageModel.Input.Task.Start) -> Bool {
        return lhs.condition == rhs.condition
    }

}

extension DataManageModel.Input.Task.Exit: Equatable {
    public static func == (lhs: DataManageModel.Input.Task.Exit, rhs: DataManageModel.Input.Task.Exit) -> Bool {
        return lhs.condition == rhs.condition &&
            lhs.option == rhs.option
    }
}

extension DataManageModel.Input.Task.Exit.Option: Equatable {
    public static func == (lhs: DataManageModel.Input.Task.Exit.Option, rhs: DataManageModel.Input.Task.Exit.Option) -> Bool {
        return lhs.numberOfRuns == rhs.numberOfRuns
    }
}

// MARK: - ExecutionLog情報
extension DataManageModel.Output.ExecutionLog: Equatable {
    public static func == (lhs: DataManageModel.Output.ExecutionLog, rhs: DataManageModel.Output.ExecutionLog) -> Bool {
        return lhs.id == rhs.id &&
            lhs.executedAt == rhs.executedAt &&
            lhs.result == rhs.result
    }
}

// MARK: -
/// 配列を検証するヘルパー
func isEqualArray<T1, T2>(_ lhs: [T1]?, _ rhs: [T2]?, isEqual: (T1, T2) -> Bool) -> Bool {
    switch (lhs, rhs) {
    case let (lhs?, rhs?):
        // 要素数が同じであること
        if lhs.count != rhs.count { return false }
        for (l, r) in zip(lhs, rhs) {
            // 各要素が同じであること
            if !isEqual(l, r) { return false }
        }
        return true
    case let (lhs?, nil):
        // 片方がnilの場合は空配列であれば同じとする
        return lhs.isEmpty
    case let (nil, rhs?):
        // 片方がnilの場合は空配列であれば同じとする
        return rhs.isEmpty
    case (nil, nil):
        // 両方nilの場合は同じとする
        return true
    }
}

/// 要素を検証するヘルパー
func isEqualElement<T1, T2>(_ lhs: T1?, _ rhs: T2?, isEqual: (T1, T2) -> Bool ) -> Bool {
    if let lhs = lhs, let rhs = rhs {
        // 要素が同じであること
        return isEqual(lhs, rhs)
    }
    // 両方nilの場合は同じとする
    if lhs == nil && rhs == nil { return true }

    return false
}

// MARK: - DataManageModel.Output.Jobとの比較
extension DataManageModel.Output.Job {
    static func == (lhs: DataManageModel.Output.Job, rhs: JobOrder_Data.JobEntity) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            isEqualArray(lhs.actions, rhs.actionsArray) { $0 == $1 } &&
            lhs.entryPoint == rhs.entryPoint &&
            lhs.overview == rhs.overview &&
            lhs.remarks == rhs.remarks &&
            isEqualArray(lhs.requirements, rhs.requirementsArray) { $0 == $1 } &&
            lhs.version == rhs.version &&
            lhs.createTime == rhs.createTime &&
            lhs.creator == rhs.creator &&
            lhs.updateTime == rhs.updateTime &&
            lhs.updator == rhs.updator
    }
    static func == (lhs: DataManageModel.Output.Job, rhs: JobOrder_API.JobAPIEntity.Data) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            isEqualArray(lhs.actions, rhs.actions) { $0 == $1 } &&
            lhs.entryPoint == rhs.entryPoint &&
            lhs.overview == rhs.overview &&
            lhs.remarks == rhs.remarks &&
            isEqualArray(lhs.requirements, rhs.requirements) { $0 == $1 } &&
            lhs.version == rhs.version &&
            lhs.createTime == rhs.createTime &&
            lhs.creator == rhs.creator &&
            lhs.updateTime == rhs.updateTime &&
            lhs.updator == rhs.updator
    }
}

extension DataManageModel.Output.Job.Action {
    static func == (lhs: DataManageModel.Output.Job.Action, rhs: JobOrder_Data.JobAction) -> Bool {
        return lhs.index == rhs.index &&
            lhs.id == rhs.id &&
            // lhs.parameter == rhs.parameter &&
            lhs._catch == rhs._catch &&
            lhs.then == rhs.then
    }
    static func == (lhs: DataManageModel.Output.Job.Action, rhs: JobOrder_API.JobAPIEntity.Data.Action) -> Bool {
        return lhs.index == rhs.index &&
            lhs.id == rhs.id &&
            isEqualElement(lhs.parameter, rhs.parameter) { $0 == $1 } &&
            lhs._catch == rhs._catch &&
            lhs.then == rhs.then
    }
}

extension DataManageModel.Output.Job.Action.Parameter {
    static func == (lhs: DataManageModel.Output.Job.Action.Parameter, rhs: JobAPIEntity.Data.Action.Parameter) -> Bool {
        return true
    }
}

extension DataManageModel.Output.Job.Requirement {
    static func == (lhs: DataManageModel.Output.Job.Requirement, rhs: JobOrder_Data.JobRequirement) -> Bool {
        return true
    }
    static func == (lhs: DataManageModel.Output.Job.Requirement, rhs: JobAPIEntity.Data.Requirement) -> Bool {
        return true
    }
}

// MARK: - DataManageModel.Output.Robotとの比較
extension DataManageModel.Output.Robot {
    static func == (lhs: DataManageModel.Output.Robot, rhs: JobOrder_Data.RobotEntity) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.type == rhs.type &&
            lhs.model == rhs.model &&
            lhs.modelClass == rhs.modelClass &&
            lhs.maker == rhs.maker &&
            lhs.serial == rhs.serial &&
            lhs.overview == rhs.overview &&
            lhs.remarks == rhs.remarks &&
            lhs.thingName == rhs.thingName &&
            lhs.thingArn == rhs.thingArn &&
            isEqualElement(lhs.state, rhs.state) { $0.key == $1 }
    }
    static func == (lhs: DataManageModel.Output.Robot, rhs: JobOrder_API.RobotAPIEntity.Data) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.type == rhs.type &&
            lhs.model == rhs.model &&
            lhs.modelClass == rhs.modelClass &&
            lhs.maker == rhs.maker &&
            lhs.serial == rhs.serial &&
            lhs.overview == rhs.overview &&
            lhs.remarks == rhs.remarks &&
            lhs.thingName == rhs.awsKey?.thingName &&
            lhs.thingArn == rhs.awsKey?.thingArn
    }
}

// MARK: - DataManageModel.Output.Commandとの比較
extension DataManageModel.Output.Command {
    static func == (lhs: DataManageModel.Output.Command, rhs: JobOrder_API.CommandEntity.Data) -> Bool {
        return lhs.taskId == rhs.taskId &&
            lhs.taskId == rhs.taskId &&
            lhs.robotId == rhs.robotId &&
            lhs.started == rhs.started &&
            lhs.exited == rhs.exited &&
            lhs.execDuration == rhs.execDuration &&
            lhs.receivedStartReort == rhs.receivedStartReort &&
            lhs.receivedExitReort == rhs.receivedExitReort &&
            lhs.status == rhs.status &&
            lhs.resultInfo == rhs.resultInfo &&
            lhs.success == rhs.success &&
            lhs.fail == rhs.fail &&
            lhs.error == rhs.error &&
            lhs.dataVersion == rhs.dataVersion &&
            lhs.createTime == rhs.createTime &&
            lhs.creator == rhs.creator &&
            lhs.updateTime == rhs.updateTime &&
            lhs.updator == rhs.updator
    }
}

// MARK: - DataManageModel.Output.Taskとの比較
extension DataManageModel.Output.Task {
    static func == (lhs: DataManageModel.Output.Task, rhs: JobOrder_API.TaskAPIEntity.Data) -> Bool {
        return lhs.id == rhs.id &&
            lhs.jobId == rhs.jobId &&
            lhs.robotIds == rhs.robotIds &&
            lhs.exit == rhs.exit &&
            lhs.job == rhs.job &&
            lhs.createTime == rhs.createTime &&
            lhs.creator == rhs.creator &&
            lhs.updateTime == rhs.updateTime &&
            lhs.updator == rhs.updator
    }
}

extension DataManageModel.Output.Task.Exit {
    static func == (lhs: DataManageModel.Output.Task.Exit, rhs: JobOrder_API.TaskAPIEntity.Exit) -> Bool {
        return lhs.option == rhs.option
    }
}

extension DataManageModel.Output.Task.Exit.Option {
    static func == (lhs: DataManageModel.Output.Task.Exit.Option, rhs: JobOrder_API.TaskAPIEntity.Exit.Option) -> Bool {
        return lhs.numberOfRuns == rhs.numberOfRuns
    }
}

// MARK: - DataManageModel.Output.ActionLibraryとの比較
extension DataManageModel.Output.ActionLibrary {
    static func == (lhs: DataManageModel.Output.ActionLibrary, rhs: JobOrder_Data.ActionLibraryEntity) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            isEqualArray(lhs.requirements, rhs.requirementsArray) { $0 == $1 } &&
            lhs.imagePath == rhs.imagePath &&
            lhs.overview == rhs.overview &&
            lhs.remarks == rhs.remarks &&
            lhs.version == rhs.version &&
            lhs.createTime == rhs.createTime &&
            lhs.creator == rhs.creator &&
            lhs.updateTime == rhs.updateTime &&
            lhs.updator == rhs.updator
    }
}

extension DataManageModel.Output.ActionLibrary.Requirement {
    static func == (lhs: DataManageModel.Output.ActionLibrary.Requirement, rhs: JobOrder_Data.ActionLibraryRequirement) -> Bool {
        return true
    }
}

// MARK: - DataManageModel.Output.Systemとの比較
extension DataManageModel.Output.System.SoftwareConfiguration {
    static func == (lhs: DataManageModel.Output.System.SoftwareConfiguration, rhs: JobOrder_API.RobotAPIEntity.Swconf) -> Bool {
        let distribution = "\(rhs.operatingSystem?.distribution ?? "") \(rhs.operatingSystem?.distributionVersion ?? "")"
        if lhs.distribution != distribution { return false }

        let system = "\(rhs.operatingSystem?.system ?? "") \(rhs.operatingSystem?.systemVersion ?? "")"
        if lhs.system != system { return false }

        if let softwares = rhs.softwares {
            if lhs.installs.count != softwares.count { return false }
            for (index, software) in softwares.enumerated() {
                let name = software.displayName ?? ""
                let version = software.displayVersion ?? ""
                if lhs.installs[index].name != name { return false }
                if lhs.installs[index].version != version { return false }
            }
        }

        return true
    }
}

extension DataManageModel.Output.System.HardwareConfiguration {
    static func == (lhs: DataManageModel.Output.System.HardwareConfiguration, rhs: JobOrder_API.RobotAPIEntity.Asset) -> Bool {
        return lhs.type == rhs.type &&
            lhs.model == rhs.displayModel ?? "" &&
            lhs.maker == rhs.displayMaker ?? "" &&
            lhs.serialNo == rhs.displaySerial ?? ""
    }
}

// MARK: - DataManageModel.Output.AILibraryとの比較
extension DataManageModel.Output.AILibrary {
    static func == (lhs: DataManageModel.Output.AILibrary, rhs: JobOrder_Data.AILibraryEntity) -> Bool {
        return true
    }
}

// MARK: - DataManageModel.Input.Taskとの比較
extension DataManageModel.Input.Task {
    static func == (lhs: DataManageModel.Input.Task, rhs: JobOrder_API.TaskAPIEntity.Input.Data) -> Bool {
        return lhs.jobId == rhs.jobId &&
            lhs.robotIds == rhs.robotIds &&
            lhs.start == rhs.start &&
            lhs.exit == rhs.exit
    }
}

extension DataManageModel.Input.Task.Start {
    public static func == (lhs: DataManageModel.Input.Task.Start, rhs: JobOrder_API.TaskAPIEntity.Start) -> Bool {
        return lhs.condition == rhs.condition
    }

}

extension DataManageModel.Input.Task.Exit {
    public static func == (lhs: DataManageModel.Input.Task.Exit, rhs: JobOrder_API.TaskAPIEntity.Exit) -> Bool {
        return lhs.condition == rhs.condition &&
            lhs.option == rhs.option
    }
}

extension DataManageModel.Input.Task.Exit.Option {
    public static func == (lhs: DataManageModel.Input.Task.Exit.Option, rhs: JobOrder_API.TaskAPIEntity.Exit.Option) -> Bool {
        return lhs.numberOfRuns == rhs.numberOfRuns
    }
}

// MARK: - DataManageModel.Input.Jobとの比較
extension DataManageModel.Input.Job {
    static func == (lhs: DataManageModel.Input.Job, rhs: JobOrder_API.JobAPIEntity.Input.Data) -> Bool {
        return lhs.name == rhs.name &&
            isEqualArray(lhs.actions, rhs.actions) { $0 == $1 } &&
            lhs.entryPoint == rhs.entryPoint &&
            lhs.overview == rhs.overview &&
            lhs.remarks == rhs.remarks &&
            isEqualArray(lhs.requirements, rhs.requirements) { $0 == $1 }
    }
}

extension DataManageModel.Input.Job.Action {
    static func == (lhs: DataManageModel.Input.Job.Action, rhs: JobAPIEntity.Input.Data.Action) -> Bool {
        return lhs.index == rhs.index &&
            lhs.actionLibraryId == rhs.actionLibraryId &&
            isEqualElement(lhs.parameter, rhs.parameter) { $0 == $1 } &&
            lhs.catch == rhs.catch &&
            lhs.then == rhs.then
    }
}

extension DataManageModel.Input.Job.Action.Parameter {
    static func == (lhs: DataManageModel.Input.Job.Action.Parameter, rhs: JobAPIEntity.Input.Data.Action.Parameter) -> Bool {
        return lhs.aiLibraryId == rhs.aiLibraryId &&
            lhs.aiLibraryObjectId == rhs.aiLibraryObjectId
    }
}

extension DataManageModel.Input.Job.Requirement {
    static func == (lhs: DataManageModel.Input.Job.Requirement, rhs: JobAPIEntity.Input.Data.Requirement) -> Bool {
        return lhs.type == rhs.type &&
            lhs.subtype == rhs.subtype &&
            lhs.id == rhs.id &&
            lhs.versionId == rhs.versionId
    }
}
