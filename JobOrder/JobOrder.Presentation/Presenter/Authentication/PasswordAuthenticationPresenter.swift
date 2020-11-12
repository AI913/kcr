//
//  PasswordAuthenticationPresenter.swift
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
/// PasswordAuthenticationPresenterProtocol
/// @mockable
protocol PasswordAuthenticationPresenterProtocol {
    /// ユーザーID保存済
    var isRestoredIdentifier: Bool { get }
    /// ユーザー名
    var username: String? { get }
    /// SignInボタン有効無効
    var isEnabledSignInButton: Bool { get }
    /// 生体認証ボタン有効無効
    var isEnabledBiometricsButton: Bool { get }
    /// Viewの表示開始
    func viewDidAppear()
    /// SignInボタンをタップ
    func tapSignInButton()
    /// 生体認証ボタンをタップ
    func tapBiometricsAuthenticationButton()
    /// ユーザーID変更
    /// - Parameter identifier: ユーザーID
    func changedIdentifierTextField(_ identifier: String?)
    /// パスワード変更
    /// - Parameter password: パスワード
    func changedPasswordTextField(_ password: String?)
}

// MARK: - Implementation
/// PasswordAuthenticationPresenter
class PasswordAuthenticationPresenter {

    /// AuthenticationUseCaseProtocol
    private let useCase: JobOrder_Domain.AuthenticationUseCaseProtocol
    /// SettingsUseCaseProtocol
    private let settingsUseCase: JobOrder_Domain.SettingsUseCaseProtocol
    /// PasswordAuthenticationViewControllerProtocol
    private let vc: PasswordAuthenticationViewControllerProtocol
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// ユーザーID
    private var identifier: String?
    /// パスワード
    private var password: String?
    /// One Off Func
    private let oneOffFunc = OneOffFunc()

    /// イニシャライザ
    /// - Parameters:
    ///   - authUseCase: AuthenticationUseCaseProtocol
    ///   - settingsUseCase: SettingsUseCaseProtocol
    ///   - vc: PasswordAuthenticationViewControllerProtocol
    required init(authUseCase: JobOrder_Domain.AuthenticationUseCaseProtocol,
                  settingsUseCase: JobOrder_Domain.SettingsUseCaseProtocol,
                  vc: PasswordAuthenticationViewControllerProtocol) {
        self.useCase = authUseCase
        self.settingsUseCase = settingsUseCase
        self.vc = vc
        subscribeUseCaseProcessing()
        registerStateChanges()
    }

    /// デイニシャライザ
    deinit {
        unregisterStateChanges()
    }
}

// MARK: - Protocol Function
extension PasswordAuthenticationPresenter: PasswordAuthenticationPresenterProtocol {

    /// ユーザーID保存済
    var isRestoredIdentifier: Bool {
        settingsUseCase.restoreIdentifier
    }

    /// ユーザー名
    var username: String? {
        useCase.currentUsername
    }

    /// SignInボタン有効無効
    var isEnabledSignInButton: Bool {
        isEnabled(identifier, password)
    }

    /// 生体認証ボタン有効無効
    var isEnabledBiometricsButton: Bool {
        return useCase.isSignedIn && settingsUseCase.useBiometricsAuthentication && useCase.canUseBiometricsAuthentication.result
    }

    /// Viewの表示開始
    func viewDidAppear() {

        guard settingsUseCase.spaceName != nil else {
            vc.transitionToConnectionSettings()
            return
        }

        oneOffFunc.execute {
            // サインイン中かつ、生体認証が使える場合は生体認証を実施
            if useCase.isSignedIn &&
                useCase.canUseBiometricsAuthentication.result &&
                settingsUseCase.useBiometricsAuthentication {
                doBiometricsAuthentication()
            }
        }
    }

    /// SignInボタンをタップ
    func tapSignInButton() {

        guard let identifier = identifier, identifier != "",
              let password = password, password != "" else {
            return
        }

        useCase.signIn(identifier: identifier, password: password)
            .receive(on: DispatchQueue.main)
            .map { value -> JobOrder_Domain.AuthenticationModel.Output.SignInResult.State in
                return value.state
            }.sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                switch response {
                case .signedIn:
                    self.vc.dismiss()
                case .newPasswordRequired:
                    self.vc.transitionToNewPasswordRequiredScreen()
                default:
                    // TODO: エラーケース
                    break
                }
            }).store(in: &cancellables)
    }

    /// 生体認証ボタンをタップ
    func tapBiometricsAuthenticationButton() {
        doBiometricsAuthentication()
    }

    /// ユーザーID変更
    /// - Parameter identifier: ユーザーID
    func changedIdentifierTextField(_ identifier: String?) {
        self.identifier = identifier
    }

    /// パスワード変更
    /// - Parameter password: パスワード
    func changedPasswordTextField(_ password: String?) {
        self.password = password
    }
}

// MARK: - Private Function
extension PasswordAuthenticationPresenter {

    private func subscribeUseCaseProcessing() {
        // 通信中はキー無効
        // useCase.$processing.sink { response in
        useCase.processingPublisher
            .receive(on: DispatchQueue.main)
            .sink { response in
                self.vc.changedProcessing(response)
            }.store(in: &cancellables)
    }

    private func registerStateChanges() {

        useCase.registerAuthenticationStateChange()
            .receive(on: DispatchQueue.main)
            .map { value -> Bool in
                return value == .signedIn || value == .unknown
            }.sink { response in
                if !response {
                    self.identifier = nil
                    self.password = nil
                    self.vc.changedProcessing(false)
                }
            }.store(in: &cancellables)
    }

    private func unregisterStateChanges() {
        useCase.unregisterAuthenticationStateChange()
    }

    private func doBiometricsAuthentication() {

        useCase.biometricsAuthentication()
            .receive(on: DispatchQueue.main)
            .map { value -> Bool in
                return value.result
            }.sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    // TODO: エラーケース
                    Logger.error(target: self, "\(error.localizedDescription)")
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(response)")
                if response {
                    self.vc.dismissByBiometricsAuthentication()
                } else {
                    // TODO: エラーケース
                }
            }).store(in: &cancellables)
    }

    func isEnabled(_ st1: String?, _ st2: String?) -> Bool {
        return st1 != nil && st1 != "" && st2 != nil && st2 != ""
    }

    func validate(password: String) -> Bool {
        if password.count < 8 { return false }
        let decimalDigits = password.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let uppeercase = password.components(separatedBy: CharacterSet.uppercaseLetters.inverted).joined()
        let lowercase = password.components(separatedBy: CharacterSet.lowercaseLetters.inverted).joined()
        let punctuationCharacter = password.components(separatedBy: CharacterSet.punctuationCharacters.inverted).joined()
        return !decimalDigits.isEmpty && !uppeercase.isEmpty && !lowercase.isEmpty && !punctuationCharacter.isEmpty
    }
}
