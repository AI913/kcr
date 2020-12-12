//
//  DataTestsStub.swift
//  JobOrder.DataTests
//
//  Created by Yu Suzuki on 2020/08/25.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

@testable import JobOrder_Data

struct DataTestsStub {

    var robots: [RobotEntity] {
        [robot1, robot2, robot3]
    }

    var robot1: RobotEntity {
        let robot = RobotEntity()
        robot.id = "0149308a-af44-4d03-9864-c5ab5561cd91"
        robot.name = "Tatsumi's MacBook Pro"
        robot.type = "PC"
        robot.locale = "ja_JP"
        robot.isSimulator = false
        robot.maker = "Apple"
        robot.model = "MacBookPro15,4"
        robot.modelClass = "MacBook Pro 2019"
        robot.serial = "FVFZM0M8L415"
        robot.overview = ""
        robot.remarks = ""
        robot.version = 1
        robot.createTime = 1_592_477_267_000
        robot.creator = "user@kyocera.jp"
        robot.updateTime = 1_592_477_267_000
        robot.updator = "user@kyocera.jp"
        robot.thingName = "Robot-KC-1"
        robot.thingArn = "arn:aws:iot:ap-northeast-1:701006255006:thing/Robot-KC-1"
        robot.state = "Processing"
        return robot
    }

    var robot2: RobotEntity {
        let robot = RobotEntity()
        robot.id = "ac305346-fd81-4cbb-8738-90b025570292"
        robot.name = "Minami's Raspberry Pi"
        robot.type = "Arm"
        robot.locale = "ja_JP"
        robot.isSimulator = false
        robot.maker = "RS Components Ltd."
        robot.model = "3BPLUS-R"
        robot.modelClass = "Raspberry Pi3 ModelB+"
        robot.serial = "B8AE9C426FC1"
        robot.overview = ""
        robot.remarks = ""
        robot.version = 1
        robot.createTime = 1_592_477_387_000
        robot.creator = "user@kyocera.jp"
        robot.updateTime = 1_592_477_387_000
        robot.updator = "user@kyocera.jp"
        robot.thingName = "Robot-KC-2"
        robot.thingArn = "arn:aws:iot:ap-northeast-1:701006255006:thing/Robot-KC-2"
        robot.state = "Starting"
        return robot
    }

    var robot3: RobotEntity {
        let robot = RobotEntity()
        robot.id = "0c2ede75-65b9-4bce-99d5-a82c2a685655"
        robot.name = "Kanasaki 1"
        robot.type = "Arm"
        robot.locale = "ja_JP"
        robot.isSimulator = true
        robot.maker = "Sample Maker Inc."
        robot.model = "41DA"
        robot.modelClass = "SR-202004"
        robot.serial = "B8AE9C426FC1"
        robot.overview = "The overview of Sample Robot 3."
        robot.remarks = "This remarks of Sample Robot 3."
        robot.version = 1
        robot.createTime = 1_592_477_387_000
        robot.creator = "user@kyocera.jp"
        robot.updateTime = 1_592_477_387_000
        robot.updator = "user@kyocera.jp"
        robot.thingName = "Robot-KC-3"
        robot.thingArn = "arn:aws:iot:ap-northeast-1:701006255006:thing/Robot-KC-3"
        robot.state = "Starting"
        return robot
    }

    var jobs: [JobEntity] {
        [job1, job2, job3]
    }

    var job1: JobEntity {
        let action = JobAction()
        action.index = 1
        action.id = "30cf3116-c823-4093-a62d-4fe07c81ffff"
        // action.parameter = JobParameter()
        action._catch = nil
        action.then = nil

        let job = JobEntity(actions: [action])
        job.id = "8ce74801-1045-4ade-aebf-9fc237acc682"
        job.name = "LED Flicker Job (RED)"
        job.entryPoint = 1
        job.overview = "A job for flickering Raspberry Pi LEDs"
        job.remarks = "The remarks of Job 1"
        job.requirements = nil
        job.version = 1
        job.createTime = 1_592_477_367_000
        job.creator = "user@kyocera.jp"
        job.updateTime = 1_592_477_367_000
        job.updator = "user@kyocera.jp"
        return job
    }

    var job2: JobEntity {
        let action = JobAction()
        action.index = 1
        action.id = "30cf3116-c823-4093-a62d-4fe07c81ffff"
        // action.parameter = JobParameter()
        action._catch = nil
        action.then = nil

        let job = JobEntity(actions: [action])
        job.id = "9da41ec9-d611-42f9-87e7-f929f58917df"
        job.name = "LED Flicker Job (GREEN)"
        job.entryPoint = 1
        job.overview = "A job for flickering Raspberry Pi LEDs"
        job.remarks = "The remarks of Job 2"
        job.requirements = nil
        job.version = 1
        job.createTime = 1_592_477_397_000
        job.creator = "user@kyocera.jp"
        job.updateTime = 1_592_477_397_000
        job.updator = "user@kyocera.jp"
        return job
    }

    var job3: JobEntity {
        let action = JobAction()
        action.index = 1
        action.id = "12cfcc68-634f-41c1-b5fb-e094cafdd512"
        // action.parameter = JobParameter()
        action._catch = nil
        action.then = nil

        let job = JobEntity(actions: [action])
        job.id = "e64f75d2-78b4-47d2-9318-fd370d55c8d1"
        job.name = "LED Flicker Job (YELLOW)"
        job.entryPoint = 1
        job.overview = "A job for flickering Raspberry Pi LEDs"
        job.remarks = "The remarks of Job 3"
        job.requirements = nil
        job.version = 1
        job.createTime = 1_592_477_337_000
        job.creator = "user@kyocera.jp"
        job.updateTime = 1_592_477_337_000
        job.updator = "user@kyocera.jp"
        return job
    }

    var actionLibraries: [ActionLibraryEntity] {
        [actionLibrary1]
    }

    var actionLibrary1: ActionLibraryEntity {
        let actionLibrary = ActionLibraryEntity()
        actionLibrary.id = "30cf3116-c823-4093-a62d-4fe07c81ffff"
        actionLibrary.name = "LED Flicker (RED)"
        actionLibrary.requirements = nil
        actionLibrary.imagePath = "30cf3116-c823-4093-a62d-4fe07c81ffff/raspberry-pi.jpg"
        actionLibrary.overview = "A library for flickering Raspberry Pi LEDs."
        actionLibrary.remarks = "LED module is required to use."
        actionLibrary.version = 1
        actionLibrary.createTime = 1_592_477_377_000
        actionLibrary.creator = "user@kyocera.jp"
        actionLibrary.updateTime = 1_592_477_377_000
        actionLibrary.updator = "user@kyocera.jp"
        return actionLibrary
    }

    var aiLibraries: [AILibraryEntity] {
        [aiLibrary1, aiLibrary2]
    }

    var aiLibrary1: AILibraryEntity {
        let aiLibrary = AILibraryEntity()
        aiLibrary.id = "19ae9914-acb5-4e6e-ab11-52a20d8952f2"
        aiLibrary.name = "Gear"
        aiLibrary.type = "recognition-workbench"
        aiLibrary.requirements = nil
        aiLibrary.imagePath = "19ae9914-acb5-4e6e-ab11-52a20d8952f2/industrial.png"
        aiLibrary.overview = "This library is a recognition of 'Gear' used to detect a workobject."
        aiLibrary.remarks = "The remarks of Gear Recognize Library."
        aiLibrary.version = 1
        aiLibrary.createTime = 1_592_477_167_000
        aiLibrary.creator = "user@kyocera.jp"
        aiLibrary.updateTime = 1_592_477_167_000
        aiLibrary.updator = "user@kyocera.jp"
        return aiLibrary
    }

    var aiLibrary2: AILibraryEntity {
        let aiLibrary = AILibraryEntity()
        aiLibrary.id = "657BACA4-8273-45CF-8D8F-223847B38F2F"
        aiLibrary.name = "Boxes"
        aiLibrary.type = "recognition-workbench"
        aiLibrary.requirements = nil
        aiLibrary.imagePath = "657BACA4-8273-45CF-8D8F-223847B38F2F/box.svg"
        aiLibrary.overview = "This library is a recognition of 'Box' used to select a workbench."
        aiLibrary.remarks = "The remarks of Box Recognize Library."
        aiLibrary.version = 1
        aiLibrary.createTime = 1_592_477_327_000
        aiLibrary.creator = "user@kyocera.jp"
        aiLibrary.updateTime = 1_592_477_327_000
        aiLibrary.updator = "user@kyocera.jp"
        return aiLibrary
    }
}
