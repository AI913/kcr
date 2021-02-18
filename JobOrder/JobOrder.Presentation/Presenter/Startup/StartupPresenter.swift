//
//  StartupPresenter.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2021/02/04.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Domain
import JobOrder_Utility

// MARK: - Interface
/// StartupPresenterProtocol
/// @mockable
protocol StartupPresenterProtocol {
    /// Nextボタンの有効無効
    var isEnabledNextButton: Bool { get }
    /// Viewの表示開始
    func viewDidAppear()
    /// Nextボタンをタップ
    func tapNextButton()
    /// Space名変更
    /// - Parameter space: テナントコード
    func changedSpaceTextField(_ space: String?)
}

// MARK: - Implementation
/// StartupPresenter
class StartupPresenter {

    /// AuthenticationUseCaseProtocol
    private let authUseCase: JobOrder_Domain.AuthenticationUseCaseProtocol
    /// SettingsUseCaseProtocol
    private var settingsUseCase: JobOrder_Domain.SettingsUseCaseProtocol
    /// StartupViewControllerProtocol
    private let vc: StartupViewControllerProtocol
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// テナントコード
    var space: String?

    /// イニシャライザ
    /// - Parameters:
    ///   - authUseCase: AuthenticationUseCaseProtocol
    ///   - settingsUseCase: SettingsUseCaseProtocol
    ///   - vc: StartupViewControllerProtocol
    required init(authUseCase: JobOrder_Domain.AuthenticationUseCaseProtocol,
                  settingsUseCase: JobOrder_Domain.SettingsUseCaseProtocol,
                  vc: StartupViewControllerProtocol) {
        self.authUseCase = authUseCase
        self.settingsUseCase = settingsUseCase
        self.vc = vc
    }

    /// デイニシャライザ
    deinit {}
}

// MARK: - Protocol Function
extension StartupPresenter: StartupPresenterProtocol {

    /// Nextボタンの有効無効
    var isEnabledNextButton: Bool {
        !(space ?? "").isEmpty
    }

    /// Viewの表示開始
    func viewDidAppear() {
        if let space = settingsUseCase.spaceName {
            readyToConnectServer(space)
        } else {
            vc.showSpaceView()
        }
    }

    /// Nextボタンをタップ
    func tapNextButton() {
        guard let space = space else { return }
        readyToConnectServer(space)
    }

    /// テナントコード変更
    /// - Parameter tenantCode: テナントコード
    func changedSpaceTextField(_ space: String?) {
        self.space = space
    }
}

// MARK: - Private Function
extension StartupPresenter {

    func readyToConnectServer(_ space: String) {
        vc.changedProcessing(true)

        authUseCase.initializeServer(space: space)
            .receive(on: DispatchQueue.main)
            .map { value -> Bool in
                return value.result
            }.sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    Logger.error(target: self, "\(error.localizedDescription)")
                    self.vc.showErrorAlert(error)
                    self.vc.showSpaceView()
                }
                self.vc.changedProcessing(false)
            }, receiveValue: { response in
                Logger.debug(target: self, "\(response)")
                if response {
                    self.vc.launchMain()
                }
            }).store(in: &cancellables)
    }
}
