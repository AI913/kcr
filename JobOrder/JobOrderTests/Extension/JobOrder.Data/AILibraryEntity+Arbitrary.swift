//
//  AILibraryEntity+Arbitrary.swift
//  JobOrderTests
//
//  Created by 藤井一暢 on 2021/01/13.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import JobOrder_Data

extension AILibraryEntity: Arbitrary {
    public static var arbitrary: Gen<AILibraryEntity> {
        return Gen<AILibraryEntity>.compose { c in
            let requirements = AILibraryRequirement.arbitrary.sample
            let aiLibrary = AILibraryEntity(requirements: requirements)
            aiLibrary.id = c.generate(using: FakeFactory.shared.uuidStringGen)
            aiLibrary.name = c.generate()
            aiLibrary.type = c.generate()
            aiLibrary.imagePath = c.generate()
            aiLibrary.overview = c.generate()
            aiLibrary.remarks = c.generate()
            aiLibrary.version = c.generate()
            aiLibrary.createTime = c.generate(using: FakeFactory.shared.epochTimeGen)
            aiLibrary.creator = c.generate(using: FakeFactory.shared.emailGen)
            aiLibrary.updateTime = c.generate(using: FakeFactory.shared.epochTimeGen)
            aiLibrary.updator = c.generate(using: FakeFactory.shared.emailGen)
            return aiLibrary
        }
    }
}

extension AILibraryRequirement: Arbitrary {
    public static var arbitrary: Gen<AILibraryRequirement> {
        return Gen<AILibraryRequirement>.compose { c in
            let requirement = AILibraryRequirement()
            requirement.id = c.generate(using: FakeFactory.shared.uuidStringGen)
            return requirement
        }
    }
}
