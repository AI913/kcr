//
//  AuthenticationUseCase.swift
//  JobOrder.Domain
//
//  Created by Kento Tatsumi on 2020/03/04.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import LocalAuthentication
import JobOrder_API
import JobOrder_Data
import JobOrder_Utility

// MARK: - Interface
/// AuthenticationUseCaseProtocol
/// @mockable
public protocol AuthenticationUseCaseProtocol {
    /// ログイン中のユーザー名
    var currentUsername: String? { get }
    /// サインイン状態
    var isSignedIn: Bool { get }
    /// 生体認証の可否
    var canUseBiometricsAuthentication: AuthenticationModel.Output.BiometricsAuthentication { get }
    /// サインイン状態取得イベントの登録
    func registerAuthenticationStateChange() -> AnyPublisher<AuthenticationModel.Output.AuthenticationState, Never>
    /// サインイン状態取得イベントの解除
    func unregisterAuthenticationStateChange()
    /// 生体認証実施
    func biometricsAuthentication() -> AnyPublisher<AuthenticationModel.Output.BiometricsAuthentication, Error>
    /// サインイン
    func signIn(identifier: String, password: String) -> AnyPublisher<AuthenticationModel.Output.SignInResult, Error>
    /// 新しいパスワードを設定してサインイン
    /// - Parameter newPassword: 新しいパスワード
    func confirmSignIn(newPassword: String) -> AnyPublisher<AuthenticationModel.Output.SignInResult, Error>
    /// サインアウト
    func signOut() -> AnyPublisher<AuthenticationModel.Output.SignOutResult, Error>
    /// パスワードを忘れた場合の処理に遷移要求
    /// - Parameter identifier: ユーザーID
    func forgotPassword(identifier: String) -> AnyPublisher<AuthenticationModel.Output.ForgotPasswordResult, Error>
    /// パスワード再設定要求
    /// - Parameters:
    ///   - identifier: ユーザーID
    ///   - newPassword: 新しいパスワード
    ///   - confirmationCode: 確認コード
    func confirmForgotPassword(identifier: String, newPassword: String, confirmationCode: String) -> AnyPublisher<AuthenticationModel.Output.ForgotPasswordResult, Error>
    /// 確認メール再送信要求
    /// - Parameter identifier: ユーザーID
    func resendConfirmationCode(identifier: String) -> AnyPublisher<AuthenticationModel.Output.SignUpResult, Error>
    /// e-mailアドレス取得
    func email() -> AnyPublisher<AuthenticationModel.Output.Email, Error>

    // var _processing: Published<Bool> { get set }
    var processing: Bool { get }
    var processingPublished: Published<Bool> { get }
    var processingPublisher: Published<Bool>.Publisher { get }
}

// MARK: - Implementation
/// AuthenticationUseCase
public class AuthenticationUseCase: AuthenticationUseCaseProtocol {

    @Published public var processing: Bool = false
    public var processingPublished: Published<Bool> { _processing }
    public var processingPublisher: Published<Bool>.Publisher { $processing }
    /// 生体認証のContext
    var context: LAContextProtocol = LAContext()

    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// Authenticationレポジトリ
    private let auth: JobOrder_API.AuthenticationRepository
    /// MQTTレポジトリ
    private let mqtt: JobOrder_API.MQTTRepository
    /// Settingsレポジトリ
    private var settings: JobOrder_Data.SettingsRepository!
    /// UserDefaultsレポジトリ
    private let ud: JobOrder_Data.UserDefaultsRepository
    /// Keychainレポジトリ
    private let keychain: JobOrder_Data.KeychainRepository
    /// Robotレポジトリ
    private let robotData: JobOrder_Data.RobotRepository
    /// Jobレポジトリ
    private let jobData: JobOrder_Data.JobRepository
    /// Action Libraryレポジトリ
    private let actionLibraryData: JobOrder_Data.ActionLibraryRepository
    /// AI Libraryレポジトリ
    private let aiLibraryData: JobOrder_Data.AILibraryRepository

    /// イニシャライザ
    /// - Parameters:
    ///   - authRepository: Authenticationレポジトリ
    ///   - mqttRepository: MQTTレポジトリ
    ///   - settingsRepository: Settingsレポジトリ
    ///   - userDefaultsRepository: UserDefaultsレポジトリ
    ///   - keychainRepository: Keychainレポジトリ
    ///   - robotDataRepository: Robotレポジトリ
    ///   - jobDataRepository: Jobレポジトリ
    ///   - actionLibraryDataRepository: Action Libraryレポジトリ
    ///   - aiLibraryDataRepository: AI Libraryレポジトリ
    public required init(authRepository: JobOrder_API.AuthenticationRepository,
                         mqttRepository: JobOrder_API.MQTTRepository,
                         settingsRepository: JobOrder_Data.SettingsRepository,
                         userDefaultsRepository: JobOrder_Data.UserDefaultsRepository,
                         keychainRepository: JobOrder_Data.KeychainRepository,
                         robotDataRepository: JobOrder_Data.RobotRepository,
                         jobDataRepository: JobOrder_Data.JobRepository,
                         actionLibraryDataRepository: JobOrder_Data.ActionLibraryRepository,
                         aiLibraryDataRepository: JobOrder_Data.AILibraryRepository) {
        self.auth = authRepository
        self.mqtt = mqttRepository
        self.settings = settingsRepository
        self.ud = userDefaultsRepository
        self.keychain = keychainRepository
        self.robotData = robotDataRepository
        self.jobData = jobDataRepository
        self.actionLibraryData = actionLibraryDataRepository
        self.aiLibraryData = aiLibraryDataRepository
    }

    /// ログイン中のユーザー名
    public var currentUsername: String? {
        return auth.currentUsername
    }

    /// サインイン状態
    public var isSignedIn: Bool {
        return auth.isSignedIn
    }

    /// 生体認証の可否
    public var canUseBiometricsAuthentication: AuthenticationModel.Output.BiometricsAuthentication {
        var error: NSError?
        // https://qiita.com/aokiplayer/items/a43d1b302ea7fba40970
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        let result = canEvaluate || (!canEvaluate && (error?.code == LAError.biometryNotEnrolled.rawValue || error?.code == LAError.biometryLockout.rawValue))
        return AuthenticationModel.Output.BiometricsAuthentication(result: result, errorDescription: error?.localizedDescription)
    }

    /// サインイン状態取得イベントの登録
    /// - Returns: 状態
    public func registerAuthenticationStateChange() -> AnyPublisher<AuthenticationModel.Output.AuthenticationState, Never> {
        Logger.info(target: self)

        let publisher = PassthroughSubject<AuthenticationModel.Output.AuthenticationState, Never>()
        auth.registerUserStateChange()
            .map { value -> AuthenticationModel.Output.AuthenticationState in
                return AuthenticationModel.Output.AuthenticationState(value)
            }.sink { response in
                // Logger.debug(target: self, "\(response)")
                switch response {
                case .signedOut, .signedOutUserPoolsTokenInvalid, .signedOutFederatedTokensInvalid:
                    self.ud.set(0, forKey: .lastSynced)
                    self.robotData.deleteAll()
                    self.jobData.deleteAll()
                    self.actionLibraryData.deleteAll()
                    self.aiLibraryData.deleteAll()
                default: break
                }
                publisher.send(response)
            }.store(in: &self.cancellables)
        return publisher.eraseToAnyPublisher()
    }

    /// サインイン状態取得イベントの解除
    public func unregisterAuthenticationStateChange() {
        Logger.info(target: self)
        auth.unregisterUserStateChange()
    }

    /// 生体認証実施
    /// - Returns: 生体認証の結果
    public func biometricsAuthentication() -> AnyPublisher<AuthenticationModel.Output.BiometricsAuthentication, Error> {
        Logger.info(target: self)

        return Future<AuthenticationModel.Output.BiometricsAuthentication, Error> { promise in
            let reason = "Sign in"
            self.context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { (success, evaluateError) in
                if let error = evaluateError {
                    promise(.failure(JobOrderError(from: error)))
                } else {
                    // 生体認証時はログアウトしないのでRobot稼働状態をクリアする
                    self.robotData.read()?.forEach {
                        self.robotData.update(state: nil, entity: $0)
                    }
                    let model = AuthenticationModel.Output.BiometricsAuthentication(result: success, errorDescription: nil)
                    promise(.success(model))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// サインイン
    /// - Parameters:
    ///   - identifier: ユーザーID
    ///   - password: パスワード
    /// - Returns: サインイン結果
    public func signIn(identifier: String, password: String) -> AnyPublisher<AuthenticationModel.Output.SignInResult, Error> {
        Logger.info(target: self, "ID: \(identifier), Password: ***")

        self.processing = true
        return Future<AuthenticationModel.Output.SignInResult, Error> { promise in
            self.auth.signIn(username: identifier, password: password)
                .map { value -> AuthenticationModel.Output.SignInResult in
                    return AuthenticationModel.Output.SignInResult(value)
                }.sink(receiveCompletion: { completion in
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        promise(.failure(JobOrderError(from: error)))
                    }
                }, receiveValue: { response in
                    // Logger.debug(target: self, "\(response)")
                    promise(.success(response))
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }

    /// 新しいパスワードを設定してサインイン
    /// - Parameter newPassword: 新しいパスワード
    /// - Returns: サインインの結果
    public func confirmSignIn(newPassword: String) -> AnyPublisher<AuthenticationModel.Output.SignInResult, Error> {
        Logger.info(target: self, "Password: ***")

        self.processing = true
        return Future<AuthenticationModel.Output.SignInResult, Error> { promise in
            self.auth.confirmSignIn(newPassword: newPassword)
                .map { value -> AuthenticationModel.Output.SignInResult in
                    return AuthenticationModel.Output.SignInResult(value)
                }.sink(receiveCompletion: { completion in
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        promise(.failure(JobOrderError(from: error)))
                    }
                }, receiveValue: { response in
                    // Logger.debug(target: self, "\(response)")
                    promise(.success(response))
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }

    /// サインアウト
    /// - Returns: サインアウトの結果
    /// - Remark: IoTの証明書類を削除して切断してからサインアウトする
    public func signOut() -> AnyPublisher<AuthenticationModel.Output.SignOutResult, Error> {
        Logger.info(target: self)

        self.processing = true
        return Future<AuthenticationModel.Output.SignOutResult, Error> { promise in
            self.mqtt.disconnectWithCleanUp()
                .flatMap { value -> AnyPublisher<AuthenticationModel.Output.SignOutResult, Error> in
                    guard value.result else {
                        return Future<AuthenticationModel.Output.SignOutResult, Error> { promise in
                            promise(.failure(JobOrderError.connectionFailed(reason: .failToDisconnect)))
                        }.eraseToAnyPublisher()
                    }
                    // UserDefaults, キーチェーンは明示的にサインアウトした場合のみ削除する
                    self.settings.restoreIdentifier = false
                    self.settings.useBiometricsAuthentication = false
                    return self.auth.signOut()
                        .map { value in
                            return AuthenticationModel.Output.SignOutResult(value)
                        }.eraseToAnyPublisher()
                }.sink(receiveCompletion: { completion in
                    // Logger.debug(target: self, "\(completion)")
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        promise(.failure(JobOrderError(from: error)))
                    }
                }, receiveValue: { response in
                    // Logger.debug(target: self, "\(response)")
                    promise(.success(response))
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }

    /// パスワードを忘れた場合の処理に遷移要求
    /// - Parameter identifier: ユーザーID
    /// - Returns: 確認メール送信結果
    public func forgotPassword(identifier: String) -> AnyPublisher<AuthenticationModel.Output.ForgotPasswordResult, Error> {
        Logger.info(target: self, "ID: \(identifier)")

        self.processing = true
        return Future<AuthenticationModel.Output.ForgotPasswordResult, Error> { promise in
            self.auth.forgotPassword(username: identifier)
                .map { value -> AuthenticationModel.Output.ForgotPasswordResult in
                    return AuthenticationModel.Output.ForgotPasswordResult(value)
                }.sink(receiveCompletion: { completion in
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        promise(.failure(JobOrderError(from: error)))
                    }
                }, receiveValue: { response in
                    // Logger.debug(target: self, "\(response)")
                    promise(.success(response))
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }

    /// パスワード再設定要求
    /// - Parameters:
    ///   - identifier: ユーザーID
    ///   - newPassword: 新しいパスワード
    ///   - confirmationCode: 確認コード
    /// - Returns: パスワードを忘れた時の再設定結果
    public func confirmForgotPassword(identifier: String, newPassword: String, confirmationCode: String) -> AnyPublisher<AuthenticationModel.Output.ForgotPasswordResult, Error> {
        Logger.info(target: self, "ID: \(identifier), Password: ***, confirmationCode: \(confirmationCode)")

        self.processing = true
        return Future<AuthenticationModel.Output.ForgotPasswordResult, Error> { promise in
            self.auth.confirmForgotPassword(username: identifier, newPassword: newPassword, confirmationCode: confirmationCode)
                .map { value -> AuthenticationModel.Output.ForgotPasswordResult in
                    return AuthenticationModel.Output.ForgotPasswordResult(value)
                }.sink(receiveCompletion: { completion in
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        promise(.failure(JobOrderError(from: error)))
                    }
                }, receiveValue: { response in
                    // Logger.debug(target: self, "\(response)")
                    promise(.success(response))
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }

    /// 確認メール再送信要求
    /// - Parameter identifier: ユーザーID
    /// - Returns: 確認結果
    public func resendConfirmationCode(identifier: String) -> AnyPublisher<AuthenticationModel.Output.SignUpResult, Error> {
        Logger.info(target: self, "ID: \(identifier)")

        self.processing = true
        return Future<AuthenticationModel.Output.SignUpResult, Error> { promise in
            self.auth.resendConfirmationCode(username: identifier)
                .map { value -> AuthenticationModel.Output.SignUpResult in
                    return AuthenticationModel.Output.SignUpResult(value)
                }.sink(receiveCompletion: { completion in
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        promise(.failure(JobOrderError(from: error)))
                    }
                }, receiveValue: { response in
                    // Logger.debug(target: self, "\(response)")
                    promise(.success(response))
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }

    /// e-mailアドレス取得
    /// - Returns: e-mailアドレス
    public func email() -> AnyPublisher<AuthenticationModel.Output.Email, Error> {
        Logger.info(target: self)

        self.processing = true
        return Future<AuthenticationModel.Output.Email, Error> { promise in
            self.auth.getAttrlibutes()
                .map { value -> AuthenticationModel.Output.Email in
                    return AuthenticationModel.Output.Email(value)
                }.sink(receiveCompletion: { completion in
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        promise(.failure(JobOrderError(from: error)))
                    }
                }, receiveValue: { response in
                    // Logger.debug(target: self, "\(response)")
                    promise(.success(response))
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
}

/// @mockable
protocol LAContextProtocol {
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void)
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
}

extension LAContext: LAContextProtocol {}
