//
//  ConnectionSettingsPresenter.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/03/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Domain
import JobOrder_Utility

// MARK: - Interface
/// ConnectionSettingsPresenterProtocol
/// @mockable
protocol ConnectionSettingsPresenterProtocol {
    /// Resetボタンをタップ
    func tapResetButton()
}

// MARK: - Implementation
/// ConnectionSettingsPresenter
class ConnectionSettingsPresenter {

    /// AuthenticationUseCaseProtocol
    private let authUseCase: JobOrder_Domain.AuthenticationUseCaseProtocol
    /// SettingsUseCaseProtocol
    private var settingsUseCase: JobOrder_Domain.SettingsUseCaseProtocol
    /// ConnectionSettingsViewControllerProtocol
    private let vc: ConnectionSettingsViewControllerProtocol
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []

    /// イニシャライザ
    /// - Parameters:
    ///   - authUseCase: AuthenticationUseCaseProtocol
    ///   - settingsUseCase: SettingsUseCaseProtocol
    ///   - vc: ConnectionSettingsViewControllerProtocol
    required init(authUseCase: JobOrder_Domain.AuthenticationUseCaseProtocol,
                  settingsUseCase: JobOrder_Domain.SettingsUseCaseProtocol,
                  vc: ConnectionSettingsViewControllerProtocol) {
        self.authUseCase = authUseCase
        self.settingsUseCase = settingsUseCase
        self.vc = vc
    }
}

// MARK: - Protocol Function
extension ConnectionSettingsPresenter: ConnectionSettingsPresenterProtocol {

    /// Resetボタンタップ
    func tapResetButton() {
        settingsUseCase.spaceName = nil

        guard authUseCase.isSignedIn else {
            self.vc.back()
            return
        }

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
                self.vc.back()
            }).store(in: &cancellables)
    }
}
