//
//  Date.swift
//  JobOrder.Utility
//
//  Created by 藤井一暢 on 2020/12/03.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

extension Date {

    public var toDateString: String {
        guard self.timeIntervalSince1970 != 0 else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        return formatter.string(from: self)
    }

    public var toMediumDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

}
