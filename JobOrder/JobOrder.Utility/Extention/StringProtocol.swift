//
//  StringProtocol.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

extension StringProtocol {

    public func toNsRange(_ range: Range<Index>) -> NSRange {
        return .init(range, in: self)
    }
}
