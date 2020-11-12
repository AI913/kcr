//
//  MailVerificationEntryPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/05/21.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class MailVerificationEntryPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    @Published private var processing: Bool = false
    private let vc = MailVerificationEntryViewControllerProtocolMock()
    private let auth = JobOrder_Domain.AuthenticationUseCaseProtocolMock()
    private lazy var presenter = MailVerificationEntryPresenter(useCase: auth,
                                                                vc: vc)

    override func setUpWithError() throws {
        auth.processingPublisher = $processing
        auth.registerAuthenticationStateChangeHandler = {
            return Future<JobOrder_Domain.AuthenticationModel.Output.AuthenticationState, Never> { promise in }.eraseToAnyPublisher()
        }
    }

    override func tearDownWithError() throws {}

    func test_isEnabledSendButton() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(presenter.isEnabledSendButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Identifierが設定されていない場合") { _ in
            presenter.changedIdentifierTextField(nil)
            XCTAssertFalse(presenter.isEnabledSendButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Identifierが設定されている場合") { _ in
            presenter.changedIdentifierTextField(param)
            XCTAssertTrue(presenter.isEnabledSendButton, "無効になってはいけない")
        }
    }

    func test_tapSendButton() {
        let param = "test"

        JobOrder_Domain.AuthenticationModel.Output.ForgotPasswordResult.State.allCases.forEach { state in
            let handlerExpectation = expectation(description: "handler \(state)")
            let completionExpectation = expectation(description: "completion \(state)")
            completionExpectation.isInverted = true

            auth.forgotPasswordHandler = { identifier in
                return Future<JobOrder_Domain.AuthenticationModel.Output.ForgotPasswordResult, Error> { promise in
                    promise(.success(.init(state)))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            presenter.changedIdentifierTextField(param)
            presenter.tapSendButton()

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)

            switch state {
            case .confirmationCodeSent:
                XCTAssertEqual(vc.transitionToConfirmScreenCallCount, 1, "ViewControllerのメソッドが呼ばれない")
            default: break
            // TODO: エラーケース
            }
        }
    }

    func test_tapSendButtonNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        handlerExpectation.isInverted = true
        completionExpectation.isInverted = true

        auth.forgotPasswordHandler = { identifier in
            return Future<JobOrder_Domain.AuthenticationModel.Output.ForgotPasswordResult, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.tapSendButton()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(auth.forgotPasswordCallCount, 0, "AuthenticationUseCaseのメソッドが呼ばれてはいけない")
    }

    func test_tapSendButtonError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"

        auth.forgotPasswordHandler = { identifier in
            return Future<JobOrder_Domain.AuthenticationModel.Output.ForgotPasswordResult, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.changedIdentifierTextField(param)
        presenter.tapSendButton()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_subscribeUseCaseProcessing() {
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        // 初期化時に登録
        presenter = MailVerificationEntryPresenter(useCase: auth, vc: vc)

        wait(for: [completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.changedProcessingCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_isEnabled() {
        let param = "test"
        XCTAssertTrue(presenter.isEnabled(param), "無効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(""), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(nil), "有効になってはいけない")
    }
}
