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
    /// クラウドサーバー使用可否
    var useCloudServer: Bool { get set }
    /// サーバーURL
    var serverUrl: String? { get set }
    /// Thing名
    var thingName: String? { get }
}

// MARK: - Implementation
public class SettingsUseCase: SettingsUseCaseProtocol {

    /// Settingsレポジトリ
    private var repository: JobOrder_Data.SettingsRepository

    public required init(repository: JobOrder_Data.SettingsRepository) {
        self.repository = repository
    }

    /// ログインID保存可否
    public var restoreIdentifier: Bool {
        get { return repository.restoreIdentifier }
        set { repository.restoreIdentifier = newValue }
    }

    /// 生体認証使用可否
    public var useBiometricsAuthentication: Bool {
        get { return repository.useBiometricsAuthentication }
        set { repository.useBiometricsAuthentication = newValue }
    }

    /// 最終同期日時
    public var lastSynced: Int? {
        if repository.lastSynced == 0 { return nil }
        return repository.lastSynced
    }

    /// Space名
    public var spaceName: String? {
        get { return repository.space }
        set { repository.space = newValue }
    }

    /// クラウドサーバー使用可否
    public var useCloudServer: Bool {
        get { return repository.useCloudServer }
        set { repository.useCloudServer = newValue }
    }

    /// サーバーURL
    public var serverUrl: String? {
        get { return repository.serverUrl }
        set { repository.serverUrl = newValue }
    }

    /// Thing名
    public var thingName: String? {
        repository.thingName
    }
}
