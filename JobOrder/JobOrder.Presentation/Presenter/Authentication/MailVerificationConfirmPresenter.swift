//
//  MailVerificationConfirmPresenter.swift
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
/// MailVerificationConfirmPresenterProtocol
/// @mockable
protocol MailVerificationConfirmPresenterProtocol {
    /// ViewData
    var data: AuthenticationViewData { get }
    /// ユーザー名
    var username: String? { get }
    /// Updateボタン有効無効
    var isEnabledUpdateButton: Bool { get }
    /// Resendボタンをタップ
    func tapResendButton()
    /// Updateボタンをタップ
    func tapUpdateButton()
    /// 確認コード変更
    /// - Parameter confirmationCode: 確認コード
    func changedConfirmationCodeTextField(_ confirmationCode: String?)
    /// パスワード変更
    /// - Parameter password: パスワード
    func changedPasswordTextField(_ password: String?)
}

// MARK: - Implementation
/// MailVerificationConfirmPresenter
class MailVerificationConfirmPresenter {

    /// AuthenticationUseCaseProtocol
    private let useCase: JobOrder_Domain.AuthenticationUseCaseProtocol
    /// MailVerificationConfirmViewControllerProtocol
    private let vc: MailVerificationConfirmViewControllerProtocol
    /// ViewData
    var data: AuthenticationViewData
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// 確認コード
    private var confirmationCode: String?
    /// パスワード
    private var password: String?

    /// イニシャライザ
    /// - Parameters:
    ///   - useCase: AuthenticationUseCaseProtocol
    ///   - vc: MailVerificationConfirmViewControllerProtocol
    ///   - viewData: AuthenticationViewData
    required init(useCase: JobOrder_Domain.AuthenticationUseCaseProtocol,
                  vc: MailVerificationConfirmViewControllerProtocol,
                  viewData: AuthenticationViewData) {
        self.useCase = useCase
        self.vc = vc
        self.data = viewData
        subscribeUseCaseProcessing()
    }
}

// MARK: - Protocol Function
extension MailVerificationConfirmPresenter: MailVerificationConfirmPresenterProtocol {

    /// ユーザー名
    var username: String? {
        useCase.currentUsername
    }

    /// Updateボタン有効無効
    var isEnabledUpdateButton: Bool {
        isEnabled(data.identifier, password, confirmationCode)
    }

    /// Resendボタンをタップ
    func tapResendButton() {
        guard let identifier = data.identifier, identifier != "" else { return }

        useCase.resendConfirmationCode(identifier: identifier)
            .receive(on: DispatchQueue.main)
            .map { value -> Bool in
                return value.state == .unconfirmed
            }.sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(response)")
                if response {
                    self.vc.showAlert("Resent confirmation code to your email.")
                } else {
                    // TODO: エラーケース
                }
            }).store(in: &cancellables)
    }

    /// Updateボタンをタップ
    func tapUpdateButton() {

        guard let identifier = data.identifier, identifier != "",
              let password = password, password != "",
              let confirmationCode = confirmationCode, confirmationCode != "" else {
            return
        }

        useCase.confirmForgotPassword(identifier: identifier, newPassword: password, confirmationCode: confirmationCode)
            .receive(on: DispatchQueue.main)
            .map { value -> Bool in
                return value.state == .done
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
                    // TODO: エラーケース
                }
            }).store(in: &cancellables)
    }

    /// 確認コード変更
    /// - Parameter confirmationCode: 確認コード
    func changedConfirmationCodeTextField(_ confirmationCode: String?) {
        self.confirmationCode = confirmationCode
    }

    /// パスワード変更
    /// - Parameter password: パスワード
    func changedPasswordTextField(_ password: String?) {
        self.password = password
    }
}

// MARK: - Private
extension MailVerificationConfirmPresenter {

    func subscribeUseCaseProcessing() {
        // 通信中はキー無効
        //useCase.$processing.sink { response in
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
                    self.vc.transitionToCompleteScreen()
                } else {
                    // TODO: エラーケース
                }
            }).store(in: &self.cancellables)
    }

    func isEnabled(_ st1: String?, _ st2: String?, _ st3: String?) -> Bool {
        return st1 != nil && st1 != "" &&
            st2 != nil && st2 != "" &&
            st3 != nil && st3 != ""
    }
}
