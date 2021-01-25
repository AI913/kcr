//
//  APIResult+Arbitrary.swift
//  JobOrder.APITests
//
//  Created by 藤井一暢 on 2021/01/12.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import JobOrder_API

/// Conditional Conformance Problems https://forums.swift.org/t/conditional-conformance-problems/19633
extension APIResult: Arbitrary {}

extension APIResult {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return APIResult(time: 0, data: nil, count: nil, paging: nil)
        }
    }
}

// MARK: - ActionLibrary情報
extension APIResult where T == [ActionLibraryAPIEntity.Data] {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let time = FakeFactory.shared.epochTimeGen.generate
            let data = ActionLibraryAPIEntity.Data.arbitrary.sample
            let count = data.count
            return APIResult(time: time, data: data, count: count, paging: nil)
        }
    }
}

// MARK: - AILibrary情報
extension APIResult where T == [AILibraryAPIEntity.Data] {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let time = FakeFactory.shared.epochTimeGen.generate
            let data = AILibraryAPIEntity.Data.arbitrary.sample
            let count = data.count
            return APIResult(time: time, data: data, count: count, paging: nil)
        }
    }
}

// MARK: - Job情報
extension APIResult where T == [JobAPIEntity.Data] {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let time = FakeFactory.shared.epochTimeGen.generate
            let data = JobAPIEntity.Data.arbitrary.sample
            let count = data.count
            return APIResult(time: time, data: data, count: count, paging: nil)
        }
    }
}

// MARK: - Task情報
extension APIResult where T == [TaskAPIEntity.Data] {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let time = FakeFactory.shared.epochTimeGen.generate
            let data = TaskAPIEntity.Data.arbitrary.sample
            let count = data.count
            return APIResult(time: time, data: data, count: count, paging: nil)
        }
    }
}

extension APIResult where T == TaskAPIEntity.Data {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let time = FakeFactory.shared.epochTimeGen.generate
            let data = TaskAPIEntity.Data.arbitrary.generate
            return APIResult(time: time, data: data, count: nil, paging: nil)
        }
    }
}

// MARK: - Command情報
extension APIResult where T == [CommandEntity.Data] {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let time = FakeFactory.shared.epochTimeGen.generate
            let data = CommandEntity.Data.arbitrary.sample
            let count = data.count
            return APIResult(time: time, data: data, count: count, paging: nil)
        }
    }
}

extension APIResult where T == CommandEntity.Data {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let time = FakeFactory.shared.epochTimeGen.generate
            let data = CommandEntity.Data.arbitrary.generate
            return APIResult(time: time, data: data, count: nil, paging: nil)
        }
    }
}

// MARK: - Robot情報
extension APIResult where T == [RobotAPIEntity.Data] {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let time = FakeFactory.shared.epochTimeGen.generate
            let data = RobotAPIEntity.Data.arbitrary.sample
            let count = data.count
            return APIResult(time: time, data: data, count: count, paging: nil)
        }
    }
}

extension APIResult where T == RobotAPIEntity.Data {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let time = FakeFactory.shared.epochTimeGen.generate
            let data = RobotAPIEntity.Data.arbitrary.generate
            return APIResult(time: time, data: data, count: nil, paging: nil)
        }
    }
}

// MARK: - Robot SW構成情報
extension APIResult where T == RobotAPIEntity.Swconf {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let time = FakeFactory.shared.epochTimeGen.generate
            let data = RobotAPIEntity.Swconf.arbitrary.generate
            return APIResult(time: time, data: data, count: nil, paging: nil)
        }
    }
}

// MARK: - Robot アセット情報
extension APIResult where T == [RobotAPIEntity.Asset] {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let time = FakeFactory.shared.epochTimeGen.generate
            let data = RobotAPIEntity.Asset.arbitrary.sample
            let count = data.count
            return APIResult(time: time, data: data, count: count, paging: nil)
        }
    }
}

// MARK: - Executionログ
extension APIResult where T == [ExecutionEntity.LogData] {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            let time = FakeFactory.shared.epochTimeGen.generate
            let data = ExecutionEntity.LogData.arbitrary.sample
            let count = data.count
            let paging = APIPaging.Output.arbitrary.generate
            return APIResult(time: time, data: data, count: count, paging: paging)
        }
    }
}
