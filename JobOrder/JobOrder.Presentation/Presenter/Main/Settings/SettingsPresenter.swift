//
//  SettingsPresenter.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/03/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Domain
import JobOrder_Utility

// MARK: - Interface
/// SettingsPresenterProtocol
/// @mockable
protocol SettingsPresenterProtocol {
    /// リストのセクション数
    var numberOfSections: Int { get }
    /// リストのヘッダータイトル
    /// - Parameter section: セクション番号
    func titleForHeaderInSection(section: Int) -> String
    /// リストのフッタータイトル
    /// - Parameter section: セクション番号
    func titleForFooterInSection(section: Int) -> String
    /// リストのセクション内の行数
    /// - Parameter section: セクション番号
    func numberOfRowsInSection(section: Int) -> Int
    /// ユーザー名
    var username: String? { get }
    /// ログインID保存可否
    var isRestoredIdentifier: Bool { get set }
    /// 生体認証使用可否
    var isUsedBiometricsAuthentication: Bool { get set }
    /// 生体認証有効無効
    var canUseBiometricsWithErrorDescription: (Bool, String?) { get }
    /// 同期した日時
    var syncedDate: String? { get }
    /// Pinpoint のエンドポイントID
    var endpointId: String? { get }
    /// e-mailアドレス
    /// - Parameter completion: クロージャ
    func email(_ completion: @escaping (String?) -> Void)
    /// セル情報を取得
    /// - Parameter indexPath: インデックスパス
    func getRow(indexPath: IndexPath) -> SettingsViewData.SettingsMenu
    /// セルを選択
    /// - Parameter indexPath: インデックスパス
    func selectRow(indexPath: IndexPath)
    /// テーブルの再利用ID
    /// - Parameter indexPath: インデックスパス
    func reusableIdentifier(indexPath: IndexPath) -> String
}

// MARK: - Implementation
/// SettingsPresenter
class SettingsPresenter {

    /// SettingsUseCaseProtocol
    private var useCase: JobOrder_Domain.SettingsUseCaseProtocol
    /// AuthenticationUseCaseProtocol
    private let authUseCase: JobOrder_Domain.AuthenticationUseCaseProtocol
    /// MQTTUseCaseProtocol
    private let mqttUseCase: JobOrder_Domain.MQTTUseCaseProtocol
    /// DataManageUseCaseProtocol
    private let dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// AnalyticsUseCaseProtocol
    private let analyticsUseCase: JobOrder_Domain.AnalyticsUseCaseProtocol
    /// SettingsViewControllerProtocol
    private let vc: SettingsViewControllerProtocol
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []

    /// イニシャライザ
    /// - Parameters:
    ///   - useCase: SettingsUseCaseProtocol
    ///   - authUseCase: AuthenticationUseCaseProtocol
    ///   - mqttUseCase: MQTTUseCaseProtocol
    ///   - dataUseCase: DataManageUseCaseProtocol
    ///   - analyticsUseCase: AnalyticsUseCaseProtocol
    ///   - vc: SettingsViewControllerProtocol
    required init(useCase: JobOrder_Domain.SettingsUseCaseProtocol,
                  authUseCase: JobOrder_Domain.AuthenticationUseCaseProtocol,
                  mqttUseCase: JobOrder_Domain.MQTTUseCaseProtocol,
                  dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  analyticsUseCase: JobOrder_Domain.AnalyticsUseCaseProtocol,
                  vc: SettingsViewControllerProtocol) {
        self.useCase = useCase
        self.authUseCase = authUseCase
        self.mqttUseCase = mqttUseCase
        self.dataUseCase = dataUseCase
        self.analyticsUseCase = analyticsUseCase
        self.vc = vc
        subscribeUseCaseProcessing()
    }
}

// MARK: - Protocol Function
extension SettingsPresenter: SettingsPresenterProtocol {

    /// リストのセクション数
    var numberOfSections: Int {
        SettingsViewData.SettingsMenuSection.allCases.count
    }

    /// リストのヘッダータイトル
    /// - Parameter section: セクション番号
    /// - Returns: タイトル
    func titleForHeaderInSection(section: Int) -> String {
        SettingsViewData.SettingsMenuSection.allCases[section].titleForHeader
    }

    /// リストのフッタータイトル
    /// - Parameter section: セクション番号
    /// - Returns: タイトル
    func titleForFooterInSection(section: Int) -> String {
        SettingsViewData.SettingsMenuSection.allCases[section].titleForFooter
    }

    /// リストのセクション内の行数
    /// - Parameter section: セクション番号
    /// - Returns: 行数
    func numberOfRowsInSection(section: Int) -> Int {
        SettingsViewData.SettingsMenu.allCases.filter { $0.section == SettingsViewData.SettingsMenuSection.allCases[section] }.count
    }

    /// ユーザー名
    var username: String? {
        authUseCase.currentUsername
    }

    /// ログインID保存可否
    var isRestoredIdentifier: Bool {
        get { useCase.restoreIdentifier }
        set {
            let name = SettingsViewData.SettingsMenu.restoreIdentifier.rawValue
            analyticsUseCase.recordEventSwitch(name: name, view: vc.className, isOn: newValue)
            useCase.restoreIdentifier = newValue
        }
    }

    /// 生体認証使用可否
    var isUsedBiometricsAuthentication: Bool {
        get { useCase.useBiometricsAuthentication }
        set {
            let name = SettingsViewData.SettingsMenu.biometricsAuthentication.rawValue
            analyticsUseCase.recordEventSwitch(name: name, view: vc.className, isOn: newValue)
            useCase.useBiometricsAuthentication = newValue
        }
    }

    /// 生体認証有効無効
    var canUseBiometricsWithErrorDescription: (Bool, String?) {
        return (authUseCase.canUseBiometricsAuthentication.result, authUseCase.canUseBiometricsAuthentication.errorDescription)
    }

    /// 同期した日時
    var syncedDate: String? {
        guard let time = useCase.lastSynced else { return nil }
        return TimeInterval(time).date
    }

    /// Pinpoint のエンドポイントID
    var endpointId: String? {
        #if DEBUG
        return analyticsUseCase.endpointId
        #else
        return nil
        #endif
    }

    /// e-mailアドレス
    /// - Parameter completion: クロージャ
    func email(_ completion: @escaping (String?) -> Void) {
        authUseCase.email()
            .receive(on: DispatchQueue.main)
            .map { value -> String? in
                return value.address
            }.sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(String(describing: response))")
                completion(response)
            }).store(in: &cancellables)
    }

    /// セル情報を取得
    /// - Parameter indexPath: インデックスパス
    /// - Returns: セル情報
    func getRow(indexPath: IndexPath) -> SettingsViewData.SettingsMenu {
        return data(indexPath: indexPath)
    }

    /// セルを選択
    /// - Parameter indexPath: インデックスパス
    func selectRow(indexPath: IndexPath) {

        let menu = data(indexPath: indexPath)
        analyticsUseCase.recordEventButton(name: menu.rawValue, view: vc.className)

        switch menu {
        case .signOut:
            signOut()
        case .syncData:
            sync()
        case .robotVideo:
            vc.transitionToRobotVideoScreen()
        case .notification: break
        case .aboutApp:
            vc.transitionToAboutAppScreen()
        default: break
        }
    }

    /// テーブルの再利用ID
    /// - Parameter indexPath: インデックスパス
    /// - Returns: 再利用ID
    func reusableIdentifier(indexPath: IndexPath) -> String {

        let menu = data(indexPath: indexPath)
        switch menu {
        case .restoreIdentifier, .biometricsAuthentication:
            return SettingsMenuTableViewSwitchCell().identifier
        default:
            return SettingsMenuTableViewCell().identifier
        }
    }
}

// MARK: - Private
extension SettingsPresenter {

    private func subscribeUseCaseProcessing() {
        // 通信中はキー無効
        //authUseCase.$processing.sink { response in
        authUseCase.processingPublisher
            .receive(on: DispatchQueue.main)
            .sink { response in
                Logger.debug(target: self, "Auth: \(response)")
                self.vc.changedProcessing(response)
            }.store(in: &cancellables)

        // 通信中はキー無効
        //dataUseCase.$processing.sink { response in
        dataUseCase.processingPublisher
            .receive(on: DispatchQueue.main)
            .sink { response in
                Logger.debug(target: self, "Data: \(response)")
                self.vc.changedProcessing(response)
            }.store(in: &cancellables)
    }

    func signOut() {

        authUseCase.signOut()
            .receive(on: DispatchQueue.main)
            .map { value -> Bool in
                return value.state == .success
            }.sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(response)")
                if response {
                    self.vc.back()
                } else {
                    // TODO: エラーケース
                }
            }).store(in: &cancellables)
    }

    private func data(indexPath: IndexPath) -> SettingsViewData.SettingsMenu {
        return SettingsViewData.SettingsMenu.allCases.filter { $0.section == SettingsViewData.SettingsMenuSection.allCases[indexPath.section] }[indexPath.row]
    }

    /// 同期を開始
    func sync() {
        dataUseCase.syncData()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                Logger.debug(target: self, "\(completion)")
                switch completion {
                case .finished:
                    self.vc.reloadTable()
                    self.mqttUseCase.subscribeRobots()
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
