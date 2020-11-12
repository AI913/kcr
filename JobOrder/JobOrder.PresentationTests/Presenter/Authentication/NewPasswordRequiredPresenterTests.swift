//
//  NewPasswordRequiredPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class NewPasswordRequiredPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    @Published private var processing: Bool = false
    private let vc = NewPasswordRequiredViewControllerProtocolMock()
    private let auth = JobOrder_Domain.AuthenticationUseCaseProtocolMock()
    private lazy var presenter = NewPasswordRequiredPresenter(useCase: auth,
                                                              vc: vc)

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

    func test_isEnabledUpdateButton() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(presenter.isEnabledUpdateButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Passwordが設定されていない場合") { _ in
            presenter.changedPasswordTextField(nil)
            XCTAssertFalse(presenter.isEnabledUpdateButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Passwordが設定されている場合") { _ in
            presenter.changedPasswordTextField(param)
            XCTAssertTrue(presenter.isEnabledUpdateButton, "無効になってはいけない")
        }
    }

    func test_tapUpdateButton() {
        let param = "test"
        var callCount = 0

        JobOrder_Domain.AuthenticationModel.Output.SignInResult.State.allCases.forEach { state in
            let handlerExpectation = expectation(description: "handler \(state)")
            let completionExpectation = expectation(description: "completion \(state)")
            completionExpectation.isInverted = true

            auth.confirmSignInHandler = { newPassword in
                return Future<JobOrder_Domain.AuthenticationModel.Output.SignInResult, Error> { promise in
                    promise(.success(.init(state)))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            presenter.changedPasswordTextField(param)
            presenter.tapUpdateButton()

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

            switch state {
            case .signedIn:
                XCTAssertEqual(auth.signOutCallCount, 1, "AuthenticationUseCaseのメソッドが呼ばれない")
            default:
                callCount += 1
                XCTAssertEqual(vc.transitionToPasswordAuthenticationScreenCallCount, callCount, "ViewControllerのメソッドが呼ばれない")
            }
        }
    }

    func test_tapUpdateButtonNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        handlerExpectation.isInverted = true
        completionExpectation.isInverted = true

        auth.confirmSignInHandler = { newPassword in
            return Future<JobOrder_Domain.AuthenticationModel.Output.SignInResult, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.changedPasswordTextField(nil)
        presenter.tapUpdateButton()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(auth.confirmSignInCallCount, 0, "AuthenticationUseCaseのメソッドが呼ばれてはいけない")
    }

    func test_tapUpdateButtonError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"

        auth.confirmSignInHandler = { newPassword in
            return Future<JobOrder_Domain.AuthenticationModel.Output.SignInResult, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.changedPasswordTextField(param)
        presenter.tapUpdateButton()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_subscribeUseCaseProcessing() {
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        // 初期化時に登録
        presenter = NewPasswordRequiredPresenter(useCase: auth, vc: vc)

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
                XCTAssertEqual(vc.transitionToPasswordAuthenticationScreenCallCount, 1, "ViewControllerのメソッドが呼ばれない")
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
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_isEnabled() {
        let param = "test"
        XCTAssertTrue(presenter.isEnabled(param), "無効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(""), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(nil), "有効になってはいけない")
    }
}
