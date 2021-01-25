//
//  JobAPIEntity+Arbitrary.swift
//  JobOrder.APITests
//
//  Created by 藤井一暢 on 2021/01/12.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import JobOrder_API

extension JobAPIEntity.Data: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return JobAPIEntity.Data(id: c.generate(using: FakeFactory.shared.uuidStringGen),
                                     name: c.generate(),
                                     actions: c.generate(),
                                     entryPoint: c.generate(),
                                     overview: c.generate(),
                                     remarks: c.generate(),
                                     requirements: c.generate(),
                                     version: c.generate(),
                                     createTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                     creator: c.generate(using: FakeFactory.shared.emailGen),
                                     updateTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                     updator: c.generate(using: FakeFactory.shared.emailGen))
        }
    }
}

extension JobAPIEntity.Data.Action: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return JobAPIEntity.Data.Action(index: c.generate(),
                                            id: c.generate(using: FakeFactory.shared.uuidStringGen),
                                            parameter: nil,
                                            _catch: c.generate(),
                                            then: c.generate())
        }
    }
}

extension JobAPIEntity.Data.Requirement: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return JobAPIEntity.Data.Requirement()
        }
    }
}
