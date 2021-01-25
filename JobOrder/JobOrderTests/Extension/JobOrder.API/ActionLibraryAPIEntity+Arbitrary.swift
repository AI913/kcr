//
//  ActionLibraryAPIEntity+Arbitrary.swift
//  JobOrder.APITests
//
//  Created by 藤井一暢 on 2021/01/12.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import JobOrder_API

extension ActionLibraryAPIEntity.Data: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return ActionLibraryAPIEntity.Data(id: c.generate(using: FakeFactory.shared.uuidStringGen),
                                               name: c.generate(),
                                               requirements: c.generate(),
                                               imagePath: c.generate(),
                                               overview: c.generate(),
                                               remarks: c.generate(),
                                               version: c.generate(),
                                               createTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                               creator: c.generate(using: FakeFactory.shared.emailGen),
                                               updateTime: c.generate(using: FakeFactory.shared.epochTimeGen),
                                               updator: c.generate(using: FakeFactory.shared.emailGen))
        }
    }
}

extension ActionLibraryAPIEntity.Data.Requirement: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return ActionLibraryAPIEntity.Data.Requirement()
        }
    }
}
