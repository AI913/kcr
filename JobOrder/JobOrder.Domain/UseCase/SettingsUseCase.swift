//
//  SettingsUseCase.swift
//  JobOrder.Domain
//
//  Created by Kento Tatsumi on 2020/03/08.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import JobOrder_Data

// MARK: - Interface
/// @mockable
public protocol SettingsUseCaseProtocol {
    /// ログインID保存可否
    var restoreIdentifier: Bool { get set }
    /// 生体認証使用可否
    var useBiometricsAuthentication: Bool { get set }
    /// 最終同期日時
    var lastSynced: Int? { get }
    /// Space名
    var spaceName: String? { get set }
    /// Thing名
    var thingName: String? { get }
}

// MARK: - Implementation
public class SettingsUseCase: SettingsUseCaseProtocol {

    /// Settingsレポジトリ
    private var settings: JobOrder_Data.SettingsRepository

    public required init(settingsRepository: JobOrder_Data.SettingsRepository) {
        self.settings = settingsRepository
    }

    /// ログインID保存可否
    public var restoreIdentifier: Bool {
        get { return settings.restoreIdentifier }
        set { settings.restoreIdentifier = newValue }
    }

    /// 生体認証使用可否
    public var useBiometricsAuthentication: Bool {
        get { return settings.useBiometricsAuthentication }
        set { settings.useBiometricsAuthentication = newValue }
    }

    /// 最終同期日時
    public var lastSynced: Int? {
        if settings.lastSynced == 0 { return nil }
        return settings.lastSynced
    }

    /// Space名
    public var spaceName: String? {
        get { return settings.space }
        set { settings.space = newValue }
    }

    /// Thing名
    public var thingName: String? {
        settings.thingName
    }
}
