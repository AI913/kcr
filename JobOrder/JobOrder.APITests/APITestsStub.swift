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
        return APIResult(time: 1_592_477_407_000, data: jobs, count: 3)
    }

    var robotsResult: APIResult<[RobotAPIEntity.Data]> {
        return APIResult(time: 1_592_477_407_000, data: robots, count: 3)
    }

    var tasksResult: APIResult<[TaskAPIEntity.Data]> {
        return APIResult(time: 1_592_477_407_000, data: commandFromTasks, count: 3)
    }

    var commandsResult: APIResult<[CommandAPIEntity.Data]> {
        return APIResult(time: 1_592_477_407_000, data: commands, count: 2)
    }

    var actionLibrariesResult: APIResult<[ActionLibraryAPIEntity.Data]> {
        return APIResult(time: 1_592_477_407_000, data: actionLibraries, count: 1)
    }

    var aiLibrariesResult: APIResult<[AILibraryAPIEntity.Data]> {
        return APIResult(time: 1_592_477_407_000, data: aiLibraries, count: 2)
    }

    var jobResult: APIResult<JobAPIEntity.Data> {
        return APIResult(time: 1_592_477_407_000, data: job1, count: 1)
    }

    var robotResult: APIResult<RobotAPIEntity.Data> {
        return APIResult(time: 1_592_477_407_000, data: robot1, count: 1)
    }

    var commandResult: APIResult<CommandAPIEntity.Data> {
        return APIResult(time: 1_592_477_407_000, data: command1, count: 1)
    }

    var commandFromTaskResult: APIResult<TaskAPIEntity.Data> {
        return APIResult(time: 1_592_477_407_000, data: c_task1, count: 1)
    }

    var taskResult: APIResult<TaskAPIEntity.Tasks> {
        return APIResult(time: 1_592_477_407_000, data: task1, count: 1)
    }

    var actionLibraryResult: APIResult<ActionLibraryAPIEntity.Data> {
        return APIResult(time: 1_592_477_407_000, data: actionLibrary1, count: 1)
    }

    var aiLibraryResult: APIResult<AILibraryAPIEntity.Data> {
        return APIResult(time: 1_592_477_407_000, data: aiLibrary1, count: 1)
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

    private var commands: [CommandAPIEntity.Data] {
        [command1, command2]
    }

    private var command1: CommandAPIEntity.Data {

        return CommandAPIEntity.Data(taskId: "54b50d1e-a4a6-435e-9a38-0eaa91aa2559",
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

    private var command2: CommandAPIEntity.Data {

        return CommandAPIEntity.Data(taskId: "54b50d1e-a4a6-435e-9a38-0eaa91aa2559",
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

    private var commandFromTasks: [TaskAPIEntity.Data] {
        [c_task1, c_task2, c_task3]
    }

    private var c_task1: TaskAPIEntity.Data {
        let task = CommandAPIEntity.Data(
            taskId: "54b50d1e-a4a6-435e-9a38-0eaa91aa2559",
            robotId: "78abfbd4-6613-42a6-a691-23c3748fa346",
            started: 1_592_620_113_000,
            exited: 1_592_661_502_000,
            execDuration: 41_389_000,
            receivedStartReort: 1_592_652_512_000,
            receivedExitReort: 1_592_693_902_000,
            status: "succeeded",
            resultInfo: "All success",
            success: 73,
            fail: 0,
            error: 0,
            dataVersion: 1,
            createTime: 1_592_477_367_000,
            creator: "user@kyocera.jp",
            updateTime: 1_592_477_367_000,
            updator: "user@kyocera.jp")
        return TaskAPIEntity.Data(command: task)
    }

    private var c_task2: TaskAPIEntity.Data {
        let task = CommandAPIEntity.Data(
            taskId: "54b50d1e-a4a6-435e-9a38-0eaa91aa2559",
            robotId: "78abfbd4-6613-42a6-a691-23c3748fa346",
            started: 1_592_620_113_000,
            exited: 1_592_661_502_000,
            execDuration: 41_389_000,
            receivedStartReort: 1_592_652_512_000,
            receivedExitReort: 1_592_693_902_000,
            status: "succeeded",
            resultInfo: "All success",
            success: 73,
            fail: 0,
            error: 0,
            dataVersion: 1,
            createTime: 1_592_477_367_000,
            creator: "user@kyocera.jp",
            updateTime: 1_592_477_367_000,
            updator: "user@kyocera.jp")
        return TaskAPIEntity.Data(command: task)
    }

    private var c_task3: TaskAPIEntity.Data {
        let task = CommandAPIEntity.Data(
            taskId: "54b50d1e-a4a6-435e-9a38-0eaa91aa2559",
            robotId: "78abfbd4-6613-42a6-a691-23c3748fa346",
            started: 1_592_620_113_000,
            exited: 1_592_661_502_000,
            execDuration: 41_389_000,
            receivedStartReort: 1_592_652_512_000,
            receivedExitReort: 1_592_693_902_000,
            status: "succeeded",
            resultInfo: "All success",
            success: 73,
            fail: 0,
            error: 0,
            dataVersion: 1,
            createTime: 1_592_477_367_000,
            creator: "user@kyocera.jp",
            updateTime: 1_592_477_367_000,
            updator: "user@kyocera.jp")
        return TaskAPIEntity.Data(command: task)
    }

    private var tasks: [TaskAPIEntity.Tasks] {
        [task1, task2, task3]
    }

    private var task1: TaskAPIEntity.Tasks {
        return TaskAPIEntity.Tasks(jobId: "e64f75d2-78b4-47d2-9318-fd370d55c8d1",
                                   exit: TaskAPIEntity.Tasks.Exit(option: TaskAPIEntity.Tasks.Exit.Option(numberOfRuns: 5)))
    }

    private var task2: TaskAPIEntity.Tasks {
        return TaskAPIEntity.Tasks(jobId: "e64f75d2-78b4-47d2-9318-fd370d55c8d1",
                                   exit: TaskAPIEntity.Tasks.Exit(option: TaskAPIEntity.Tasks.Exit.Option(numberOfRuns: 5)))
    }

    private var task3: TaskAPIEntity.Tasks {
        return TaskAPIEntity.Tasks(jobId: "e64f75d2-78b4-47d2-9318-fd370d55c8d1",
                                   exit: TaskAPIEntity.Tasks.Exit(option: TaskAPIEntity.Tasks.Exit.Option(numberOfRuns: 5)))
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
