//
//  KeychainRepository.swift
//  JobOrder.Data
//
//  Created by Yu Suzuki on 2020/06/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

/// Keychainの操作をするプロトコル
/// @mockable
public protocol KeychainRepository {
    /// String型のデータを取得
    /// - Parameter key: 保存キー
    func getString(_ key: KeychainKey) -> String?
    /// String型のデータを保存
    /// - Parameters:
    ///   - value: 保存データ
    ///   - key: 保存キー
    func set(_ value: String?, key: KeychainKey)
}
