//
//  DomainTestsStub.swift
//  JobOrder.Domain
//
//  Created by Yu Suzuki on 2020/08/25.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

@testable import JobOrder_Domain
@testable import JobOrder_API

struct DomainTestsStub {

    var tasks: [JobOrder_API.TaskAPIEntity.Data] {
        return [task]
    }

    var task: JobOrder_API.TaskAPIEntity.Data {
        let command = JobOrder_API.CommandAPIEntity.Data(taskId: "54b50d1e-a4a6-435e-9a38-0eaa91aa2559",
                                                         robotId: "78abfbd4-6613-42a6-a691-23c3748fa346",
                                                         started: 0,
                                                         exited: 0,
                                                         execDuration: 0,
                                                         receivedStartReort: 0,
                                                         receivedExitReort: 0,
                                                         status: "queued",
                                                         resultInfo: "",
                                                         success: 0,
                                                         fail: 0,
                                                         error: 0,
                                                         dataVersion: 1,
                                                         createTime: 1_592_617_637_000,
                                                         creator: "user@kyocera.jp",
                                                         updateTime: 1_592_618_421_000,
                                                         updator: "user@kyocera.jp")
        return JobOrder_API.TaskAPIEntity.Data(command: command)
    }

    var jobs: [JobOrder_API.JobAPIEntity.Data] {
        return [job]
    }

    var job: JobOrder_API.JobAPIEntity.Data {
        let parameter = JobOrder_API.JobAPIEntity.Data.Action.Parameter()
        let action = JobOrder_API.JobAPIEntity.Data.Action(index: 1,
                                                           id: "id",
                                                           parameter: parameter,
                                                           _catch: nil,
                                                           then: nil)
        return JobOrder_API.JobAPIEntity.Data(id: "id",
                                              name: "name",
                                              actions: [action],
                                              entryPoint: 1,
                                              overview: "overview",
                                              remarks: "remarks",
                                              requirements: "requirements",
                                              version: 1,
                                              createTime: 1,
                                              creator: "creator",
                                              updateTime: 1,
                                              updator: "updator")
    }

    var robots: [JobOrder_API.RobotAPIEntity.Data] {
        return [robot]
    }

    var robot: JobOrder_API.RobotAPIEntity.Data {
        return JobOrder_API.RobotAPIEntity.Data(id: "id",
                                                name: "name",
                                                type: "type",
                                                locale: "locale",
                                                isSimulator: false,
                                                maker: "maker",
                                                model: "model",
                                                modelClass: "modelClass",
                                                serial: "serial",
                                                overview: "overview",
                                                remarks: "remarks",
                                                version: 1,
                                                createTime: 1_592_477_267_000,
                                                creator: "creator",
                                                updateTime: 1_592_477_267_000,
                                                updator: "updator",
                                                awsKey: RobotAPIEntity.Data.Key(thingName: "thingName", thingArn: "thingArn"))
    }

    var commands: [JobOrder_API.CommandAPIEntity.Data] {
        return [command]
    }

    var command: JobOrder_API.CommandAPIEntity.Data {
        return JobOrder_API.CommandAPIEntity.Data(taskId: "54b50d1e-a4a6-435e-9a38-0eaa91aa2559",
                                                  robotId: "78abfbd4-6613-42a6-a691-23c3748fa346",
                                                  started: 0,
                                                  exited: 0,
                                                  execDuration: 0,
                                                  receivedStartReort: 0,
                                                  receivedExitReort: 0,
                                                  status: "queued",
                                                  resultInfo: "",
                                                  success: 0,
                                                  fail: 0,
                                                  error: 0,
                                                  dataVersion: 1,
                                                  createTime: 1_592_617_637_000,
                                                  creator: "user@kyocera.jp",
                                                  updateTime: 1_592_618_421_000,
                                                  updator: "user@kyocera.jp")
    }

    var actionLibraries: [JobOrder_API.ActionLibraryAPIEntity.Data] {
        return [actionLibrary]
    }

    var actionLibrary: JobOrder_API.ActionLibraryAPIEntity.Data {
        return JobOrder_API.ActionLibraryAPIEntity.Data(id: "id",
                                                        name: "name",
                                                        requirements: "requirements",
                                                        imagePath: "imagePath",
                                                        overview: "overview",
                                                        remarks: "remarks",
                                                        version: 1,
                                                        createTime: 1,
                                                        creator: "creator",
                                                        updateTime: 1,
                                                        updator: "updator")
    }

    var aiLibraries: [JobOrder_API.AILibraryAPIEntity.Data] {
        return [aiLibrary]
    }

    var aiLibrary: JobOrder_API.AILibraryAPIEntity.Data {
        return JobOrder_API.AILibraryAPIEntity.Data(id: "id",
                                                    name: "name",
                                                    type: "type",
                                                    requirements: "requirements",
                                                    imagePath: "imagePath",
                                                    overview: "overview",
                                                    remarks: "remarks",
                                                    version: 1,
                                                    createTime: 1,
                                                    creator: "creator",
                                                    updateTime: 1,
                                                    updator: "updator")
    }
}
