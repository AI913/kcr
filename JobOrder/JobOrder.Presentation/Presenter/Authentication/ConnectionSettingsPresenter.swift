//
//  ConnectionSettingsPresenter.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/03/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import JobOrder_Domain

// MARK: - Interface
/// ConnectionSettingsPresenterProtocol
/// @mockable
protocol ConnectionSettingsPresenterProtocol {
    /// Space名登録状態
    var isRegisteredSpace: Bool { get }
    /// Space名取得
    var registeredSpaceName: String? { get }
    /// サーバーURL取得
    var registeredServerUrl: String? { get }
    /// クラウドサーバー使用可否取得
    var registeredUseCloudServer: Bool { get }
    /// Saveボタンの有効無効
    var isEnabledSaveButton: Bool { get }
    /// Saveボタンをタップ
    func tapSaveButton()
    /// Space名変更
    /// - Parameter spaceName: スペース名
    func changedSpaceNameTextField(_ spaceName: String?)
    /// サーバーURL変更
    /// - Parameter serverUrl: サーバーURL
    func changedServerUrlTextField(_ serverUrl: String?)
    /// クラウドサーバー使用可否変更
    /// - Parameter isOn: 使用可否
    func changedUseCloudServerSwitch(_ isOn: Bool)
}

// MARK: - Implementation
/// ConnectionSettingsPresenter
class ConnectionSettingsPresenter {

    /// SettingsUseCaseProtocol
    private var useCase: JobOrder_Domain.SettingsUseCaseProtocol
    /// ConnectionSettingsViewControllerProtocol
    private let vc: ConnectionSettingsViewControllerProtocol
    /// スペース名
    private var spaceName: String?
    /// サーバーURL
    private var serverUrl: String?
    /// クラウドサーバー使用可否
    private var doesUseCloudServer: Bool = false

    /// イニシャライザ
    /// - Parameters:
    ///   - useCase: SettingsUseCaseProtocol
    ///   - vc: ConnectionSettingsViewControllerProtocol
    required init(useCase: JobOrder_Domain.SettingsUseCaseProtocol,
                  vc: ConnectionSettingsViewControllerProtocol) {
        self.useCase = useCase
        self.vc = vc
    }
}

// MARK: - Protocol Function
extension ConnectionSettingsPresenter: ConnectionSettingsPresenterProtocol {

    /// Space登録状態
    var isRegisteredSpace: Bool {
        useCase.spaceName != nil
    }

    /// Space名取得
    var registeredSpaceName: String? {
        spaceName = useCase.spaceName
        return spaceName
    }

    /// サーバーURL取得
    var registeredServerUrl: String? {
        serverUrl = useCase.serverUrl
        return serverUrl
    }

    /// クラウドサーバー使用可否取得
    var registeredUseCloudServer: Bool {
        doesUseCloudServer = useCase.useCloudServer
        return doesUseCloudServer
    }

    /// Saveボタンの有効無効
    var isEnabledSaveButton: Bool {
        return isEnabled(spaceName) && doesUseCloudServer
            || isEnabled(spaceName) && isEnabled(serverUrl) && !doesUseCloudServer
    }

    /// Saveボタンタップ
    func tapSaveButton() {
        useCase.spaceName = spaceName
        useCase.serverUrl = serverUrl
        useCase.useCloudServer = doesUseCloudServer
        vc.back()
    }

    /// Space名変更
    /// - Parameter spaceName: Space名
    func changedSpaceNameTextField(_ spaceName: String?) {
        self.spaceName = spaceName
    }

    /// サーバーURL変更
    /// - Parameter serverUrl: サーバーURL
    func changedServerUrlTextField(_ serverUrl: String?) {
        guard let url = serverUrl,
              let encodedUrlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let _ = URL(string: encodedUrlString) else {
            self.serverUrl = nil
            return
        }
        self.serverUrl = encodedUrlString
    }

    /// クラウドサーバー使用可否変更
    /// - Parameter isOn: 使用可否
    func changedUseCloudServerSwitch(_ isOn: Bool) {
        self.doesUseCloudServer = isOn
    }
}

// MARK: - Private Function
extension ConnectionSettingsPresenter {

    func isEnabled(_ st1: String?) -> Bool {
        return st1 != nil && st1 != ""
    }
}
