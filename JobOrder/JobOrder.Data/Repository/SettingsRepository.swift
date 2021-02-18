//
//  SettingsRepository.swift
//  JobOrder.Data
//
//  Created by Kento Tatsumi on 2020/03/08.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

/// アプリの設定を操作する
/// @mockable
public protocol SettingsRepository {
    /// ログインID保存可否
    var restoreIdentifier: Bool { get set }
    /// 生体認証使用可否
    var useBiometricsAuthentication: Bool { get set }
    /// 最終同期日時
    var lastSynced: Int { get set }
    /// Space名
    var space: String? { get set }
    /// Thing名
    var thingName: String? { get }
    /// Server Confugurationデータ
    var serverConfiguration: Data? { get set }
}
