//
//  NewPasswordRequiredPresenter.swift
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
/// NewPasswordRequiredPresenterProtocol
/// @mockable
protocol NewPasswordRequiredPresenterProtocol {
    /// Updateボタンの有効無効
    var isEnabledUpdateButton: Bool { get }
    /// Updateボタンをタップ
    func tapUpdateButton()
    /// パスワード変更
    /// - Parameter password: パスワード
    func changedPasswordTextField(_ password: String?)
}

// MARK: - Implementation
/// NewPasswordRequiredPresenter
class NewPasswordRequiredPresenter {

    /// AuthenticationUseCaseProtocol
    private let useCase: JobOrder_Domain.AuthenticationUseCaseProtocol
    /// NewPasswordRequiredViewControllerProtocol
    private let vc: NewPasswordRequiredViewControllerProtocol
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// パスワード
    private var password: String?

    /// イニシャライザ
    /// - Parameters:
    ///   - useCase: AuthenticationUseCaseProtocol
    ///   - vc: NewPasswordRequiredViewControllerProtocol
    required init(useCase: JobOrder_Domain.AuthenticationUseCaseProtocol,
                  vc: NewPasswordRequiredViewControllerProtocol) {
        self.useCase = useCase
        self.vc = vc
        subscribeUseCaseProcessing()
    }
}

// MARK: - Protocol Function
extension NewPasswordRequiredPresenter: NewPasswordRequiredPresenterProtocol {

    /// Updateボタンの有効無効
    var isEnabledUpdateButton: Bool {
        isEnabled(password)
    }

    /// Updateボタンをタップ
    func tapUpdateButton() {

        guard let password = password, password != "" else {
            return
        }
        if !password.checkPolicy() {
            self.vc.showErrorAlert("パスワードは大文字、小文字、数字、特殊文字を含め、８文字以上で設定して下さい。")
            return
        }

        useCase.confirmSignIn(newPassword: password)
            .receive(on: DispatchQueue.main)
            .map { value -> Bool in
                return value.state == .signedIn
            }.sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(response)")
                if response {
                    self.signOut()
                } else {
                    self.vc.transitionToPasswordAuthenticationScreen()
                }
            }).store(in: &cancellables)
    }

    /// パスワード変更
    /// - Parameter password: パスワード
    func changedPasswordTextField(_ password: String?) {
        self.password = password
    }
}

// MARK: - Private
extension NewPasswordRequiredPresenter {

    func subscribeUseCaseProcessing() {
        // 通信中はキー無効
        // useCase.$processing.sink { response in
        useCase.processingPublisher
            .receive(on: DispatchQueue.main)
            .sink { response in
                Logger.debug(target: self, "Auth: \(response)")
                self.vc.changedProcessing(response)
            }.store(in: &cancellables)
    }

    func signOut() {

        useCase.signOut()
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
                    self.vc.transitionToPasswordAuthenticationScreen()
                } else {
                    // TODO: エラーケース
                }
            }).store(in: &self.cancellables)
    }

    func isEnabled(_ st: String?) -> Bool {
        return st != nil && st != ""
    }
}
