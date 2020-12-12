//
//  APIResult.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

/// APIResult
public struct APIResult<T: Codable>: Codable {

    /// 実行時刻
    public let time: Int
    /// データ
    public let data: T?
    /// 回数
    public let count: Int?
    /// ページング
    public let paging: APIPaging.Output?

    static func == (lhs: APIResult, rhs: APIResult) -> Bool {
        return lhs.time == rhs.time && lhs.count == rhs.count
    }
}
