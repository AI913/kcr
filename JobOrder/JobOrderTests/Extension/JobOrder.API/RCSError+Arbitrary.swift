//
//  RCSError+Arbitrary.swift
//  JobOrderTests
//
//  Created by 藤井一暢 on 2021/01/25.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import JobOrder_API

extension RCSError.APIGatewayErrorResponse: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return RCSError.APIGatewayErrorResponse(type: c.generate(),
                                                    resourcePath: c.generate(),
                                                    message: c.generate(),
                                                    details: c.generate())
        }
    }
}

extension RCSError.LamdbaFunctionErrorResponse: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return RCSError.LamdbaFunctionErrorResponse(time: c.generate(),
                                                        errors: c.generate())
        }
    }
}

extension RCSError.LamdbaFunctionErrorResponse.ErrorObject: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { c in
            return RCSError.LamdbaFunctionErrorResponse.ErrorObject(code: c.generate(using: FakeFactory.shared.rcsErrorGen),
                                                                    field: c.generate(),
                                                                    value: c.generate(),
                                                                    description: c.generate())
        }
    }
}
