//
//  APITestsStub.swift
//  JobOrder.APITests
//
//  Created by Yu Suzuki on 2020/08/25.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

@testable import JobOrder_API

struct APITestsStub {

    var jobsResult: APIResult<[JobAPIEntity.Data]> {
        return APIResult(time: 1_592_477_407_000, data: jobs, count: 3, paging: nil)
    }

    var robotsResult: APIResult<[RobotAPIEntity.Data]> {
        return APIResult(time: 1_592_477_407_000, data: robots, count: 3, paging: nil)
    }

    var swconfResult: APIResult<RobotAPIEntity.Swconf> {
        return APIResult(time: 1_592_693_902_000, data: swconf, count: nil, paging: nil)
    }

    var assetsResult: APIResult<[RobotAPIEntity.Asset]> {
        return APIResult(time: 1_603_999_930_000, data: assets, count: 2, paging: nil)
    }

    var actionLibrariesResult: APIResult<[ActionLibraryAPIEntity.Data]> {
        return APIResult(time: 1_592_477_407_000, data: actionLibraries, count: 1, paging: nil)
    }

    var aiLibrariesResult: APIResult<[AILibraryAPIEntity.Data]> {
        return APIResult(time: 1_592_477_407_000, data: aiLibraries, count: 2, paging: nil)
    }

    var jobResult: APIResult<JobAPIEntity.Data> {
        return APIResult(time: 1_592_477_407_000, data: job1, count: 1, paging: nil)
    }

    var tasksFromJobResult: APIResult<[TaskAPIEntity.Data]> {
        return APIResult(time: 1_602_795_182_227, data: tasks, count: 2, paging: nil)
    }

    var robotResult: APIResult<RobotAPIEntity.Data> {
        return APIResult(time: 1_592_477_407_000, data: robot1, count: 1, paging: nil)
    }

    var commandResult: APIResult<CommandEntity.Data> {
        return APIResult(time: 1_592_477_407_000, data: command1, count: 1, paging: nil)
    }

    var commandsFromRobotResult: APIResult<[CommandEntity.Data]> {
        return APIResult(time: 1_592_477_407_000, data: commands, count: 2, paging: nil)
    }

    var commandFromTaskResult: APIResult<CommandEntity.Data> {
        return APIResult(time: 1_592_477_407_000, data: command1, count: 1, paging: nil)
    }

    var commandsFromTaskResult: APIResult<[CommandEntity.Data]> {
        return APIResult(time: 1_592_477_407_000, data: commands, count: 2, paging: nil)
    }

    var actionLibraryResult: APIResult<ActionLibraryAPIEntity.Data> {
        return APIResult(time: 1_592_477_407_000, data: actionLibrary1, count: 1, paging: nil)
    }

    var aiLibraryResult: APIResult<AILibraryAPIEntity.Data> {
        return APIResult(time: 1_592_477_407_000, data: aiLibrary1, count: 1, paging: nil)
    }
}

extension APITestsStub {

    private var robots: [RobotAPIEntity.Data] {
        [robot1, robot2, robot3]
    }

    private var robot1: RobotAPIEntity.Data {
        let key = RobotAPIEntity.Data.Key(thingName: "Robot-KC-1",
                                          thingArn: "arn:aws:iot:ap-northeast-1:701006255006:thing/Robot-KC-1")
        return RobotAPIEntity.Data(id: "0149308a-af44-4d03-9864-c5ab5561cd91",
                                   name: "Tatsumi's MacBook Pro",
                                   type: "PC",
                                   locale: "ja_JP",
                                   isSimulator: false,
                                   maker: "Apple",
                                   model: "MacBookPro15,4",
                                   modelClass: "MacBook Pro 2019",
                                   serial: "FVFZM0M8L415",
                                   overview: "",
                                   remarks: "",
                                   version: 1,
                                   createTime: 1_592_477_267_000,
                                   creator: "user@kyocera.jp",
                                   updateTime: 1_592_477_267_000,
                                   updator: "user@kyocera.jp",
                                   awsKey: key)
    }

    private var robot2: RobotAPIEntity.Data {
        let key = RobotAPIEntity.Data.Key(thingName: "Robot-KC-2",
                                          thingArn: "arn:aws:iot:ap-northeast-1:701006255006:thing/Robot-KC-2")
        return RobotAPIEntity.Data(id: "ac305346-fd81-4cbb-8738-90b025570292",
                                   name: "Minami's Raspberry Pi",
                                   type: "Arm",
                                   locale: "ja_JP",
                                   isSimulator: false,
                                   maker: "RS Components Ltd.",
                                   model: "3BPLUS-R",
                                   modelClass: "Raspberry Pi3 ModelB+",
                                   serial: "B8AE9C426FC1",
                                   overview: "",
                                   remarks: "",
                                   version: 1,
                                   createTime: 1_592_477_387_000,
                                   creator: "user@kyocera.jp",
                                   updateTime: 1_592_477_387_000,
                                   updator: "user@kyocera.jp",
                                   awsKey: key)
    }

    private var robot3: RobotAPIEntity.Data {
        let key = RobotAPIEntity.Data.Key(thingName: "Robot-KC-3",
                                          thingArn: "arn:aws:iot:ap-northeast-1:701006255006:thing/Robot-KC-3")
        return RobotAPIEntity.Data(id: "0c2ede75-65b9-4bce-99d5-a82c2a685655",
                                   name: "Kanasaki 1",
                                   type: "Arm",
                                   locale: "ja_JP",
                                   isSimulator: true,
                                   maker: "Sample Maker Inc.",
                                   model: "41DA",
                                   modelClass: "SR-202004",
                                   serial: "B8AE9C426FC1",
                                   overview: "The overview of Sample Robot 3.",
                                   remarks: "This remarks of Sample Robot 3.",
                                   version: 1,
                                   createTime: 1_592_477_387_000,
                                   creator: "user@kyocera.jp",
                                   updateTime: 1_592_477_387_000,
                                   updator: "user@kyocera.jp",
                                   awsKey: key)
    }

    private var commands: [CommandEntity.Data] {
        [command1, command2]
    }

    private var command1: CommandEntity.Data {

        return CommandEntity.Data(taskId: "54b50d1e-a4a6-435e-9a38-0eaa91aa2559",
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
                                  robot: CommandEntity.Data.Robot(robotInfo: robot1),
                                  dataVersion: 1,
                                  createTime: 1_592_617_637_000,
                                  creator: "user@kyocera.jp",
                                  updateTime: 1_592_618_421_000,
                                  updator: "user@kyocera.jp")
    }

    private var command2: CommandEntity.Data {

        return CommandEntity.Data(taskId: "54b50d1e-a4a6-435e-9a38-0eaa91aa2559",
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
                                  robot: CommandEntity.Data.Robot(robotInfo: robot1),
                                  dataVersion: 1,
                                  createTime: 1_592_617_637_000,
                                  creator: "user@kyocera.jp",
                                  updateTime: 1_592_618_421_000,
                                  updator: "user@kyocera.jp")
    }

    private var swconf: RobotAPIEntity.Swconf {
        return RobotAPIEntity.Swconf(robotId: "6592c2a4-3688-49c5-ac1e-4763c81680e4",
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

    private var assets: [RobotAPIEntity.Asset] {
        [asset1, asset2]
    }

    private var asset1: RobotAPIEntity.Asset {
        return RobotAPIEntity.Asset(robotId: "6592c2a4-3688-49c5-ac1e-4763c81680e4",
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

    private var asset2: RobotAPIEntity.Asset {
        return RobotAPIEntity.Asset(robotId: "6592c2a4-3688-49c5-ac1e-4763c81680e4",
                                    assetId: "fa9f7d4a-0ba6-4a10-9abc-f97f805dd3f3",
                                    type: "camera",
                                    displayMaker: "Intel Corporation",
                                    displayModel: "82635AWGDVKPRQ",
                                    displayModelClass: "Intel RealSense Depth Camera D435",
                                    displaySerial: "f97f805dd3f3",
                                    dataVersion: 1,
                                    createTime: 1_592_477_367_000,
                                    creator: "user@kyocera.jp",
                                    updateTime: 1_592_477_367_000,
                                    updator: "user@kyocera.jp")
    }

    private var jobs: [JobAPIEntity.Data] {
        [job1, job2, job3]
    }

    private var job1: JobAPIEntity.Data {
        let parameter = JobAPIEntity.Data.Action.Parameter()
        let action = JobAPIEntity.Data.Action(index: 1,
                                              id: "30cf3116-c823-4093-a62d-4fe07c81ffff",
                                              parameter: parameter,
                                              _catch: nil,
                                              then: nil)
        return JobAPIEntity.Data(id: "8ce74801-1045-4ade-aebf-9fc237acc682",
                                 name: "LED Flicker Job (RED)",
                                 actions: [action],
                                 entryPoint: 1,
                                 overview: "A job for flickering Raspberry Pi LEDs",
                                 remarks: "The remarks of Job 1",
                                 requirements: nil,
                                 version: 1,
                                 createTime: 1_592_477_367_000,
                                 creator: "user@kyocera.jp",
                                 updateTime: 1_592_477_367_000,
                                 updator: "user@kyocera.jp")
    }

    private var job2: JobAPIEntity.Data {
        let parameter = JobAPIEntity.Data.Action.Parameter()
        let action = JobAPIEntity.Data.Action(index: 1,
                                              id: "30cf3116-c823-4093-a62d-4fe07c81ffff",
                                              parameter: parameter,
                                              _catch: nil,
                                              then: nil)
        return JobAPIEntity.Data(id: "9da41ec9-d611-42f9-87e7-f929f58917df",
                                 name: "LED Flicker Job (GREEN)",
                                 actions: [action],
                                 entryPoint: 1,
                                 overview: "A job for flickering Raspberry Pi LEDs",
                                 remarks: "The remarks of Job 2",
                                 requirements: nil,
                                 version: 1,
                                 createTime: 1_592_477_397_000,
                                 creator: "user@kyocera.jp",
                                 updateTime: 1_592_477_397_000,
                                 updator: "user@kyocera.jp")
    }

    private var job3: JobAPIEntity.Data {
        let parameter = JobAPIEntity.Data.Action.Parameter()
        let action = JobAPIEntity.Data.Action(index: 1,
                                              id: "12cfcc68-634f-41c1-b5fb-e094cafdd512",
                                              parameter: parameter,
                                              _catch: nil,
                                              then: nil)
        return JobAPIEntity.Data(id: "e64f75d2-78b4-47d2-9318-fd370d55c8d1",
                                 name: "LED Flicker Job (YELLOW)",
                                 actions: [action],
                                 entryPoint: 1,
                                 overview: "A job for flickering Raspberry Pi LEDs",
                                 remarks: "The remarks of Job 3",
                                 requirements: nil,
                                 version: 1,
                                 createTime: 1_592_477_337_000,
                                 creator: "user@kyocera.jp",
                                 updateTime: 1_592_477_337_000,
                                 updator: "user@kyocera.jp")
    }

    private var tasks: [TaskAPIEntity.Data] {
        [task1, task2]
    }

    private var task1: TaskAPIEntity.Data {
        return TaskAPIEntity.Data(id: "091bf5e2-d3e4-4426-a36b-8554d68f1167",
                                  jobId: "e64f75d2-78b4-47d2-9318-fd370d55c8d1",
                                  robotIds: ["6592c2a4-3688-49c5-ac1e-4763c81680e4", "78abfbd4-6613-42a6-a691-23c3748fa346"],
                                  start: TaskAPIEntity.Data.Start(condition: "immediately"),
                                  exit: TaskAPIEntity.Data.Exit(
                                    condition: "specifiedNumberOfTimes",
                                    option: TaskAPIEntity.Data.Exit.Option(numberOfRuns: 5)),
                                  job: job1,
                                  version: 1,
                                  createTime: 1_601_165_183_557,
                                  creator: "e2e_test_account",
                                  updateTime: 1_601_165_183_557,
                                  updator: "e2e_test_account")

    }

    private var task2: TaskAPIEntity.Data {
        return TaskAPIEntity.Data(id: "f83e50ac-22f8-11eb-adc1-0242ac120002",
                                  jobId: "e64f75d2-78b4-47d2-9318-fd370d55c8d1",
                                  robotIds: ["9f31a3bd-3138-56b2-1a1e-2769356f80e4", "c8abfad4-1219-4aa6-d691-13c3748ea322"],
                                  start: TaskAPIEntity.Data.Start(condition: "immediately"),
                                  exit: TaskAPIEntity.Data.Exit(
                                    condition: "specifiedNumberOfTimes",
                                    option: TaskAPIEntity.Data.Exit.Option(numberOfRuns: 30)),
                                  job: job2,
                                  version: 1,
                                  createTime: 1_602_765_183_557,
                                  creator: "e2e_test_account",
                                  updateTime: 1_602_765_183_557,
                                  updator: "e2e_test_account")
    }

    private var task3: TaskAPIEntity.Data {
        return TaskAPIEntity.Data(id: "f83e50ac-22f8-11eb-adc1-0242ac120002",
                                  jobId: "e64f75d2-78b4-47d2-9318-fd370d55c8d1",
                                  robotIds: ["9f31a3bd-3138-56b2-1a1e-2769356f80e4", "c8abfad4-1219-4aa6-d691-13c3748ea322"],
                                  start: TaskAPIEntity.Data.Start(condition: "immediately"),
                                  exit: TaskAPIEntity.Data.Exit(
                                    condition: "specifiedNumberOfTimes",
                                    option: TaskAPIEntity.Data.Exit.Option(numberOfRuns: 5)),
                                  job: job3,
                                  version: 1,
                                  createTime: 1_592_477_337_000,
                                  creator: "user@kyocera.jp",
                                  updateTime: 1_592_477_337_000,
                                  updator: "user@kyocera.jp")
    }

    private var actionLibraries: [ActionLibraryAPIEntity.Data] {
        [actionLibrary1]
    }

    private var actionLibrary1: ActionLibraryAPIEntity.Data {
        return ActionLibraryAPIEntity.Data(id: "30cf3116-c823-4093-a62d-4fe07c81ffff",
                                           name: "LED Flicker (RED)",
                                           requirements: nil,
                                           imagePath: "30cf3116-c823-4093-a62d-4fe07c81ffff/raspberry-pi.jpg",
                                           overview: "A library for flickering Raspberry Pi LEDs.",
                                           remarks: "LED module is required to use.",
                                           version: 1,
                                           createTime: 1_592_477_377_000,
                                           creator: "user@kyocera.jp",
                                           updateTime: 1_592_477_377_000,
                                           updator: "user@kyocera.jp")
    }

    private var aiLibraries: [AILibraryAPIEntity.Data] {
        [aiLibrary1, aiLibrary2]
    }

    private var aiLibrary1: AILibraryAPIEntity.Data {
        return AILibraryAPIEntity.Data(id: "19ae9914-acb5-4e6e-ab11-52a20d8952f2",
                                       name: "Gear",
                                       type: "recognition-workbench",
                                       requirements: nil,
                                       imagePath: "19ae9914-acb5-4e6e-ab11-52a20d8952f2/industrial.png",
                                       overview: "This library is a recognition of 'Gear' used to detect a workobject.",
                                       remarks: "The remarks of Gear Recognize Library.",
                                       version: 1,
                                       createTime: 1_592_477_167_000,
                                       creator: "user@kyocera.jp",
                                       updateTime: 1_592_477_167_000,
                                       updator: "user@kyocera.jp")
    }

    private var aiLibrary2: AILibraryAPIEntity.Data {
        return AILibraryAPIEntity.Data(id: "657BACA4-8273-45CF-8D8F-223847B38F2F",
                                       name: "Boxes",
                                       type: "recognition-workbench",
                                       requirements: nil,
                                       imagePath: "657BACA4-8273-45CF-8D8F-223847B38F2F/box.svg",
                                       overview: "This library is a recognition of 'Box' used to select a workobject.",
                                       remarks: "The remarks of Box Recognize Library.",
                                       version: 1,
                                       createTime: 1_592_477_327_000,
                                       creator: "user@kyocera.jp",
                                       updateTime: 1_592_477_327_000,
                                       updator: "user@kyocera.jp")
    }
}
