//
//  ConnectionSettingsPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class ConnectionSettingsPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let vc = ConnectionSettingsViewControllerProtocolMock()
    private let auth = JobOrder_Domain.AuthenticationUseCaseProtocolMock()
    private let settings = JobOrder_Domain.SettingsUseCaseProtocolMock()
    private lazy var presenter = ConnectionSettingsPresenter(authUseCase: auth,
                                                             settingsUseCase: settings,
                                                             vc: vc)

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_tapResetButtonWithSignIn() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        auth.isSignedIn = true

        auth.signOutHandler = {
            return Future<AuthenticationModel.Output.SignOutResult, Error> { promise in
                promise(.success(.init(.success)))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.tapResetButton()
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertNil(settings.spaceName, "値を取得できてはいけない")
        XCTAssertEqual(vc.backCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_tapResetButtonErrorWithSignIn() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        auth.isSignedIn = true

        auth.signOutHandler = {
            return Future<AuthenticationModel.Output.SignOutResult, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.tapResetButton()
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_tapResetButtonWithSignOut() {
        auth.isSignedIn = false

        presenter.tapResetButton()
        XCTAssertNil(settings.spaceName, "値を取得できてはいけない")
        XCTAssertEqual(auth.signOutCallCount, 0, "AuthUseCaseのメソッドが呼ばれてはいけない")
        XCTAssertEqual(vc.backCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }
}
