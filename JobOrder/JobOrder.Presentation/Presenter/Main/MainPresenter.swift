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
    /// View表示開始
    func viewDidAppear()
    /// 生体認証によるサインイン
    func signInByBiometricsAuthentication()
    /// ConnectionStatusボタンをタップ
    func tapConnectionStatusButton()
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
    /// MainTabBarControllerProtocol
    private let vc: MainTabBarControllerProtocol
    /// 接続情報のViewData
    var data = MainViewData.ConnectionInfo(JobOrder_Domain.MQTTModel.Output.ConnectionStatus.unknown)
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// One Off Func
    private let oneOffFunc = OneOffFunc()

    /// イニシャライザ
    /// - Parameters:
    ///   - authUseCase: AuthenticationUseCaseProtocol
    ///   - mqttUseCase: MQTTUseCaseProtocol
    ///   - settingsUseCase: SettingsUseCaseProtocol
    ///   - dataUseCase: DataManageUseCaseProtocol
    ///   - vc: MainTabBarControllerProtocol
    required init(authUseCase: JobOrder_Domain.AuthenticationUseCaseProtocol,
                  mqttUseCase: JobOrder_Domain.MQTTUseCaseProtocol,
                  settingsUseCase: JobOrder_Domain.SettingsUseCaseProtocol,
                  dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: MainTabBarControllerProtocol) {
        self.authUseCase = authUseCase
        self.mqttUseCase = mqttUseCase
        self.settingsUseCase = settingsUseCase
        self.dataUseCase = dataUseCase
        self.vc = vc
        registerStateChanges()
    }

    /// デイニシャライザ
    deinit {
        unregisterStateChanges()
    }
}

// MARK: - Protocol Function
extension MainPresenter: MainPresenterProtocol {

    /// View表示開始
    func viewDidAppear() {
        // 起動時は必ずPasswordAuthentication画面を開く
        oneOffFunc.execute {
            vc.launchPasswordAuthentication()
        }
    }

    /// 生体認証によるサインイン
    func signInByBiometricsAuthentication() {
        afterSignInSequence()
    }

    /// ConnectionStatusボタンをタップ
    func tapConnectionStatusButton() {
        vc.showAlert(L10n.connectionStatus, data.displayName)
    }
}

// MARK: - Private Function
extension MainPresenter {

    private func registerStateChanges() {

        authUseCase.registerAuthenticationStateChange()
            .receive(on: DispatchQueue.main)
            .sink { response in
                Logger.debug(target: self, "authenticationState: \(response)")
                switch response {
                case .signedIn:
                    self.afterSignInSequence()
                case .signedOut, .signedOutUserPoolsTokenInvalid, .signedOutFederatedTokensInvalid:
                    self.vc.launchPasswordAuthentication()
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

    private func unregisterStateChanges() {
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
