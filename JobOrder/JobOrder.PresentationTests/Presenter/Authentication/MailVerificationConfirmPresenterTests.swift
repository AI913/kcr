//
//  MailVerificationConfirmPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class MailVerificationConfirmPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    @Published private var processing: Bool = false
    private let vc = MailVerificationConfirmViewControllerProtocolMock()
    private let auth = JobOrder_Domain.AuthenticationUseCaseProtocolMock()
    private let viewData: AuthenticationViewData = AuthenticationViewData(identifier: "test")
    private lazy var presenter = MailVerificationConfirmPresenter(useCase: auth,
                                                                  vc: vc,
                                                                  viewData: viewData)

    override func setUpWithError() throws {
        auth.processingPublisher = $processing
        auth.registerAuthenticationStateChangeHandler = {
            return Future<JobOrder_Domain.AuthenticationModel.Output.AuthenticationState, Never> { promise in }.eraseToAnyPublisher()
        }
        auth.signOutHandler = {
            return Future<JobOrder_Domain.AuthenticationModel.Output.SignOutResult, Error> { promise in }.eraseToAnyPublisher()
        }
    }

    override func tearDownWithError() throws {}

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

    func test_isEnabledUpdateButton() {
        let param = "test"
        let valid_password = "Aa34567!"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(presenter.isEnabledUpdateButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Identifierが設定されていない場合") { _ in
            presenter.data.identifier = nil
            XCTAssertFalse(presenter.isEnabledUpdateButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "ConfirmationCodeが設定されていない場合") { _ in
            presenter.changedConfirmationCodeTextField(nil)
            XCTAssertFalse(presenter.isEnabledUpdateButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Passwordが設定されていない場合") { _ in
            presenter.changedPasswordTextField(nil)
            XCTAssertFalse(presenter.isEnabledUpdateButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Identifier, ConfirmationCode, Passwordが全て設定されている場合") { _ in
            presenter.data.identifier = param
            presenter.changedConfirmationCodeTextField(param)
            presenter.changedPasswordTextField(valid_password)
            XCTAssertTrue(presenter.isEnabledUpdateButton, "無効になってはいけない")
        }
    }

    func test_tapResendButton() {
        let param = "test"

        JobOrder_Domain.AuthenticationModel.Output.SignUpResult.ConfirmationState.allCases.forEach { state in
            let handlerExpectation = expectation(description: "handler \(state)")
            let completionExpectation = expectation(description: "completion \(state)")
            completionExpectation.isInverted = true

            auth.resendConfirmationCodeHandler = { identifier in
                return Future<JobOrder_Domain.AuthenticationModel.Output.SignUpResult, Error> { promise in
                    promise(.success(.init(state)))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            presenter.data.identifier = param
            presenter.tapResendButton()

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

            switch state {
            case .unconfirmed:
                XCTAssertEqual(vc.showAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
            default: break
            // TODO: エラーケース
            }
        }
    }

    func test_tapResendButtonNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        handlerExpectation.isInverted = true
        completionExpectation.isInverted = true

        auth.resendConfirmationCodeHandler = { identifier in
            return Future<JobOrder_Domain.AuthenticationModel.Output.SignUpResult, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.data.identifier = nil
        presenter.tapResendButton()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(auth.resendConfirmationCodeCallCount, 0, "AuthenticationUseCaseのメソッドが呼ばれてはいけない")
    }

    func test_tapResendButtonError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"

        auth.resendConfirmationCodeHandler = { identifier in
            return Future<JobOrder_Domain.AuthenticationModel.Output.SignUpResult, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.data.identifier = param
        presenter.tapResendButton()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.showErrorAlertErrorCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_tapUpdateButton() {
        let param = "test"
        let valid_password = "Aa34567!"

        JobOrder_Domain.AuthenticationModel.Output.ForgotPasswordResult.State.allCases.forEach { state in
            let handlerExpectation = expectation(description: "handler \(state)")
            let completionExpectation = expectation(description: "completion \(state)")
            completionExpectation.isInverted = true

            auth.confirmForgotPasswordHandler = { identifier, newPassword, confirmationCode in
                return Future<JobOrder_Domain.AuthenticationModel.Output.ForgotPasswordResult, Error> { promise in
                    promise(.success(.init(state)))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            presenter.data.identifier = param
            presenter.changedConfirmationCodeTextField(param)
            presenter.changedPasswordTextField(valid_password)
            presenter.tapUpdateButton()

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

            switch state {
            case .done:
                XCTAssertEqual(auth.signOutCallCount, 1, "AuthenticationUseCaseのメソッドが呼ばれない")
            default: break
            // TODO: エラーケース
            }
        }
    }

    func test_tapUpdateButtonNotReceived() {

        XCTContext.runActivity(named: "Identifierが未設定の場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            handlerExpectation.isInverted = true
            completionExpectation.isInverted = true
            let param = "test"
            let valid_password = "Aa34567!"

            auth.confirmForgotPasswordHandler = { identifier, newPassword, confirmationCode in
                return Future<JobOrder_Domain.AuthenticationModel.Output.ForgotPasswordResult, Error> { promise in
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            presenter.data.identifier = nil
            presenter.changedConfirmationCodeTextField(param)
            presenter.changedPasswordTextField(valid_password)
            presenter.tapUpdateButton()

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            XCTAssertEqual(auth.confirmForgotPasswordCallCount, 0, "AuthenticationUseCaseのメソッドが呼ばれてはいけない")
        }

        XCTContext.runActivity(named: "Passwordが未設定の場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            handlerExpectation.isInverted = true
            completionExpectation.isInverted = true
            let param = "test"

            auth.confirmForgotPasswordHandler = { identifier, newPassword, confirmationCode in
                return Future<JobOrder_Domain.AuthenticationModel.Output.ForgotPasswordResult, Error> { promise in
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            presenter.data.identifier = param
            presenter.changedConfirmationCodeTextField(param)
            presenter.changedPasswordTextField(nil)
            presenter.tapUpdateButton()

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            XCTAssertEqual(auth.confirmForgotPasswordCallCount, 0, "AuthenticationUseCaseのメソッドが呼ばれてはいけない")
        }

        XCTContext.runActivity(named: "ConfirmationCodeが未設定の場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            handlerExpectation.isInverted = true
            completionExpectation.isInverted = true
            let param = "test"

            auth.confirmForgotPasswordHandler = { identifier, newPassword, confirmationCode in
                return Future<JobOrder_Domain.AuthenticationModel.Output.ForgotPasswordResult, Error> { promise in
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            presenter.data.identifier = param
            presenter.changedConfirmationCodeTextField(param)
            presenter.changedPasswordTextField(nil)
            presenter.tapUpdateButton()

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            XCTAssertEqual(auth.confirmForgotPasswordCallCount, 0, "AuthenticationUseCaseのメソッドが呼ばれてはいけない")
        }
    }

    func test_tapUpdateButtonError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"
        let valid_password = "Aa34567!"

        auth.confirmForgotPasswordHandler = { identifier, newPassword, confirmationCode in
            return Future<JobOrder_Domain.AuthenticationModel.Output.ForgotPasswordResult, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.data.identifier = param
        presenter.changedConfirmationCodeTextField(param)
        presenter.changedPasswordTextField(valid_password)
        presenter.tapUpdateButton()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.showErrorAlertErrorCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_tapUpdateButtonErrorPasswordErrorSpecial() {
        let param = "test"
        let invalid_password = "Ab345678"

        presenter.data.identifier = param
        presenter.changedConfirmationCodeTextField(param)
        presenter.changedPasswordTextField(invalid_password)
        presenter.tapUpdateButton()

        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "パスワードポリシーエラーとなること")
    }

    func test_tapUpdateButtonErrorPasswordErrorUpper() {
        let param = "test"
        let invalid_password = "ab3456!8"

        presenter.data.identifier = param
        presenter.changedConfirmationCodeTextField(param)
        presenter.changedPasswordTextField(invalid_password)
        presenter.tapUpdateButton()

        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "パスワードポリシーエラーとなること")
    }

    func test_tapUpdateButtonErrorPasswordErrorLower() {
        let param = "test"
        let invalid_password = "AB3456!8"

        presenter.data.identifier = param
        presenter.changedConfirmationCodeTextField(param)
        presenter.changedPasswordTextField(invalid_password)
        presenter.tapUpdateButton()

        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "パスワードポリシーエラーとなること")
    }

    func test_tapUpdateButtonErrorPasswordErrorDigit() {
        let param = "test"
        let invalid_password = "ABCDEF!H"

        presenter.data.identifier = param
        presenter.changedConfirmationCodeTextField(param)
        presenter.changedPasswordTextField(invalid_password)
        presenter.tapUpdateButton()

        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "パスワードポリシーエラーとなること")
    }

    func test_tapUpdateButtonErrorPasswordErrorLength() {
        let param = "test"
        let invalid_password = "Aa3456!"

        presenter.data.identifier = param
        presenter.changedConfirmationCodeTextField(param)
        presenter.changedPasswordTextField(invalid_password)
        presenter.tapUpdateButton()

        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "パスワードポリシーエラーとなること")
    }

    func test_subscribeUseCaseProcessing() {
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        // 初期化時に登録
        presenter = MailVerificationConfirmPresenter(useCase: auth, vc: vc, viewData: viewData)

        wait(for: [completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.changedProcessingCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_signOut() {

        JobOrder_Domain.AuthenticationModel.Output.SignOutResult.State.allCases.forEach { state in
            let handlerExpectation = expectation(description: "handler \(state)")
            let completionExpectation = expectation(description: "completion \(state)")
            completionExpectation.isInverted = true

            auth.signOutHandler = {
                return Future<JobOrder_Domain.AuthenticationModel.Output.SignOutResult, Error> { promise in
                    promise(.success(.init(state)))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            presenter.signOut()

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

            switch state {
            case .success:
                XCTAssertEqual(vc.transitionToCompleteScreenCallCount, 1, "ViewControllerのメソッドが呼ばれない")
            default: break
            // TODO: エラーケース
            }
        }
    }

    func test_signOutError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.signOutHandler = {
            return Future<JobOrder_Domain.AuthenticationModel.Output.SignOutResult, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.signOut()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.showErrorAlertErrorCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_isEnabled() {
        let param = "test"

        XCTAssertTrue(presenter.isEnabled(param, param, param), "無効になってはいけない")
        XCTAssertFalse(presenter.isEnabled("", "", ""), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(nil, nil, nil), "有効になってはいけない")

        XCTAssertFalse(presenter.isEnabled(nil, nil, param), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(nil, nil, ""), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(nil, param, param), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(nil, param, ""), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(nil, param, nil), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(nil, "", param), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(nil, "", ""), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(nil, "", nil), "有効になってはいけない")

        XCTAssertFalse(presenter.isEnabled(param, nil, nil), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(param, nil, param), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(param, nil, ""), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(param, param, ""), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(param, param, nil), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(param, "", param), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(param, "", ""), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(param, "", nil), "有効になってはいけない")

        XCTAssertFalse(presenter.isEnabled("", nil, nil), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled("", nil, param), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled("", nil, ""), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled("", param, param), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled("", param, ""), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled("", param, nil), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled("", "", param), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled("", "", nil), "有効になってはいけない")
    }
}
