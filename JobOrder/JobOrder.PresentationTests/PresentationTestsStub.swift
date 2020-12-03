//
//  PresentationTestsStub.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/19.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

@testable import JobOrder_Domain

struct PresentationTestsStub {

    var robots: [JobOrder_Domain.DataManageModel.Output.Robot] {
        return [robot1(), robot2(), robot3()]
    }

    func robot1(id: String = "test1", name: String = "test1") -> JobOrder_Domain.DataManageModel.Output.Robot {
        let param = "test1"
        return JobOrder_Domain.DataManageModel.Output.Robot(id: id,
                                                            name: name,
                                                            type: param,
                                                            locale: param,
                                                            isSimulator: false,
                                                            maker: param,
                                                            model: param,
                                                            modelClass: param,
                                                            serial: param,
                                                            overview: param,
                                                            remarks: param,
                                                            version: 1,
                                                            createTime: 1,
                                                            creator: param,
                                                            updateTime: 1,
                                                            updator: param,
                                                            thingName: param,
                                                            thingArn: param,
                                                            state: param)
    }

    func robot2(id: String = "test2", name: String = "test2") -> JobOrder_Domain.DataManageModel.Output.Robot {
        let param = "test2"
        return JobOrder_Domain.DataManageModel.Output.Robot(id: id,
                                                            name: name,
                                                            type: param,
                                                            locale: param,
                                                            isSimulator: false,
                                                            maker: param,
                                                            model: param,
                                                            modelClass: param,
                                                            serial: param,
                                                            overview: param,
                                                            remarks: param,
                                                            version: 1,
                                                            createTime: 1,
                                                            creator: param,
                                                            updateTime: 1,
                                                            updator: param,
                                                            thingName: param,
                                                            thingArn: param,
                                                            state: param)
    }

    func robot3(id: String = "test3", name: String = "test3") -> JobOrder_Domain.DataManageModel.Output.Robot {
        let param = "test3"
        return JobOrder_Domain.DataManageModel.Output.Robot(id: id,
                                                            name: name,
                                                            type: param,
                                                            locale: param,
                                                            isSimulator: false,
                                                            maker: param,
                                                            model: param,
                                                            modelClass: param,
                                                            serial: param,
                                                            overview: param,
                                                            remarks: param,
                                                            version: 1,
                                                            createTime: 1,
                                                            creator: param,
                                                            updateTime: 1,
                                                            updator: param,
                                                            thingName: param,
                                                            thingArn: param,
                                                            state: param)
    }

    var robot: JobOrder_Domain.DataManageModel.Output.Robot {
        return robot1()
    }

    var jobs: [JobOrder_Domain.DataManageModel.Output.Job] {
        return [job1(), job2(), job3()]
    }

    func job1(id: String = "test1", name: String = "test1") -> JobOrder_Domain.DataManageModel.Output.Job {
        let param = "test1"
        return JobOrder_Domain.DataManageModel.Output.Job(id: id,
                                                          name: name,
                                                          actions: [],
                                                          entryPoint: 1,
                                                          overview: param,
                                                          remarks: param,
                                                          requirements: param,
                                                          version: 1,
                                                          createTime: 1,
                                                          creator: param,
                                                          updateTime: 1,
                                                          updator: param)
    }

    func job2(id: String = "test2", name: String = "test2") -> JobOrder_Domain.DataManageModel.Output.Job {
        let param = "test2"
        return JobOrder_Domain.DataManageModel.Output.Job(id: id,
                                                          name: name,
                                                          actions: [],
                                                          entryPoint: 1,
                                                          overview: param,
                                                          remarks: param,
                                                          requirements: param,
                                                          version: 1,
                                                          createTime: 1,
                                                          creator: param,
                                                          updateTime: 1,
                                                          updator: param)
    }

    func job3(id: String = "test3", name: String = "test3") -> JobOrder_Domain.DataManageModel.Output.Job {
        let param = "test3"
        return JobOrder_Domain.DataManageModel.Output.Job(id: id,
                                                          name: name,
                                                          actions: [],
                                                          entryPoint: 1,
                                                          overview: param,
                                                          remarks: param,
                                                          requirements: param,
                                                          version: 1,
                                                          createTime: 1,
                                                          creator: param,
                                                          updateTime: 1,
                                                          updator: param)
    }

    var commands: [JobOrder_Domain.DataManageModel.Output.Command] {
        return [command5(), command1(), command3(), command4(), command2()]
    }

    var commands2: [JobOrder_Domain.DataManageModel.Output.Command] {
        []
    }

    var commands3: [JobOrder_Domain.DataManageModel.Output.Command] {
        [command1(taskId: "091bf5e2-d3e4-4426-a36b-8554d68f1167")]
    }

    func command1(taskId: String = "54b50d1e-a4a6-435e-9a38-0eaa91aa2559", robotId: String = "78abfbd4-6613-42a6-a691-23c3748fa346") -> JobOrder_Domain.DataManageModel.Output.Command {
        return JobOrder_Domain.DataManageModel.Output.Command(taskId: taskId,
                                                              robotId: robotId,
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
                                                              robot: DataManageModel.Output.Robot(id: "", name: "", type: "", locale: "", isSimulator: false, maker: "", model: "", modelClass: "", serial: "", overview: "", remarks: "", version: 0, createTime: 0, creator: "", updateTime: 0, updator: "", thingName: "", thingArn: "", state: "") ,
                                                              dataVersion: 1,
                                                              createTime: 1_592_617_637_000,
                                                              creator: "user@kyocera.jp",
                                                              updateTime: 1_592_618_421_000,
                                                              updator: "user@kyocera.jp")
    }
    func command2(taskId: String = "1528f46e-f33e-11ea-adc1-0242ac120002", robotId: String = "78abfbd4-6613-42a6-a691-23c3748fa346") -> JobOrder_Domain.DataManageModel.Output.Command {
        return JobOrder_Domain.DataManageModel.Output.Command(taskId: taskId,
                                                              robotId: robotId,
                                                              started: 1_592_620_113_000,
                                                              exited: 0,
                                                              execDuration: 0,
                                                              receivedStartReort: 1_592_620_112_000,
                                                              receivedExitReort: 0,
                                                              status: "processing",
                                                              resultInfo: "",
                                                              success: 21,
                                                              fail: 0,
                                                              error: 0,
                                                              robot: DataManageModel.Output.Robot(id: "", name: "", type: "", locale: "", isSimulator: false, maker: "", model: "", modelClass: "", serial: "", overview: "", remarks: "", version: 0, createTime: 0, creator: "", updateTime: 0, updator: "", thingName: "", thingArn: "", state: "") ,
                                                              dataVersion: 1,
                                                              createTime: 1_592_617_637_000,
                                                              creator: "user@kyocera.jp",
                                                              updateTime: 1_592_618_421_000,
                                                              updator: "user@kyocera.jp")
    }
    func command3(taskId: String = "1528f662-f33e-11ea-adc1-0242ac120002", robotId: String = "78abfbd4-6613-42a6-a691-23c3748fa346") -> JobOrder_Domain.DataManageModel.Output.Command {
        return JobOrder_Domain.DataManageModel.Output.Command(taskId: taskId,
                                                              robotId: robotId,
                                                              started: 1_592_619_013_000,
                                                              exited: 0,
                                                              execDuration: 0,
                                                              receivedStartReort: 1_592_619_012_000,
                                                              receivedExitReort: 0,
                                                              status: "suspended",
                                                              resultInfo: "",
                                                              success: 32,
                                                              fail: 6,
                                                              error: 1,
                                                              robot: DataManageModel.Output.Robot(id: "", name: "", type: "", locale: "", isSimulator: false, maker: "", model: "", modelClass: "", serial: "", overview: "", remarks: "", version: 0, createTime: 0, creator: "", updateTime: 0, updator: "", thingName: "", thingArn: "", state: "") ,
                                                              dataVersion: 1,
                                                              createTime: 1_592_617_637_000,
                                                              creator: "user@kyocera.jp",
                                                              updateTime: 1_592_620_110_000,
                                                              updator: "user@kyocera.jp")
    }
    func command4(taskId: String = "75098344-f3fc-11ea-adc1-0242ac120002", robotId: String = "78abfbd4-6613-42a6-a691-23c3748fa346") -> JobOrder_Domain.DataManageModel.Output.Command {
        return JobOrder_Domain.DataManageModel.Output.Command(taskId: taskId,
                                                              robotId: robotId,
                                                              started: 1_592_660_113_000,
                                                              exited: 1_592_661_502_000,
                                                              execDuration: 1_389_000,
                                                              receivedStartReort: 1_592_660_112_000,
                                                              receivedExitReort: 1_592_661_501_000,
                                                              status: "succeeded",
                                                              resultInfo: "All success",
                                                              success: 73,
                                                              fail: 0,
                                                              error: 0,
                                                              robot: DataManageModel.Output.Robot(id: "", name: "", type: "", locale: "", isSimulator: false, maker: "", model: "", modelClass: "", serial: "", overview: "", remarks: "", version: 0, createTime: 0, creator: "", updateTime: 0, updator: "", thingName: "", thingArn: "", state: "") ,
                                                              dataVersion: 1,
                                                              createTime: 1_592_617_637_000,
                                                              creator: "user@kyocera.jp",
                                                              updateTime: 1_592_661_502_000,
                                                              updator: "user@kyocera.jp")
    }
    func command5(taskId: String = "75098344-f3fc-11ea-adc1-0242ac120002", robotId: String = "78abfbd4-6613-42a6-a691-23c3748fa346") -> JobOrder_Domain.DataManageModel.Output.Command {
        return JobOrder_Domain.DataManageModel.Output.Command(taskId: taskId,
                                                              robotId: robotId,
                                                              started: 1_591_990_021_000,
                                                              exited: 1_591_996_666_000,
                                                              execDuration: 6_645_000,
                                                              receivedStartReort: 1_591_990_019_000,
                                                              receivedExitReort: 1_591_996_664_000,
                                                              status: "failed",
                                                              resultInfo: "Finished with some fails.",
                                                              success: 70,
                                                              fail: 2,
                                                              error: 0,
                                                              robot: DataManageModel.Output.Robot(id: "", name: "", type: "", locale: "", isSimulator: false, maker: "", model: "", modelClass: "", serial: "", overview: "", remarks: "", version: 0, createTime: 0, creator: "", updateTime: 0, updator: "", thingName: "", thingArn: "", state: "") ,
                                                              dataVersion: 1,
                                                              createTime: 1_591_988_886_000,
                                                              creator: "user@kyocera.jp",
                                                              updateTime: 1_591_996_666_000,
                                                              updator: "user@kyocera.jp")
    }

    var command: JobOrder_Domain.DataManageModel.Output.Command {
        return _command()
    }

    func _command(taskId: String = "54b50d1e-a4a6-435e-9a38-0eaa91aa2559", robotId: String = "78abfbd4-6613-42a6-a691-23c3748fa346") -> JobOrder_Domain.DataManageModel.Output.Command {
        return JobOrder_Domain.DataManageModel.Output.Command(
            taskId: taskId,
            robotId: robotId,
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
            robot: DataManageModel.Output.Robot(id: "", name: "", type: "", locale: "", isSimulator: false, maker: "", model: "", modelClass: "", serial: "", overview: "", remarks: "", version: 0, createTime: 0, creator: "", updateTime: 0, updator: "", thingName: "", thingArn: "", state: "") ,
            dataVersion: 1,
            createTime: 1_592_617_637_000,
            creator: "user@kyocera.jp",
            updateTime: 1_592_618_421_000,
            updator: "user@kyocera.jp")
    }

    var tasks: [JobOrder_Domain.DataManageModel.Output.Task] {
        [task()]
    }

    var tasks2: [JobOrder_Domain.DataManageModel.Output.Task] {
        [task(robotIds: [])]
    }

    var tasks3: [JobOrder_Domain.DataManageModel.Output.Task] {
        [task(robotIds: ["test1"])]
    }

    var tasks4: [JobOrder_Domain.DataManageModel.Output.Task] {
        [task(robotIds: ["test1", "test2", "test3"])]
    }

    var task: JobOrder_Domain.DataManageModel.Output.Task {
        task()
    }

    func task(robotIds: [String] = ["6592c2a4-3688-49c5-ac1e-4763c81680e4", "78abfbd4-6613-42a6-a691-23c3748fa346"]) -> JobOrder_Domain.DataManageModel.Output.Task {
        return JobOrder_Domain.DataManageModel.Output.Task(id: "091bf5e2-d3e4-4426-a36b-8554d68f1167",
                                                           jobId: "e64f75d2-78b4-47d2-9318-fd370d55c8d1",
                                                           robotIds: robotIds,
                                                           exit: JobOrder_Domain.DataManageModel.Output.Task.Exit(
                                                            JobOrder_Domain.DataManageModel.Output.Task.Exit.Option(5)), job: JobOrder_Domain.DataManageModel.Output.Job(id: "", name: "", actions: [], entryPoint: 0, overview: "", remarks: "", requirements: "", version: 0, createTime: 0, creator: "", updateTime: 0, updator: ""),
                                                           createTime: 1_601_165_183_557,
                                                           creator: "user@kyocera.jp",
                                                           updateTime: 1_592_618_421_000,
                                                           updator: "user@kyocera.jp")

    }

    var system: DataManageModel.Output.System {
        let installs = [DataManageModel.Output.System.SoftwareConfiguration.Installed(name: "Common Module",
                                                                                      version: "1.0"),
                        DataManageModel.Output.System.SoftwareConfiguration.Installed(name: "Network Service Module",
                                                                                      version: "1.0"),
                        DataManageModel.Output.System.SoftwareConfiguration.Installed(name: "Action Service Module",
                                                                                      version: "1.0")]
        let sw = DataManageModel.Output.System.SoftwareConfiguration(system: "Linux 4.18", distribution: "Ubuntu 18.04", installs: installs)
        let hw = [DataManageModel.Output.System.HardwareConfiguration(type: "hand",
                                                                      model: "82635AWGDVKPRQ",
                                                                      maker: "Kyocera Corporation",
                                                                      serialNo: "f97f805dd3f3"),
                  DataManageModel.Output.System.HardwareConfiguration(type: "camera",
                                                                      model: "82635AWGDVKPRQ",
                                                                      maker: "Intel Corporation",
                                                                      serialNo: "f97f805dd3f3")]
        return DataManageModel.Output.System(softwareConfiguration: sw, hardwareConfigurations: hw)
    }
}
