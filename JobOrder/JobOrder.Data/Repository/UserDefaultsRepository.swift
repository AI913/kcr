//
//  UserDefaultsRepository.swift
//  JobOrder.Data
//
//  Created by Yu Suzuki on 2020/09/01.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

/// UserDefaultsの操作をするプロトコル
/// @mockable
public protocol UserDefaultsRepository {

    /// Int型のデータを取得
    /// - Parameter defaultName: 保存キー
    func integer(forKey defaultName: UserDefaultsKey) -> Int
    /// Bool型のデータを取得
    /// - Parameter defaultName: 保存キー
    func bool(forKey defaultName: UserDefaultsKey) -> Bool
    /// String型のデータを取得
    /// - Parameter defaultName: 保存キー
    func string(forKey defaultName: UserDefaultsKey) -> String?
    /// Int型のデータを保存
    /// - Parameters:
    ///   - value: 保存データ
    ///   - defaultName: 保存キー
    func set(_ value: Int, forKey defaultName: UserDefaultsKey)
    /// Bool型のデータを保存
    /// - Parameters:
    ///   - value: 保存データ
    ///   - defaultName: 保存キー
    func set(_ value: Bool, forKey defaultName: UserDefaultsKey)
    /// String型のデータを保存
    /// - Parameters:
    ///   - value: 保存データ
    ///   - defaultName: 保存キー
    func set(_ value: String?, forKey defaultName: UserDefaultsKey)
}
