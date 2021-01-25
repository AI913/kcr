//
//  APIPaging+Arbitrary.swift
//  JobOrder.APITests
//
//  Created by 藤井一暢 on 2021/01/12.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import JobOrder_API

extension APIPaging.Output: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return APIPaging.Output(page: c.generate(),
                                    size: c.generate(),
                                    totalPages: c.generate(),
                                    totalCount: c.generate())
        }
    }
}
