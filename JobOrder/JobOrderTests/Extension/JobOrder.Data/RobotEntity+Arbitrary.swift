//
//  RobotEntity+Arbitrary.swift
//  JobOrderTests
//
//  Created by 藤井一暢 on 2021/01/13.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import JobOrder_Data

extension RobotEntity: Arbitrary {
    public static var arbitrary: Gen<RobotEntity> {
        let stageGen = Gen<String>.fromElements(of: ["unknown", "terminated", "stopped", "starting", "waiting", "processing"])
        return Gen<RobotEntity>.compose { c in
            let robot = RobotEntity()
            robot.id = c.generate(using: FakeFactory.shared.uuidStringGen)
            robot.name = c.generate()
            robot.type = c.generate()
            robot.locale = c.generate(using: FakeFactory.shared.localeGen)
            robot.isSimulator = c.generate()
            robot.maker = c.generate()
            robot.model = c.generate()
            robot.modelClass = c.generate()
            robot.serial = c.generate()
            robot.overview = c.generate()
            robot.remarks = c.generate()
            robot.version = c.generate()
            robot.createTime = c.generate(using: FakeFactory.shared.epochTimeGen)
            robot.creator = c.generate(using: FakeFactory.shared.emailGen)
            robot.updateTime = c.generate(using: FakeFactory.shared.epochTimeGen)
            robot.updator = c.generate(using: FakeFactory.shared.emailGen)
            robot.thingName = c.generate()
            robot.thingArn = c.generate()
            robot.state = c.generate(using: stageGen)
            return robot
        }
    }
}
