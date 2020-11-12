//
//  PasswordAuthenticationPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/05/21.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class PasswordAuthenticationPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    @Published private var processing: Bool = false
    private let vc = PasswordAuthenticationViewControllerProtocolMock()
    private let auth = JobOrder_Domain.AuthenticationUseCaseProtocolMock()
    private let settings = JobOrder_Domain.SettingsUseCaseProtocolMock()
    private lazy var presenter = PasswordAuthenticationPresenter(authUseCase: auth,
                                                                 settingsUseCase: settings,
                                                                 vc: vc)

    override func setUpWithError() throws {
        auth.processingPublisher = $processing
        auth.registerAuthenticationStateChangeHandler = {
            return Future<JobOrder_Domain.AuthenticationModel.Output.AuthenticationState, Never> { promise in }.eraseToAnyPublisher()
        }
    }

    override func tearDownWithError() throws {}

    func test_isRestoreIdentifier() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(presenter.isRestoredIdentifier, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Trueが設定済みの場合") { _ in
            settings.restoreIdentifier = true
            XCTAssertTrue(presenter.isRestoredIdentifier, "無効になってはいけない")
        }

        XCTContext.runActivity(named: "Falseが設定済みの場合") { _ in
            settings.restoreIdentifier = false
            XCTAssertFalse(presenter.isRestoredIdentifier, "有効になってはいけない")
        }
    }

    func test_username() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(presenter.username, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            auth.currentUsername = param
            XCTAssertEqual(presenter.username, param, "正しい値が取得できていない: \(param)")
        }
    }

    func test_isEnabledSignInButton() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(presenter.isEnabledSignInButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Identifierが設定されていない場合") { _ in
            presenter.changedIdentifierTextField(nil)
            presenter.changedPasswordTextField(param)
            XCTAssertFalse(presenter.isEnabledSignInButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Passwordが設定されていない場合") { _ in
            presenter.changedIdentifierTextField(param)
            presenter.changedPasswordTextField(nil)
            XCTAssertFalse(presenter.isEnabledSignInButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Identifier, Password共に設定されている場合") { _ in
            presenter.changedIdentifierTextField(param)
            presenter.changedPasswordTextField(param)
            XCTAssertTrue(presenter.isEnabledSignInButton, "無効になってはいけない")
        }
    }

    func test_isEnabledBiometricsButton() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(presenter.isEnabledBiometricsButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "サインアウト中の場合") { _ in
            auth.isSignedIn = false
            auth.canUseBiometricsAuthentication = JobOrder_Domain.AuthenticationModel.Output.BiometricsAuthentication(result: true, errorDescription: nil)
            settings.useBiometricsAuthentication = true
            XCTAssertFalse(presenter.isEnabledBiometricsButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "生体認証不可の場合") { _ in
            auth.isSignedIn = true
            auth.canUseBiometricsAuthentication = JobOrder_Domain.AuthenticationModel.Output.BiometricsAuthentication(result: false, errorDescription: nil)
            settings.useBiometricsAuthentication = true
            XCTAssertFalse(presenter.isEnabledBiometricsButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "生体認証OFFの場合") { _ in
            auth.isSignedIn = true
            auth.canUseBiometricsAuthentication = JobOrder_Domain.AuthenticationModel.Output.BiometricsAuthentication(result: true, errorDescription: nil)
            settings.useBiometricsAuthentication = false
            XCTAssertFalse(presenter.isEnabledBiometricsButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "生体認証実施可能な場合") { _ in
            auth.isSignedIn = true
            auth.canUseBiometricsAuthentication = JobOrder_Domain.AuthenticationModel.Output.BiometricsAuthentication(result: true, errorDescription: nil)
            settings.useBiometricsAuthentication = true
            XCTAssertTrue(presenter.isEnabledBiometricsButton, "無効になってはいけない")
        }
    }

    func test_tapSignInButton() {
        let param = "test"

        JobOrder_Domain.AuthenticationModel.Output.SignInResult.State.allCases.forEach { state in
            let handlerExpectation = expectation(description: "handler \(state)")
            let completionExpectation = expectation(description: "completion \(state)")
            completionExpectation.isInverted = true

            auth.signInHandler = { identifier, password in
                return Future<JobOrder_Domain.AuthenticationModel.Output.SignInResult, Error> { promise in
                    promise(.success(.init(state)))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            presenter.changedIdentifierTextField(param)
            presenter.changedPasswordTextField(param)
            presenter.tapSignInButton()

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

            switch state {
            case .signedIn:
                XCTAssertEqual(vc.dismissCallCount, 1, "ViewControllerのメソッドが呼ばれない")
            case .newPasswordRequired:
                XCTAssertEqual(vc.transitionToNewPasswordRequiredScreenCallCount, 1, "ViewControllerのメソッドが呼ばれない")
            default: break
            // TODO: エラーケース
            }
        }
    }

    func test_tapSignInButtonNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        handlerExpectation.isInverted = true
        completionExpectation.isInverted = true

        auth.signInHandler = { identifier, password in
            return Future<JobOrder_Domain.AuthenticationModel.Output.SignInResult, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.tapSignInButton()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(auth.signInCallCount, 0, "ViewControllerのメソッドが呼ばれてはいけない")
    }

    func test_tapSignInButtonError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"

        auth.signInHandler = { identifier, password in
            return Future<JobOrder_Domain.AuthenticationModel.Output.SignInResult, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.changedIdentifierTextField(param)
        presenter.changedPasswordTextField(param)
        presenter.tapSignInButton()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_tapBiometricsAuthenticationButton() {

        XCTContext.runActivity(named: "想定外の状態になった場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            auth.biometricsAuthenticationHandler = {
                return Future<JobOrder_Domain.AuthenticationModel.Output.BiometricsAuthentication, Error> { promise in
                    promise(.success(.init(result: false, errorDescription: nil)))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            presenter.tapBiometricsAuthenticationButton()

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            // TODO: エラーケース
        }

        XCTContext.runActivity(named: "成功した場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            auth.biometricsAuthenticationHandler = {
                return Future<JobOrder_Domain.AuthenticationModel.Output.BiometricsAuthentication, Error> { promise in
                    promise(.success(.init(result: true, errorDescription: nil)))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            presenter.tapBiometricsAuthenticationButton()

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            XCTAssertEqual(vc.dismissByBiometricsAuthenticationCallCount, 1, "ViewControllerのメソッドが呼ばれない")
        }
    }

    func test_tapBiometricsAuthenticationButtonError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.biometricsAuthenticationHandler = {
            return Future<JobOrder_Domain.AuthenticationModel.Output.BiometricsAuthentication, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.tapBiometricsAuthenticationButton()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        // TODO: パスワード入力画面を表示
    }

    func test_subscribeUseCaseProcessing() {
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        // 初期化時に登録
        presenter = PasswordAuthenticationPresenter(authUseCase: auth,
                                                    settingsUseCase: settings,
                                                    vc: vc)

        wait(for: [completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.changedProcessingCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_registerStateChangesNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.registerAuthenticationStateChangeHandler = {
            return Future<AuthenticationModel.Output.AuthenticationState, Never> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = PasswordAuthenticationPresenter(authUseCase: auth,
                                                    settingsUseCase: settings,
                                                    vc: vc)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.changedProcessingCallCount, 1, "ViewControllerのメソッドが呼ばれてしまう") // changeProsessingで1回カウントされる
    }

    func test_registerStateChangesReceived() {
        var callCount = 0

        JobOrder_Domain.AuthenticationModel.Output.AuthenticationState.allCases.forEach { state in
            let handlerExpectation = expectation(description: "handler \(state)")
            let completionExpectation = expectation(description: "completion \(state)")
            completionExpectation.isInverted = true
            callCount += 1

            auth.registerAuthenticationStateChangeHandler = {
                return Future<AuthenticationModel.Output.AuthenticationState, Never> { promise in
                    promise(.success(state))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            // 初期化時に登録
            presenter = PasswordAuthenticationPresenter(authUseCase: auth,
                                                        settingsUseCase: settings,
                                                        vc: vc)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

            switch state {
            case .signedOut, .signedOutUserPoolsTokenInvalid, .signedOutFederatedTokensInvalid:
                callCount += 1
            default: break
            }
            XCTAssertEqual(vc.changedProcessingCallCount, callCount, "ViewControllerのメソッドが呼ばれない") // changeProsessingで1回カウントされる
        }
    }

    func test_isEnabled() {
        let param = "test"

        XCTAssertTrue(presenter.isEnabled(param, param), "無効になってはいけない")

        XCTAssertFalse(presenter.isEnabled("", ""), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(nil, nil), "有効になってはいけない")

        XCTAssertFalse(presenter.isEnabled(nil, param), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(nil, ""), "有効になってはいけない")

        XCTAssertFalse(presenter.isEnabled("", nil), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled("", param), "有効になってはいけない")

        XCTAssertFalse(presenter.isEnabled(param, nil), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(param, ""), "有効になってはいけない")
    }

    func test_validate() {

        XCTContext.runActivity(named: "文字数以外の条件が揃っている場合") { _ in
            XCTContext.runActivity(named: "8文字以下") { _ in
                XCTAssertFalse(presenter.validate(password: "12ABab!"), "8文字以下で条件が揃った場合に有効になってはいけない")
            }
            XCTContext.runActivity(named: "8文字") { _ in
                XCTAssertTrue(presenter.validate(password: "12ABab!?"), "8文字で条件が揃った場合に無効になってはいけない")
            }
            XCTContext.runActivity(named: "8文字以上") { _ in
                XCTAssertTrue(presenter.validate(password: "12ABab!?34"), "8文字以上で条件が揃った場合に無効になってはいけない")
            }
        }

        XCTContext.runActivity(named: "小文字以外の条件が揃っている場合") { _ in
            XCTContext.runActivity(named: "小文字なし") { _ in
                XCTAssertFalse(presenter.validate(password: "1234AB!?"), "小文字を含まず他の条件が揃った場合に有効になってはいけない")
            }
        }

        XCTContext.runActivity(named: "大文字以外の条件が揃っている場合") { _ in
            XCTContext.runActivity(named: "大文字なし") { _ in
                XCTAssertFalse(presenter.validate(password: "1234ab!?"), "大文字を含まず他の条件が揃った場合に有効になってはいけない")
            }
        }

        XCTContext.runActivity(named: "数字以外の条件が揃っている場合") { _ in
            XCTContext.runActivity(named: "数字なし") { _ in
                XCTAssertFalse(presenter.validate(password: "ABCDab!?"), "数字を含まず他の条件が揃った場合に有効になってはいけない")
            }
        }

        XCTContext.runActivity(named: "特殊文字以外の条件が揃っている場合") { _ in
            XCTContext.runActivity(named: "特殊文字なし") { _ in
                XCTAssertFalse(presenter.validate(password: "1234ABab"), "特殊文字を含まず他の条件が揃った場合に有効になってはいけない")
            }
        }
    }
}
