//
//  JobEntity+Arbitrary.swift
//  JobOrderTests
//
//  Created by 藤井一暢 on 2021/01/13.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import JobOrder_Data

extension JobEntity: Arbitrary {
    public static var arbitrary: Gen<JobEntity> {
        return Gen<JobEntity>.compose { c in
            let actions = JobAction.arbitrary.sample
            let requirements = JobRequirement.arbitrary.sample
            let job = JobEntity(actions: actions, requirements: requirements)
            job.id = c.generate(using: FakeFactory.shared.uuidStringGen)
            job.name = c.generate()
            job.entryPoint = c.generate()
            job.overview = c.generate()
            job.remarks = c.generate()
            job.version = c.generate()
            job.createTime = c.generate(using: FakeFactory.shared.epochTimeGen)
            job.creator = c.generate(using: FakeFactory.shared.emailGen)
            job.updateTime = c.generate(using: FakeFactory.shared.epochTimeGen)
            job.updator = c.generate(using: FakeFactory.shared.emailGen)
            return job
        }
    }
}

extension JobAction: Arbitrary {
    public static var arbitrary: Gen<JobAction> {
        return Gen<JobAction>.compose { c in
            let action = JobAction()
            action.index = c.generate()
            action.id = c.generate(using: FakeFactory.shared.uuidStringGen)
            action._catch = c.generate()
            action.then = c.generate()
            return action
        }
    }
}

extension JobRequirement: Arbitrary {
    public static var arbitrary: Gen<JobRequirement> {
        return Gen<JobRequirement>.compose { c in
            let requirement = JobRequirement()
            requirement.id = c.generate(using: FakeFactory.shared.uuidStringGen)
            return requirement
        }
    }
}
