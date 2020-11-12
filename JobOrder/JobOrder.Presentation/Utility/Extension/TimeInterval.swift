//
//  TimeInterval.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/09/01.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

// https://qiita.com/rinov/items/bff12e9ea1251e895306
extension TimeInterval {

    var date: String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .medium
        f.locale = Locale(identifier: "ja_JP")
        let date = Date(timeIntervalSince1970: self / 1000.0)
        return f.string(from: date)
    }
}
