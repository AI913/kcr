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
    /// Data型のデータを取得
    /// - Parameter key: 保存キー
    /// - Returns: 保存データ
    func getData(_ key: KeychainKey) -> Data?
    /// String型のデータを保存
    /// - Parameters:
    ///   - value: 保存データ
    ///   - key: 保存キー
    func set(_ value: String?, key: KeychainKey)
    /// Data型のデータを保存
    /// - Parameters:
    ///   - value: 保存データ
    ///   - key: 保存キー
    func set(_ value: Data?, key: KeychainKey)
}
