//
//  AuthenticationUseCaseTests.swift
//  JobOrder.DomainTests
//
//  Created by Yu Suzuki on 2020/07/31.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
import LocalAuthentication
@testable import JobOrder_Domain
@testable import JobOrder_API
@testable import JobOrder_Data

class AuthenticationUseCaseTests: XCTestCase {

    private let ms1000 = 1.0
    private let context = LAContextProtocolMock()
    private let auth = JobOrder_API.AuthenticationRepositoryMock()
    private let mqtt = JobOrder_API.MQTTRepositoryMock()
    private let settings = JobOrder_Data.SettingsRepositoryMock()
    private let ud = JobOrder_Data.UserDefaultsRepositoryMock()
    private let keychain = JobOrder_Data.KeychainRepositoryMock()
    private let robot = JobOrder_Data.RobotRepositoryMock()
    private let job = JobOrder_Data.JobRepositoryMock()
    private let actionLibrary = JobOrder_Data.ActionLibraryRepositoryMock()
    private let aiLibrary = JobOrder_Data.AILibraryRepositoryMock()
    private lazy var useCase = AuthenticationUseCase(authRepository: auth,
                                                     mqttRepository: mqtt,
                                                     settingsRepository: settings,
                                                     userDefaultsRepository: ud,
                                                     keychainRepository: keychain,
                                                     robotDataRepository: robot,
                                                     jobDataRepository: job,
                                                     actionLibraryDataRepository: actionLibrary,
                                                     aiLibraryDataRepository: aiLibrary)
    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_currentUsername() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(useCase.currentUsername, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            auth.currentUsername = param
            XCTAssertEqual(useCase.currentUsername, param, "正しい値が取得できていない: \(param)")
        }
    }

    func test_isSignedIn() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(useCase.isSignedIn, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Trueが設定済みの場合") { _ in
            auth.isSignedIn = true
            XCTAssertTrue(useCase.isSignedIn, "無効になってはいけない")
        }

        XCTContext.runActivity(named: "Falseが設定済みの場合") { _ in
            auth.isSignedIn = false
            XCTAssertFalse(useCase.isSignedIn, "有効になってはいけない")
        }
    }

    func test_canUseBiometricsAuthentication() {
        useCase.context = context

        context.canEvaluatePolicyHandler = { policy, error in
            return true
        }
        XCTAssertTrue(useCase.canUseBiometricsAuthentication.result, "無効になってはいけない")
        XCTAssertNil(useCase.canUseBiometricsAuthentication.errorDescription, "値を取得できてはいけない")
    }

    func test_canUseBiometricsAuthenticationError() {
        useCase.context = context

        context.canEvaluatePolicyHandler = { policy, error in
            error?.pointee = NSError(domain: "Error", code: -1, userInfo: nil)
            return false
        }
        XCTAssertFalse(useCase.canUseBiometricsAuthentication.result, "有効になってはいけない")
        XCTAssertNotNil(useCase.canUseBiometricsAuthentication.errorDescription, "値が取得できていない")

        LAError.allCases.forEach { code in

            context.canEvaluatePolicyHandler = { policy, error in
                error?.pointee = NSError(domain: "Error", code: code.rawValue, userInfo: nil)
                return false
            }
            if code == .biometryLockout || code == .biometryNotEnrolled {
                XCTAssertTrue(useCase.canUseBiometricsAuthentication.result, "無効になってはいけない")
            } else {
                XCTAssertFalse(useCase.canUseBiometricsAuthentication.result, "有効になってはいけない")
            }
        }
    }

    func test_registerAuthenticationStateChange() {
        var callCount = 0

        JobOrder_API.AuthenticationEntity.Output.AuthenticationState.allCases.forEach { entity in
            let handlerExpectation = expectation(description: "handler \(entity)")
            let completionExpectation = expectation(description: "completion \(entity)")

            auth.registerUserStateChangeHandler = {
                return Future<JobOrder_API.AuthenticationEntity.Output.AuthenticationState, Never> { promise in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // PublisherのReturnより前にsendされて失敗するのでDelayを入れる
                        handlerExpectation.fulfill()
                        promise(.success(entity))
                    }
                }.eraseToAnyPublisher()
            }

            useCase.registerAuthenticationStateChange()
                .sink { response in
                    let model = AuthenticationModel.Output.AuthenticationState(entity)
                    XCTAssertEqual(response, model, "正しい値が取得できていない: \(model)")
                    switch response {
                    case .signedOut, .signedOutUserPoolsTokenInvalid, .signedOutFederatedTokensInvalid:
                        callCount += 1
                        XCTAssertEqual(self.ud.setCallCount, callCount, "UserDefaultsRepositoryのメソッドが呼ばれない")
                        XCTAssertEqual(self.robot.deleteAllCallCount, callCount, "RobotRepositoryのメソッドが呼ばれない")
                        XCTAssertEqual(self.job.deleteAllCallCount, callCount, "JobRepositoryのメソッドが呼ばれない")
                        XCTAssertEqual(self.actionLibrary.deleteAllCallCount, callCount, "ActionLibraryRepositoryのメソッドが呼ばれない")
                        XCTAssertEqual(self.aiLibrary.deleteAllCallCount, callCount, "AILibraryRepositoryのメソッドが呼ばれない")
                    default: break
                    }
                    completionExpectation.fulfill()
                }.store(in: &cancellables)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_registerAuthenticationStateChangeNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.registerUserStateChangeHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.AuthenticationState, Never> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.registerAuthenticationStateChange()
            .sink { response in
                completionExpectation.fulfill()
            }.store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_unregisterAuthenticationStateChange() {
        useCase.unregisterAuthenticationStateChange()
        XCTAssertEqual(auth.unregisterUserStateChangeCallCount, 1, "AuthenticationRepositoryのメソッドが呼ばれていない")
    }

    func test_biometricsAuthentication() {
        useCase.context = context
        let evaluatePolicyHandlerExpectation = expectation(description: "EvaluatePolicy handler")
        let readHandlerExpectation = expectation(description: "Read handler")
        let completionExpectation = expectation(description: "completion")

        context.evaluatePolicyHandler = { policy, localizedReason, callback in
            evaluatePolicyHandlerExpectation.fulfill()
            callback(true, nil)
        }

        robot.readHandler = {
            readHandlerExpectation.fulfill()
            let entity = RobotEntity()
            entity.thingName = "test"
            return [entity]
        }

        useCase.biometricsAuthentication()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                let model = AuthenticationModel.Output.BiometricsAuthentication(result: true, errorDescription: nil)
                XCTAssertEqual(self.robot.readCallCount, 1, "RobotRepositoryのメソッドが呼ばれていない")
                XCTAssertEqual(self.robot.updateCallCount, 1, "RobotRepositoryのメソッドが呼ばれていない")
                XCTAssert(response.result == model.result, "正しい値が取得できていない: \(model)")
            }).store(in: &cancellables)

        wait(for: [evaluatePolicyHandlerExpectation, readHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_biometricsAuthenticationNotReceive() {
        useCase.context = context
        let evaluatePolicyHandlerExpectation = expectation(description: "EvaluatePolicy handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        context.evaluatePolicyHandler = { policy, localizedReason, callback in
            evaluatePolicyHandlerExpectation.fulfill()
        }

        useCase.biometricsAuthentication()
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [evaluatePolicyHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_biometricsAuthenticationError() {
        useCase.context = context
        let evaluatePolicyHandlerExpectation = expectation(description: "EvaluatePolicy handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)
        let expected = JobOrderError.internalError(error: error) as NSError

        context.evaluatePolicyHandler = { policy, localizedReason, callback in
            evaluatePolicyHandlerExpectation.fulfill()
            callback(true, error)
        }

        useCase.biometricsAuthentication()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [evaluatePolicyHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_signIn() {
        let param = "test"

        JobOrder_API.AuthenticationEntity.Output.SignInResult.State.allCases.forEach {
            let handlerExpectation = expectation(description: "handler \($0)")
            let completionExpectation = expectation(description: "completion \($0)")
            let entity = JobOrder_API.AuthenticationEntity.Output.SignInResult(state: $0)

            auth.signInHandler = { identifier, password in
                return Future<JobOrder_API.AuthenticationEntity.Output.SignInResult, Error> { promise in
                    handlerExpectation.fulfill()
                    promise(.success(entity))
                }.eraseToAnyPublisher()
            }

            useCase.signIn(identifier: param, password: param)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { response in
                    let model = AuthenticationModel.Output.SignInResult(entity)
                    XCTAssert(response == model, "正しい値が取得できていない: \(model)")
                }).store(in: &cancellables)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_signInNotReceive() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.signInHandler = { identifier, password in
            return Future<JobOrder_API.AuthenticationEntity.Output.SignInResult, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.signIn(identifier: param, password: param)
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_signInError() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)
        let expected = JobOrderError.internalError(error: error) as NSError

        auth.signInHandler = { identifier, password in
            return Future<JobOrder_API.AuthenticationEntity.Output.SignInResult, Error> { promise in
                handlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.signIn(identifier: param, password: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_confirmSignIn() {
        let param = "test"

        JobOrder_API.AuthenticationEntity.Output.SignInResult.State.allCases.forEach {
            let handlerExpectation = expectation(description: "handler \($0)")
            let completionExpectation = expectation(description: "completion \($0)")
            let entity = JobOrder_API.AuthenticationEntity.Output.SignInResult(state: $0)

            auth.confirmSignInHandler = { newPassword in
                return Future<JobOrder_API.AuthenticationEntity.Output.SignInResult, Error> { promise in
                    handlerExpectation.fulfill()
                    promise(.success(entity))
                }.eraseToAnyPublisher()
            }

            useCase.confirmSignIn(newPassword: param)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { response in
                    let model = AuthenticationModel.Output.SignInResult(entity)
                    XCTAssert(response == model, "正しい値が取得できていない: \(model)")
                }).store(in: &cancellables)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_confirmSignInNotReceived() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.confirmSignInHandler = { newPassword in
            return Future<JobOrder_API.AuthenticationEntity.Output.SignInResult, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.confirmSignIn(newPassword: param)
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_confirmSignInError() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)
        let expected = JobOrderError.internalError(error: error) as NSError

        auth.confirmSignInHandler = { newPassword in
            return Future<JobOrder_API.AuthenticationEntity.Output.SignInResult, Error> { promise in
                handlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.confirmSignIn(newPassword: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_signOut() {
        var callCount = 0

        JobOrder_API.AuthenticationEntity.Output.SignOutResult.State.allCases.forEach {
            let disconnectHandlerExpectation = expectation(description: "Disconnect handler")
            let signOutHandlerExpectation = expectation(description: "SignOut handler")
            let completionExpectation = expectation(description: "completion \($0)")
            let resultEntity = JobOrder_API.AuthenticationEntity.Output.SignOutResult(state: $0)
            callCount += 1

            mqtt.disconnectWithCleanUpHandler = {
                return Future<JobOrder_API.MQTTEntity.Output.DisconnectWithCleanup, Error> { promise in
                    disconnectHandlerExpectation.fulfill()
                    promise(.success(.init(result: true)))
                }.eraseToAnyPublisher()
            }

            auth.signOutHandler = {
                return Future<JobOrder_API.AuthenticationEntity.Output.SignOutResult, Error> { promise in
                    signOutHandlerExpectation.fulfill()
                    promise(.success(resultEntity))
                }.eraseToAnyPublisher()
            }

            useCase.signOut()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTAssertEqual(self.settings.restoreIdentifierSetCallCount, callCount, "SettingsRepositoryのメソッドが呼ばれない")
                        XCTAssertEqual(self.settings.useBiometricsAuthenticationSetCallCount, callCount, "SettingsRepositoryのメソッドが呼ばれない")
                    case .failure(let error):
                        XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { response in
                    let model = AuthenticationModel.Output.SignOutResult(resultEntity)
                    XCTAssert(response == model, "正しい値が取得できていない: \(model)")
                }).store(in: &cancellables)

            wait(for: [disconnectHandlerExpectation, signOutHandlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_signOutNotReceived() {

        XCTContext.runActivity(named: "DisconnectWithCleanupの通知が来ない場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            mqtt.disconnectWithCleanUpHandler = {
                return Future<JobOrder_API.MQTTEntity.Output.DisconnectWithCleanup, Error> { promise in
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            useCase.signOut()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("値を取得できてはいけない")
                    case .failure(let e):
                        XCTFail("値を取得できてはいけない: \(e)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { _ in
                }).store(in: &cancellables)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }

        XCTContext.runActivity(named: "SignOutの通知が来ない場合") { _ in
            let disconnectHandlerExpectation = expectation(description: "Disconnect handler")
            let signOutHandlerExpectation = expectation(description: "SignOut handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            mqtt.disconnectWithCleanUpHandler = {
                return Future<JobOrder_API.MQTTEntity.Output.DisconnectWithCleanup, Error> { promise in
                    disconnectHandlerExpectation.fulfill()
                    promise(.success(.init(result: true)))
                }.eraseToAnyPublisher()
            }

            auth.signOutHandler = {
                return Future<JobOrder_API.AuthenticationEntity.Output.SignOutResult, Error> { promise in
                    signOutHandlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            useCase.signOut()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("値を取得できてはいけない")
                    case .failure(let e):
                        XCTFail("値を取得できてはいけない: \(e)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { _ in
                }).store(in: &cancellables)

            wait(for: [disconnectHandlerExpectation, signOutHandlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_signOutError() {

        XCTContext.runActivity(named: "DisconnectWithCleanupでSuccess以外が通知された場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")

            mqtt.disconnectWithCleanUpHandler = {
                return Future<JobOrder_API.MQTTEntity.Output.DisconnectWithCleanup, Error> { promise in
                    handlerExpectation.fulfill()
                    promise(.success(.init(result: false)))
                }.eraseToAnyPublisher()
            }

            useCase.signOut()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("値を取得できてはいけない")
                    case .failure(let e):
                        let expected = JobOrderError.connectionFailed(reason: .failToDisconnect) as NSError
                        XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { _ in
                }).store(in: &cancellables)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }

        XCTContext.runActivity(named: "DisconnectWithCleanupでエラーが通知された場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            let error = NSError(domain: "Error", code: -1, userInfo: nil)
            let expected = JobOrderError.internalError(error: error) as NSError

            mqtt.disconnectWithCleanUpHandler = {
                return Future<JobOrder_API.MQTTEntity.Output.DisconnectWithCleanup, Error> { promise in
                    handlerExpectation.fulfill()
                    promise(.failure(error))
                }.eraseToAnyPublisher()
            }

            useCase.signOut()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("値を取得できてはいけない")
                    case .failure(let e):
                        XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { _ in
                }).store(in: &cancellables)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }

        XCTContext.runActivity(named: "SignOutでエラーが通知された場合") { _ in
            let disconnectHandlerExpectation = expectation(description: "Disconnect handler")
            let signOutHandlerExpectation = expectation(description: "SignOut handler")
            let completionExpectation = expectation(description: "completion")
            let error = NSError(domain: "Error", code: -1, userInfo: nil)
            let expected = JobOrderError.internalError(error: error) as NSError

            mqtt.disconnectWithCleanUpHandler = {
                return Future<JobOrder_API.MQTTEntity.Output.DisconnectWithCleanup, Error> { promise in
                    disconnectHandlerExpectation.fulfill()
                    promise(.success(.init(result: true)))
                }.eraseToAnyPublisher()
            }

            auth.signOutHandler = {
                return Future<JobOrder_API.AuthenticationEntity.Output.SignOutResult, Error> { promise in
                    signOutHandlerExpectation.fulfill()
                    promise(.failure(error))
                }.eraseToAnyPublisher()
            }

            useCase.signOut()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("値を取得できてはいけない")
                    case .failure(let e):
                        XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { _ in
                }).store(in: &cancellables)

            wait(for: [disconnectHandlerExpectation, signOutHandlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_forgotPassword() {
        let param = "test"

        JobOrder_API.AuthenticationEntity.Output.ForgotPasswordResult.State.allCases.forEach {
            let handlerExpectation = expectation(description: "handler \($0)")
            let completionExpectation = expectation(description: "completion \($0)")
            let entity = JobOrder_API.AuthenticationEntity.Output.ForgotPasswordResult(state: $0)

            auth.forgotPasswordHandler = { identifier in
                return Future<JobOrder_API.AuthenticationEntity.Output.ForgotPasswordResult, Error> { promise in
                    handlerExpectation.fulfill()
                    promise(.success(entity))
                }.eraseToAnyPublisher()
            }

            useCase.forgotPassword(identifier: param)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { response in
                    let model = AuthenticationModel.Output.ForgotPasswordResult(entity)
                    XCTAssert(response == model, "正しい値が取得できていない: \(model)")
                }).store(in: &cancellables)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_forgotPasswordNotReceived() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.forgotPasswordHandler = { identifier in
            return Future<JobOrder_API.AuthenticationEntity.Output.ForgotPasswordResult, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.forgotPassword(identifier: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_forgotPasswordError() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)
        let expected = JobOrderError.internalError(error: error) as NSError

        auth.forgotPasswordHandler = { identifier in
            return Future<JobOrder_API.AuthenticationEntity.Output.ForgotPasswordResult, Error> { promise in
                handlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.forgotPassword(identifier: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_confirmForgotPassword() {
        let param = "test"

        JobOrder_API.AuthenticationEntity.Output.ForgotPasswordResult.State.allCases.forEach {
            let handlerExpectation = expectation(description: "handler \($0)")
            let completionExpectation = expectation(description: "completion \($0)")
            let entity = JobOrder_API.AuthenticationEntity.Output.ForgotPasswordResult(state: $0)

            auth.confirmForgotPasswordHandler = { identifier, newPassword, confirmationCode in
                return Future<JobOrder_API.AuthenticationEntity.Output.ForgotPasswordResult, Error> { promise in
                    handlerExpectation.fulfill()
                    promise(.success(entity))
                }.eraseToAnyPublisher()
            }

            useCase.confirmForgotPassword(identifier: param, newPassword: param, confirmationCode: param)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { response in
                    let model = AuthenticationModel.Output.ForgotPasswordResult(entity)
                    XCTAssert(response == model, "正しい値が取得できていない: \(model)")
                }).store(in: &cancellables)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_confirmForgotPasswordNotReceived() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.confirmForgotPasswordHandler = { identifier, newPassword, confirmationCode in
            return Future<JobOrder_API.AuthenticationEntity.Output.ForgotPasswordResult, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.confirmForgotPassword(identifier: param, newPassword: param, confirmationCode: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_confirmForgotPasswordError() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)
        let expected = JobOrderError.internalError(error: error) as NSError

        auth.confirmForgotPasswordHandler = { identifier, newPassword, confirmationCode in
            return Future<JobOrder_API.AuthenticationEntity.Output.ForgotPasswordResult, Error> { promise in
                handlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.confirmForgotPassword(identifier: param, newPassword: param, confirmationCode: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_resendConfirmationCode() {
        let param = "test"

        JobOrder_API.AuthenticationEntity.Output.SignUpResult.ConfirmationState.allCases.forEach {
            let handlerExpectation = expectation(description: "handler \($0)")
            let completionExpectation = expectation(description: "completion \($0)")
            let entity = JobOrder_API.AuthenticationEntity.Output.SignUpResult(state: $0)

            auth.resendConfirmationCodeHandler = { identifier in
                return Future<JobOrder_API.AuthenticationEntity.Output.SignUpResult, Error> { promise in
                    handlerExpectation.fulfill()
                    promise(.success(entity))
                }.eraseToAnyPublisher()
            }

            useCase.resendConfirmationCode(identifier: param)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { response in
                    let model = AuthenticationModel.Output.SignUpResult(entity)
                    XCTAssert(response == model, "正しい値が取得できていない: \(model)")
                }).store(in: &cancellables)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_resendConfirmationCodeNotReceived() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.resendConfirmationCodeHandler = { identifier in
            return Future<JobOrder_API.AuthenticationEntity.Output.SignUpResult, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.resendConfirmationCode(identifier: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_resendConfirmationCodeError() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)
        let expected = JobOrderError.internalError(error: error) as NSError

        auth.resendConfirmationCodeHandler = { identifier in
            return Future<JobOrder_API.AuthenticationEntity.Output.SignUpResult, Error> { promise in
                handlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.resendConfirmationCode(identifier: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_email() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let entity = JobOrder_API.AuthenticationEntity.Output.Attributes(email: "test")

        auth.getAttrlibutesHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Attributes, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        useCase.email()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                let model = AuthenticationModel.Output.Email(entity)
                XCTAssert(response == model, "正しい値が取得できていない: \(model)")
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_emailNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.getAttrlibutesHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Attributes, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.email()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_emailError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)
        let expected = JobOrderError.internalError(error: error) as NSError

        auth.getAttrlibutesHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Attributes, Error> { promise in
                handlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.email()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }
}

extension LAError {

    static var allCases: [LAError.Code] {
        [.authenticationFailed, .userCancel, .userFallback, .systemCancel, .passcodeNotSet, .appCancel, .invalidContext, .biometryNotAvailable, .biometryNotEnrolled, .biometryLockout, .notInteractive]
    }
}
