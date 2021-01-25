//
//  RobotAPIEntity+Arbitrary.swift
//  JobOrder.APITests
//
//  Created by 藤井一暢 on 2021/01/12.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import JobOrder_API

extension RobotAPIEntity.Data: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return RobotAPIEntity.Data(id: c.generate(using: FakeFactory.shared.uuidStringGen),
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
                                       awsKey: c.generate())
        }
    }
}

extension RobotAPIEntity.Data.Key: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return RobotAPIEntity.Data.Key(thingName: c.generate(),
                                           thingArn: c.generate())
        }
    }
}

extension RobotAPIEntity.Swconf: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return RobotAPIEntity.Swconf(robotId: c.generate(using: FakeFactory.shared.uuidStringGen),
                                         operatingSystem: c.generate(),
                                         softwares: c.generate(),
                                         dataVersion: c.generate(),
                                         createTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                         creator: c.generate(using: FakeFactory.shared.emailGen),
                                         updateTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                         updator: c.generate(using: FakeFactory.shared.emailGen))
        }
    }
}

extension RobotAPIEntity.Swconf.OperatingSystem: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return RobotAPIEntity.Swconf.OperatingSystem(system: c.generate(),
                                                         systemVersion: c.generate(),
                                                         distribution: c.generate(),
                                                         distributionVersion: c.generate())
        }
    }
}

extension RobotAPIEntity.Swconf.Software: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return RobotAPIEntity.Swconf.Software(swArtifactId: c.generate(),
                                                  softwareId: c.generate(),
                                                  versionId: c.generate(),
                                                  displayName: c.generate(),
                                                  displayVersion: c.generate())
        }
    }
}

extension RobotAPIEntity.Asset: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let typeGen = Gen<String>.fromElements(of: ["hand", "camera"])
            return RobotAPIEntity.Asset(robotId: c.generate(using: FakeFactory.shared.uuidStringGen),
                                        assetId: c.generate(using: FakeFactory.shared.uuidStringGen),
                                        type: c.generate(using: typeGen),
                                        displayMaker: c.generate(),
                                        displayModel: c.generate(),
                                        displayModelClass: c.generate(),
                                        displaySerial: c.generate(),
                                        dataVersion: c.generate(),
                                        createTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                        creator: c.generate(using: FakeFactory.shared.emailGen),
                                        updateTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                        updator: c.generate(using: FakeFactory.shared.emailGen))
        }
    }
}
