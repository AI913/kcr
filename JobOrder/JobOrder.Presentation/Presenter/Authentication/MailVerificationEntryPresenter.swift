//
//  MailVerificationEntryPresenter.swift
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
/// MailVerificationEntryPresenterProtocol
/// @mockable
protocol MailVerificationEntryPresenterProtocol {
    /// ViewData
    var data: AuthenticationViewData? { get }
    /// Sendボタン有効無効
    var isEnabledSendButton: Bool { get }
    /// Sendボタンをタップ
    func tapSendButton()
    /// ユーザーID変更
    /// - Parameter identifier: ユーザーID
    func changedIdentifierTextField(_ identifier: String?)
}

// MARK: - Implementation
/// MailVerificationEntryPresenter
class MailVerificationEntryPresenter {

    /// AuthenticationUseCaseProtocol
    private let useCase: JobOrder_Domain.AuthenticationUseCaseProtocol
    /// MailVerificationEntryViewControllerProtocol
    private let vc: MailVerificationEntryViewControllerProtocol
    /// ViewData
    var data: AuthenticationViewData?
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []

    /// イニシャライザ
    /// - Parameters:
    ///   - useCase: AuthenticationUseCaseProtocol
    ///   - vc: MailVerificationEntryViewControllerProtocol
    required init(useCase: JobOrder_Domain.AuthenticationUseCaseProtocol,
                  vc: MailVerificationEntryViewControllerProtocol) {
        self.useCase = useCase
        self.vc = vc
        subscribeUseCaseProcessing()
    }
}

// MARK: - Protocol Function
extension MailVerificationEntryPresenter: MailVerificationEntryPresenterProtocol {

    /// Sendボタン有効無効
    var isEnabledSendButton: Bool {
        isEnabled(data?.identifier)
    }

    /// Sendボタンをタップ
    func tapSendButton() {
        guard let identifier = data?.identifier, identifier != "" else { return }

        useCase.forgotPassword(identifier: identifier)
            .receive(on: DispatchQueue.main)
            .map { value -> Bool in
                return value.state == .confirmationCodeSent
            }.sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(response)")
                if response {
                    self.vc.transitionToConfirmScreen()
                } else {
                    // TODO: エラーケース
                }
            }).store(in: &cancellables)
    }

    /// ユーザーID変更
    /// - Parameter identifier: ユーザーID
    func changedIdentifierTextField(_ identifier: String?) {
        guard let _ = data else {
            data = AuthenticationViewData(identifier: identifier)
            return
        }
        data?.identifier = identifier
    }
}

// MARK: - Private
extension MailVerificationEntryPresenter {

    private func subscribeUseCaseProcessing() {
        // 通信中はキー無効
        //useCase.$processing.sink { response in
        useCase.processingPublisher
            .receive(on: DispatchQueue.main)
            .sink { response in
                Logger.debug(target: self, "Auth: \(response)")
                self.vc.changedProcessing(response)
            }.store(in: &cancellables)
    }

    func isEnabled(_ st: String?) -> Bool {
        return st != nil && st != ""
    }
}
