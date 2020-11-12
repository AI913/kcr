//
//  KeychainDataStore.swift
//  JobOrder.Data
//
//  Created by Yu Suzuki on 2020/06/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import UIKit
import KeychainAccess
import JobOrder_Utility

/// KeyChainの操作
public class KeychainDataStore: KeychainRepository {

    public init() {}

    var keychain: KeychainProtocol = getKeychain()

    static func getKeychain() -> Keychain {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let buildId = infoDictionary[kCFBundleIdentifierKey as String] as? String else {
            fatalError("Bundle ID is not found.")
        }
        return Keychain(service: buildId)
    }

    /// String型のデータを取得
    /// - Parameter key: 保存キー
    /// - Returns: 保存データ
    public func getString(_ key: KeychainKey) -> String? {
        keychain[key.key]
    }

    /// String型のデータを保存
    /// - Parameters:
    ///   - value: 保存データ
    ///   - key: 保存キー
    public func set(_ value: String?, key: KeychainKey) {
        keychain[key.key] = value
    }
}

/// Keychainのキー
public enum KeychainKey: String, CaseIterable {

    /// Thing名
    case thingName
    /// 証明書ID
    case certificateId
    /// 証明書ARN
    case certificateArn

    /// キー生成
    public var key: String {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        return (deviceId + self.rawValue).sha512
    }
}

/// @mockable
protocol KeychainProtocol {
    subscript(key: String) -> String? { get set }
}

extension Keychain: KeychainProtocol {}
