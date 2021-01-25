//
//  CommandEntity+Arbitrary.swift
//  JobOrder.APITests
//
//  Created by 藤井一暢 on 2021/01/12.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import JobOrder_API

extension CommandEntity.Data: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let statusGen = Gen<String>.fromElements(of: ["unissued", "queued", "processing", "suspended", "succeeded", "failed", "aborted", "canceled", "rejected"])
            return CommandEntity.Data(taskId: c.generate(using: FakeFactory.shared.uuidStringGen),
                                      robotId: c.generate(using: FakeFactory.shared.uuidStringGen),
                                      started: c.generate(using: FakeFactory.shared.epochTimeGen),
                                      exited: c.generate(using: FakeFactory.shared.epochTimeGen),
                                      execDuration: c.generate(),
                                      receivedStartReort: c.generate(using: FakeFactory.shared.epochTimeGen),
                                      receivedExitReort: c.generate(using: FakeFactory.shared.epochTimeGen),
                                      status: c.generate(using: statusGen),
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
}

extension CommandEntity.Data.Robot: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return CommandEntity.Data.Robot(robotInfo: c.generate())
        }
    }
}
