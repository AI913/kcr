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

    var commandsFromRobot: [JobOrder_API.CommandEntity.Data] {
        return [command]
    }
    var commandFromTask: CommandEntity.Data {
        return command
    }

    var command: JobOrder_API.CommandEntity.Data {
        return JobOrder_API.CommandEntity.Data(taskId: "54b50d1e-a4a6-435e-9a38-0eaa91aa2559",
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

    var swconf: JobOrder_API.RobotAPIEntity.Swconf {
        return JobOrder_API.RobotAPIEntity.Swconf(robotId: "6592c2a4-3688-49c5-ac1e-4763c81680e4",
                                                  operatingSystem: RobotAPIEntity.Swconf.OperatingSystem(system: "Linux",
                                                                                                         systemVersion: "4.18",
                                                                                                         distribution: "Ubuntu",
                                                                                                         distributionVersion: "18.04"),
                                                  softwares: [
                                                    RobotAPIEntity.Swconf.Software(swArtifactId: "7a710501-085d-4d13-9813-93a7656df2b2",
                                                                                   softwareId: "37f4e047-faf5-4e06-ad33-9d902a604d10",
                                                                                   versionId: "cb4bcac6-92e1-4a5a-8977-c286088de056",
                                                                                   displayName: "Common Module",
                                                                                   displayVersion: "1.0"),
                                                    RobotAPIEntity.Swconf.Software(swArtifactId: "5c670cf9-0f09-4b2e-843e-2be7aa6b8be0",
                                                                                   softwareId: "9d990b60-2f6d-409d-b3a0-bd8fd57e27b2",
                                                                                   versionId: "5dfbca2c-b2d5-434b-83fe-abcf7106a11e",
                                                                                   displayName: "Network Service Module",
                                                                                   displayVersion: "1.0"),
                                                    RobotAPIEntity.Swconf.Software(swArtifactId: "6e2a6e07-cb46-4753-828a-8969662d7235",
                                                                                   softwareId: "785c179e-b994-44cc-ae85-bd44f33d7f4d",
                                                                                   versionId: "424ddc7f-c40f-406e-a221-3059475047cf",
                                                                                   displayName: "Action Service Module",
                                                                                   displayVersion: "1.0")
                                                  ],
                                                  dataVersion: 1,
                                                  createTime: 1_592_477_367_000,
                                                  creator: "user@kyocera.jp",
                                                  updateTime: 1_592_477_367_000,
                                                  updator: "user@kyocera.jp")
    }

    var assets: [JobOrder_API.RobotAPIEntity.Asset] {
        return [asset]
    }

    var asset: JobOrder_API.RobotAPIEntity.Asset {
        return JobOrder_API.RobotAPIEntity.Asset(robotId: "6592c2a4-3688-49c5-ac1e-4763c81680e4",
                                                 assetId: "a4b2a8b5-a479-4a2a-bec8-3b96b87e65a4",
                                                 type: "hand",
                                                 displayMaker: "Kyocera Corporation",
                                                 displayModel: "82635AWGDVKPRQ",
                                                 displayModelClass: "Kyocera 6D",
                                                 displaySerial: "f97f805dd3f3",
                                                 dataVersion: 1,
                                                 createTime: 1_592_477_367_000,
                                                 creator: "user@kyocera.jp",
                                                 updateTime: 1_592_477_367_000,
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
