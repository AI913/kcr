//
//  ActionLibraryEntity+Arbitrary.swift
//  JobOrderTests
//
//  Created by 藤井一暢 on 2021/01/13.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import JobOrder_Data

extension ActionLibraryEntity: Arbitrary {
    public static var arbitrary: Gen<ActionLibraryEntity> {
        return Gen<ActionLibraryEntity>.compose { c in
            let requirements = ActionLibraryRequirement.arbitrary.sample
            let actionLibrary = ActionLibraryEntity(requirements: requirements)
            actionLibrary.id = c.generate(using: FakeFactory.shared.uuidStringGen)
            actionLibrary.name = c.generate()
            actionLibrary.imagePath = c.generate()
            actionLibrary.overview = c.generate()
            actionLibrary.remarks = c.generate()
            actionLibrary.version = c.generate()
            actionLibrary.createTime = c.generate(using: FakeFactory.shared.epochTimeGen)
            actionLibrary.creator = c.generate(using: FakeFactory.shared.emailGen)
            actionLibrary.updateTime = c.generate(using: FakeFactory.shared.epochTimeGen)
            actionLibrary.updator = c.generate(using: FakeFactory.shared.emailGen)
            return actionLibrary
        }
    }
}

extension ActionLibraryRequirement: Arbitrary {
    public static var arbitrary: Gen<ActionLibraryRequirement> {
        return Gen<ActionLibraryRequirement>.compose { c in
            let requirement = ActionLibraryRequirement()
            requirement.id = c.generate(using: FakeFactory.shared.uuidStringGen)
            return requirement
        }
    }
}
