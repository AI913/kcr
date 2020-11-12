//
//  UserDefaultsDataStore.swift
//  JobOrder.Data
//
//  Created by Yu Suzuki on 2020/06/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

/// UserDefaultsの操作
public class UserDefaultsDataStore: UserDefaultsRepository {

    /// UserDefaultsProtocol
    var userDefaults: UserDefaultsProtocol = UserDefaults.standard

    public init() {}

    /// Int型のデータを取得
    /// - Parameter defaultName: 保存キー
    /// - Returns: 保存データ
    public func integer(forKey defaultName: UserDefaultsKey) -> Int {
        userDefaults.integer(forKey: defaultName.rawValue)
    }

    /// Bool型のデータを取得
    /// - Parameter defaultName: 保存キー
    /// - Returns: 保存データ
    public func bool(forKey defaultName: UserDefaultsKey) -> Bool {
        userDefaults.bool(forKey: defaultName.rawValue)
    }

    /// String型のデータを取得
    /// - Parameter defaultName: 保存キー
    /// - Returns: 保存データ
    public func string(forKey defaultName: UserDefaultsKey) -> String? {
        userDefaults.string(forKey: defaultName.rawValue)
    }

    /// Int型のデータを保存
    /// - Parameters:
    ///   - value: 保存データ
    ///   - defaultName: 保存キー
    public func set(_ value: Int, forKey defaultName: UserDefaultsKey) {
        userDefaults.set(value, forKey: defaultName.rawValue)
    }

    /// Bool型のデータを保存
    /// - Parameters:
    ///   - value: 保存データ
    ///   - defaultName: 保存キー
    public func set(_ value: Bool, forKey defaultName: UserDefaultsKey) {
        userDefaults.set(value, forKey: defaultName.rawValue)
    }

    /// String型のデータを保存
    /// - Parameters:
    ///   - value: 保存データ
    ///   - defaultName: 保存キー
    public func set(_ value: String?, forKey defaultName: UserDefaultsKey) {
        userDefaults.set(value, forKey: defaultName.rawValue)
    }
}

/// UserDefaultsのキー
public enum UserDefaultsKey: String, CaseIterable {
    /// リストアID
    case restoreIdentifier
    /// 生体認証使用可否
    case useBiometricsAuthentication
    /// 最終更新日
    case lastSynced
    /// Space名
    case space
    /// クラウドサーバー使用可否
    case useCloudServer
    /// サーバーURL
    case serverUrl
    /// RobotAPIの取得時刻
    case robotTimestamp
    /// JobAPIの取得時刻
    case jobTimestamp
    /// ActionLibraryAPIの取得時刻
    case actionLibraryTimestamp
    /// AILibraryAPIの取得時刻
    case aiLibraryTimestamp

    /// キーで取得できるデータがIntegerかどうか
    /// - Returns: 結果
    func isInteger() -> Bool {
        switch self {
        case .robotTimestamp, .jobTimestamp, .actionLibraryTimestamp, .aiLibraryTimestamp, .lastSynced:
            return true
        default:
            return false
        }
    }

    /// キーで取得できるデータがBoolかどうか
    /// - Returns: 結果
    func isBool() -> Bool {
        switch self {
        case .restoreIdentifier, .useBiometricsAuthentication, .useCloudServer:
            return true
        default:
            return false
        }
    }

    /// キーで取得できるデータがStringかどうか
    /// - Returns: 結果
    func isString() -> Bool {
        switch self {
        case .space, .serverUrl:
            return true
        default:
            return false
        }
    }
}

/// @mockable
protocol UserDefaultsProtocol {
    func integer(forKey defaultName: String) -> Int
    func bool(forKey defaultName: String) -> Bool
    func string(forKey defaultName: String) -> String?
    func set(_ value: Int, forKey defaultName: String)
    func set(_ value: Bool, forKey defaultName: String)
    func set(_ value: Any?, forKey defaultName: String)
}

extension UserDefaults: UserDefaultsProtocol {}
