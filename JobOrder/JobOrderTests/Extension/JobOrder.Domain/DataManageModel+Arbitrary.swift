//
//  DataManageModel+Arbitrary.swift
//  JobOrderTests
//
//  Created by 藤井一暢 on 2021/01/13.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import JobOrder_Domain

// MARK: - Robot情報
extension DataManageModel.Output.Robot: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let stageGen = Gen<String>.fromElements(of: ["unknown", "terminated", "stopped", "starting", "waiting", "processing"])
            return DataManageModel.Output.Robot(id: c.generate(using: FakeFactory.shared.uuidStringGen),
                                                name: c.generate(),
                                                type: c.generate(),
                                                locale: c.generate(using: FakeFactory.shared.localeGen),
                                                isSimulator: c.generate(),
                                                maker: c.generate(),
                                                model: c.generate(),
                                                modelClass: c.generate(),
                                                serial: c.generate(),
                                                overview: c.generate(),
                                                remarks: c.generate(),
                                                version: c.generate(),
                                                createTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                creator: c.generate(using: FakeFactory.shared.emailGen),
                                                updateTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                updator: c.generate(using: FakeFactory.shared.emailGen),
                                                thingName: c.generate(),
                                                thingArn: c.generate(),
                                                state: c.generate(using: stageGen))
        }
    }

    public static func pattern(id: String, name: String) -> Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Output.Robot(id: id,
                                                name: name,
                                                type: c.generate(),
                                                locale: c.generate(using: FakeFactory.shared.localeGen),
                                                isSimulator: c.generate(),
                                                maker: c.generate(),
                                                model: c.generate(),
                                                modelClass: c.generate(),
                                                serial: c.generate(),
                                                overview: c.generate(),
                                                remarks: c.generate(),
                                                version: c.generate(),
                                                createTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                creator: c.generate(using: FakeFactory.shared.emailGen),
                                                updateTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                updator: c.generate(using: FakeFactory.shared.emailGen),
                                                thingName: c.generate(),
                                                thingArn: c.generate(),
                                                state: c.generate())
        }
    }
}

// MARK: - Task情報
extension DataManageModel.Output.Task: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Output.Task(id: c.generate(using: FakeFactory.shared.uuidStringGen),
                                               jobId: c.generate(using: FakeFactory.shared.uuidStringGen),
                                               robotIds: c.generate(using: FakeFactory.shared.uuidStringGen.proliferate),
                                               exit: c.generate(),
                                               job: c.generate(),
                                               createTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                               creator: c.generate(using: FakeFactory.shared.emailGen),
                                               updateTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                               updator: c.generate(using: FakeFactory.shared.emailGen))
        }
    }

    public static func pattern(robotIds: [String]) -> Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Output.Task(id: c.generate(using: FakeFactory.shared.uuidStringGen),
                                               jobId: c.generate(using: FakeFactory.shared.uuidStringGen),
                                               robotIds: robotIds,
                                               exit: c.generate(),
                                               job: c.generate(),
                                               createTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                               creator: c.generate(using: FakeFactory.shared.emailGen),
                                               updateTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                               updator: c.generate(using: FakeFactory.shared.emailGen))
        }
    }

    public static func pattern(numberOfRuns: Int) -> Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Output.Task(id: c.generate(using: FakeFactory.shared.uuidStringGen),
                                               jobId: c.generate(using: FakeFactory.shared.uuidStringGen),
                                               robotIds: c.generate(using: FakeFactory.shared.uuidStringGen.proliferate),
                                               exit: c.generate(using: DataManageModel.Output.Task.Exit.pattern(numberOfRuns: numberOfRuns)),
                                               job: c.generate(),
                                               createTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                               creator: c.generate(using: FakeFactory.shared.emailGen),
                                               updateTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                               updator: c.generate(using: FakeFactory.shared.emailGen))
        }
    }
}

extension DataManageModel.Output.Task.Exit: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let option: DataManageModel.Output.Task.Exit.Option = c.generate()
            return DataManageModel.Output.Task.Exit(option)
        }
    }

    public static func pattern(numberOfRuns: Int) -> Gen<Self> {
        return Gen<Self>.compose { c in
            let option: DataManageModel.Output.Task.Exit.Option = c.generate(using: DataManageModel.Output.Task.Exit.Option.pattern(numberOfRuns: numberOfRuns))
            return DataManageModel.Output.Task.Exit(option)
        }
    }
}

extension DataManageModel.Output.Task.Exit.Option: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let numberOfRuns: Int = c.generate()
            return DataManageModel.Output.Task.Exit.Option(numberOfRuns)
        }
    }

    public static func pattern(numberOfRuns: Int) -> Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Output.Task.Exit.Option(numberOfRuns)
        }
    }
}

// MARK: - Job情報
extension DataManageModel.Output.Job: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Output.Job(id: c.generate(using: FakeFactory.shared.uuidStringGen),
                                              name: c.generate(),
                                              actions: c.generate(),
                                              entryPoint: c.generate(),
                                              overview: c.generate(),
                                              remarks: c.generate(),
                                              requirements: c.generate(),
                                              version: c.generate(),
                                              createTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                              creator: c.generate(using: FakeFactory.shared.emailGen),
                                              updateTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                              updator: c.generate(using: FakeFactory.shared.emailGen))
        }
    }

    public static func pattern(id: String, name: String) -> Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Output.Job(id: id,
                                              name: name,
                                              actions: c.generate(),
                                              entryPoint: c.generate(),
                                              overview: c.generate(),
                                              remarks: c.generate(),
                                              requirements: c.generate(),
                                              version: c.generate(),
                                              createTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                              creator: c.generate(using: FakeFactory.shared.emailGen),
                                              updateTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                              updator: c.generate(using: FakeFactory.shared.emailGen))
        }
    }
}

extension DataManageModel.Output.Job.Action: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Output.Job.Action(index: c.generate(),
                                                     id: c.generate(),
                                                     parameter: nil,
                                                     _catch: c.generate(),
                                                     then: c.generate())
        }
    }
}

extension DataManageModel.Output.Job.Requirement: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Output.Job.Requirement()
        }
    }
}

extension DataManageModel.Input.Job: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Input.Job(name: c.generate(),
                                             actions: c.generate(),
                                             entryPoint: c.generate(),
                                             overview: c.generate(),
                                             remarks: c.generate(),
                                             requirements: c.generate())
        }
    }
}

extension DataManageModel.Input.Job.Action: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Input.Job.Action(index: c.generate(),
                                                    actionLibraryId: c.generate(using: FakeFactory.shared.uuidStringGen),
                                                    parameter: c.generate(),
                                                    catch: c.generate(),
                                                    then: c.generate())
        }
    }
}

extension DataManageModel.Input.Job.Action.Parameter: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Input.Job.Action.Parameter(aiLibraryId: c.generate(using: FakeFactory.shared.uuidStringGen),
                                                              aiLibraryObjectId: c.generate())
        }
    }
}

extension DataManageModel.Input.Job.Requirement: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Input.Job.Requirement(type: c.generate(),
                                                         subtype: c.generate(),
                                                         id: c.generate(),
                                                         versionId: c.generate())
        }
    }
}

// MARK: - Command情報
extension DataManageModel.Output.Command: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Output.Command(taskId: c.generate(using: FakeFactory.shared.uuidStringGen),
                                                  robotId: c.generate(using: FakeFactory.shared.uuidStringGen),
                                                  started: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                  exited: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                  execDuration: c.generate(),
                                                  receivedStartReort: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                  receivedExitReort: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                  status: c.generate(),
                                                  resultInfo: c.generate(),
                                                  success: c.generate(),
                                                  fail: c.generate(),
                                                  error: c.generate(),
                                                  robot: c.generate(),
                                                  dataVersion: c.generate(),
                                                  createTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                  creator: c.generate(using: FakeFactory.shared.emailGen),
                                                  updateTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                  updator: c.generate(using: FakeFactory.shared.emailGen))
        }
    }

    public static func pattern(taskId: String) -> Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Output.Command(taskId: taskId,
                                                  robotId: c.generate(using: FakeFactory.shared.uuidStringGen),
                                                  started: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                  exited: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                  execDuration: c.generate(),
                                                  receivedStartReort: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                  receivedExitReort: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                  status: c.generate(),
                                                  resultInfo: c.generate(),
                                                  success: c.generate(),
                                                  fail: c.generate(),
                                                  error: c.generate(),
                                                  robot: c.generate(),
                                                  dataVersion: c.generate(),
                                                  createTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                  creator: c.generate(using: FakeFactory.shared.emailGen),
                                                  updateTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                  updator: c.generate(using: FakeFactory.shared.emailGen))
        }
    }

    public static func pattern(success: Int, fail: Int, error: Int) -> Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Output.Command(taskId: c.generate(using: FakeFactory.shared.uuidStringGen),
                                                  robotId: c.generate(using: FakeFactory.shared.uuidStringGen),
                                                  started: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                  exited: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                  execDuration: c.generate(),
                                                  receivedStartReort: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                  receivedExitReort: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                  status: c.generate(),
                                                  resultInfo: c.generate(),
                                                  success: success,
                                                  fail: fail,
                                                  error: error,
                                                  robot: c.generate(),
                                                  dataVersion: c.generate(),
                                                  createTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                  creator: c.generate(using: FakeFactory.shared.emailGen),
                                                  updateTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                  updator: c.generate(using: FakeFactory.shared.emailGen))
        }
    }
}

// MARK: - System情報
extension DataManageModel.Output.System: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Output.System(softwareConfiguration: c.generate(),
                                                 hardwareConfigurations: c.generate())
        }
    }
}

extension DataManageModel.Output.System.SoftwareConfiguration: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Output.System.SoftwareConfiguration(system: c.generate(),
                                                                       distribution: c.generate(),
                                                                       installs: c.generate())
        }
    }
}

extension DataManageModel.Output.System.SoftwareConfiguration.Installed: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Output.System.SoftwareConfiguration.Installed(name: c.generate(),
                                                                                 version: c.generate())
        }
    }
}

extension DataManageModel.Output.System.HardwareConfiguration: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return DataManageModel.Output.System.HardwareConfiguration(type: c.generate(),
                                                                       model: c.generate(),
                                                                       maker: c.generate(),
                                                                       serialNo: c.generate())
        }
    }
}

// MARK: - ExecutionLog情報
extension DataManageModel.Output.ExecutionLog: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let resultGen = Gen<String>.fromElements(of: ["success", "fail"])
            return DataManageModel.Output.ExecutionLog(id: c.generate(using: FakeFactory.shared.uuidStringGen),
                                                       executedAt: c.generate(using: FakeFactory.shared.epochTimeGen),
                                                       result: c.generate(using: resultGen))
        }
    }
}
