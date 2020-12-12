//
//  Int.swift
//  JobOrder.Utility
//
//  Created by 藤井一暢 on 2020/12/03.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

extension Int {

    public var toDateString: String {
        guard self != 0 else { return "" }
        return Date(timeIntervalSince1970: TimeInterval(self)).toDateString
    }

    public var toEpocTime: Date {
        return Date(timeIntervalSince1970: Double(self / 1000))
    }

}
