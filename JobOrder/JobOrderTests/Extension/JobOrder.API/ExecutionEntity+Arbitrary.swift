//
//  ExecutionEntity+Arbitrary.swift
//  JobOrder.APITests
//
//  Created by 藤井一暢 on 2021/01/12.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import JobOrder_API

extension ExecutionEntity.LogData: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let resultGen = Gen<String>.fromElements(of: ["success", "fail"])
            return ExecutionEntity.LogData(taskId: c.generate(using: FakeFactory.shared.uuidStringGen),
                                           robotId: c.generate(using: FakeFactory.shared.uuidStringGen),
                                           id: c.generate(using: FakeFactory.shared.uuidStringGen),
                                           executedAt: c.generate(using: FakeFactory.shared.epochTimeGen),
                                           result: c.generate(using: resultGen),
                                           sequenceNumber: c.generate(),
                                           receivedExecutionReportAt: c.generate(using: FakeFactory.shared.epochTimeGen))
        }
    }
}
