//
//  SettingsDataStore.swift
//  JobOrder.Data
//
//  Created by Kento Tatsumi on 2020/03/07.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

/// アプリの設定を操作する
public class SettingsDataStore: SettingsRepository {

    /// UserDefaultsRepository
    private var ud: UserDefaultsRepository
    /// KeychainProtocol
    private var kc: KeychainRepository

    public init(ud: UserDefaultsRepository, keychain: KeychainRepository) {
        self.ud = ud
        self.kc = keychain
    }

    /// ログインID保存可否
    public var restoreIdentifier: Bool {
        get { ud.bool(forKey: .restoreIdentifier) }
        set { ud.set(newValue, forKey: .restoreIdentifier) }
    }

    /// 生体認証使用可否
    public var useBiometricsAuthentication: Bool {
        get { ud.bool(forKey: .useBiometricsAuthentication) }
        set { ud.set(newValue, forKey: .useBiometricsAuthentication) }
    }

    /// 最終同期日時
    public var lastSynced: Int {
        get { ud.integer(forKey: .lastSynced) }
        set { ud.set(newValue, forKey: .lastSynced) }
    }

    /// Space名
    public var space: String? {
        get {
            if let s = ud.string(forKey: .space), s == "" { return nil }
            return ud.string(forKey: .space)
        }
        set { ud.set(newValue, forKey: .space) }
    }

    /// Thing名
    public var thingName: String? { kc.getString(.thingName) }

    /// Server Confugurationデータ
    public var serverConfiguration: Data? {
        get { kc.getData(.serverConfiguration) }
        set { kc.set(newValue, key: .serverConfiguration) }
    }
}
