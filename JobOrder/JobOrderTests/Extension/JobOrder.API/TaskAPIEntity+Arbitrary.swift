//
//  TaskAPIEntity+Arbitrary.swift
//  JobOrder.APITests
//
//  Created by 藤井一暢 on 2021/01/12.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import JobOrder_API

extension TaskAPIEntity.Data: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return TaskAPIEntity.Data(id: c.generate(using: FakeFactory.shared.uuidStringGen),
                                      jobId: c.generate(using: FakeFactory.shared.uuidStringGen),
                                      robotIds: c.generate(using: FakeFactory.shared.uuidStringGen.proliferate),
                                      start: c.generate(),
                                      exit: c.generate(),
                                      job: c.generate(),
                                      version: c.generate(),
                                      createTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                      creator: c.generate(using: FakeFactory.shared.emailGen),
                                      updateTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                      updator: c.generate(using: FakeFactory.shared.emailGen))
        }
    }
}

extension TaskAPIEntity.Start: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let conditionGen = Gen<String>.fromElements(of: ["immediately"])
            return TaskAPIEntity.Start(condition: c.generate(using: conditionGen))
        }
    }
}

extension TaskAPIEntity.Exit: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return TaskAPIEntity.Exit(condition: c.generate(),
                                      option: c.generate())
        }
    }
}

extension TaskAPIEntity.Exit.Option: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return TaskAPIEntity.Exit.Option(numberOfRuns: c.generate())
        }
    }
}
