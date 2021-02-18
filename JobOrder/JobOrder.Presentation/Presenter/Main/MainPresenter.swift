//
//  MainPresenter.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/03/25.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Domain
import JobOrder_Utility

// MARK: - Interface
/// MainPresenterProtocol
/// @mockable
protocol MainPresenterProtocol {
    /// 右上のラベル
    var rightBarLabel: String? { get }
    /// View表示開始
    func viewDidLoad()
    /// サインイン
    func signIn()
    /// 行動解析エンドポイントプロファイルの設定
    /// - Parameter displayAppearance: 表示モード
    func setAnalyticsEndpointProfiles(displayAppearance: String)
    /// ConnectionStatusボタンをタップ
    func tapConnectionStatusButton()
    /// addButtonボタンをタップ
    func tapAddButton()
}

// MARK: - Implementation
/// MainPresenter
class MainPresenter {

    /// AuthenticationUseCaseProtocol
    private let authUseCase: JobOrder_Domain.AuthenticationUseCaseProtocol
    /// MQTTUseCaseProtocol
    private let mqttUseCase: JobOrder_Domain.MQTTUseCaseProtocol
    /// SettingsUseCaseProtocol
    private let settingsUseCase: JobOrder_Domain.SettingsUseCaseProtocol
    /// DataManageUseCaseProtocol
    private let dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// AnalyticsUseCaseProtocol
    private let analyticsUseCase: JobOrder_Domain.AnalyticsUseCaseProtocol
    /// MainTabBarControllerProtocol
    private let vc: MainTabBarControllerProtocol
    /// 接続情報のViewData
    var data = MainViewData.ConnectionInfo(JobOrder_Domain.MQTTModel.Output.ConnectionStatus.unknown)
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []

    /// イニシャライザ
    /// - Parameters:
    ///   - authUseCase: AuthenticationUseCaseProtocol
    ///   - mqttUseCase: MQTTUseCaseProtocol
    ///   - settingsUseCase: SettingsUseCaseProtocol
    ///   - dataUseCase: DataManageUseCaseProtocol
    ///   - analyticsUseCase: AnalyticsUseCaseProtocol
    ///   - vc: MainTabBarControllerProtocol
    required init(authUseCase: JobOrder_Domain.AuthenticationUseCaseProtocol,
                  mqttUseCase: JobOrder_Domain.MQTTUseCaseProtocol,
                  settingsUseCase: JobOrder_Domain.SettingsUseCaseProtocol,
                  dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  analyticsUseCase: JobOrder_Domain.AnalyticsUseCaseProtocol,
                  vc: MainTabBarControllerProtocol) {
        self.authUseCase = authUseCase
        self.mqttUseCase = mqttUseCase
        self.settingsUseCase = settingsUseCase
        self.dataUseCase = dataUseCase
        self.analyticsUseCase = analyticsUseCase
        self.vc = vc
    }

    /// デイニシャライザ
    deinit {
        unregisterStateChanges()
    }
}

// MARK: - Protocol Function
extension MainPresenter: MainPresenterProtocol {

    /// 右上のラベル
    var rightBarLabel: String? {
        settingsUseCase.spaceName
    }

    /// View表示開始
    func viewDidLoad() {
        vc.launchAuthentication()
    }

    /// サインイン
    func signIn() {
        registerStateChanges()
        afterSignInSequence()
    }

    /// 行動解析エンドポイントプロファイルの設定
    /// - Parameter displayAppearance: 表示モード
    func setAnalyticsEndpointProfiles(displayAppearance: String) {
        analyticsUseCase.setDisplayAppearance(displayAppearance)
        analyticsUseCase.setBiometricsSetting(settingsUseCase.useBiometricsAuthentication)
        if let name = authUseCase.currentUsername {
            analyticsUseCase.setUserName(name)
        }
    }

    /// ConnectionStatusボタンをタップ
    func tapConnectionStatusButton() {
        vc.showAlert(L10n.connectionStatus, data.displayName)
    }

    /// addButtonボタンをタップ
    func tapAddButton() {
        vc.launchJobEntry()
    }
}

// MARK: - Private Function
extension MainPresenter {

    func registerStateChanges() {

        authUseCase.registerAuthenticationStateChange()
            .receive(on: DispatchQueue.main)
            .sink { response in
                Logger.debug(target: self, "authenticationState: \(response)")
                switch response {
                case .signedIn:
                    self.afterSignInSequence()
                case .signedOut, .signedOutUserPoolsTokenInvalid, .signedOutFederatedTokensInvalid:
                    self.vc.launchAuthentication()
                default: break
                }
            }.store(in: &cancellables)

        mqttUseCase.registerConnectionStatusChange()
            .receive(on: DispatchQueue.main)
            .sink { response in
                Logger.debug(target: self, "connectionState: \(response)")
                self.data = MainViewData.ConnectionInfo(response)
                self.vc.updateConnectionStatusButton(color: self.data.color)
            }.store(in: &cancellables)
    }

    func unregisterStateChanges() {
        authUseCase.unregisterAuthenticationStateChange()
    }

    private func afterSignInSequence() {
        sync()
        connectToIotClient()
    }

    func connectToIotClient() {
        if data.status == .connected || data.status == .connecting { return }
        if mqttUseCase.processing { return }

        mqttUseCase.connect()
            .receive(on: DispatchQueue.main)
            .map { value -> Bool in
                return value.result
            }.sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(response)")
                if !response {
                    // TODO: エラーケース
                }
            }).store(in: &cancellables)
    }

    /// 同期を開始
    func sync() {
        dataUseCase.syncData()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                Logger.debug(target: self, "\(completion)")
                switch completion {
                case .finished:
                    self.mqttUseCase.subscribeRobots()
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
