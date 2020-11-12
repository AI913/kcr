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
        return _robot()
    }

    func _robot(id: String = "ac305346-fd81-4cbb-8738-90b025570292", name: String = "Minami\'s Raspberry Pi") -> JobOrder_Domain.DataManageModel.Output.Robot {
        return JobOrder_Domain.DataManageModel.Output.Robot(
            id: id,
            name: name,
            type: "Raspberry Pi",
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
            thingName: Optional("raspberrypi_3"),
            thingArn: "arn:aws:iot:ap-northeast-1:701006255006:thing/raspberrypi_3",
            state: "waiting")
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
            dataVersion: 1,
            createTime: 1_592_617_637_000,
            creator: "user@kyocera.jp",
            updateTime: 1_592_618_421_000,
            updator: "user@kyocera.jp")
    }

    var task: JobOrder_Domain.DataManageModel.Output.Task {
        return _task()
    }

    func _task(jobId: String = "e64f75d2-78b4-47d2-9318-fd370d55c8d1") -> JobOrder_Domain.DataManageModel.Output.Task {
        return JobOrder_Domain.DataManageModel.Output.Task(
            jobId: jobId,
            exit: JobOrder_Domain.DataManageModel.Output.Task.Exit(JobOrder_Domain.DataManageModel.Output.Task.Exit.Option(5)))
    }
}
