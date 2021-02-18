//
//  StartupPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class StartupPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let vc = StartupViewControllerProtocolMock()
    private let auth = JobOrder_Domain.AuthenticationUseCaseProtocolMock()
    private let settings = JobOrder_Domain.SettingsUseCaseProtocolMock()
    private lazy var presenter = StartupPresenter(authUseCase: auth,
                                                  settingsUseCase: settings,
                                                  vc: vc)
    override func setUpWithError() throws {
        auth.initializeServerHandler = { _ in
            return Future<AuthenticationModel.Output.InitializeServer, Error> { promise in }.eraseToAnyPublisher()
        }
    }
    override func tearDownWithError() throws {}

    func test_isEnabledNextButton() {
        let param = String.arbitrary.generate
        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(presenter.isEnabledNextButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "空文字の場合") { _ in
            presenter.space = ""
            XCTAssertFalse(presenter.isEnabledNextButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            presenter.space = param
            XCTAssertTrue(presenter.isEnabledNextButton, "有効にならなくてはいけない")
        }
    }

    func test_viewDidAppear() {
        let param = String.arbitrary.generate

        XCTContext.runActivity(named: "未設定の場合") { _ in
            settings.spaceName = nil
            presenter.viewDidAppear()
            XCTAssertEqual(vc.showSpaceViewCallCount, 1, "ViewControllerのメソッドが呼ばれない")
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            settings.spaceName = param
            presenter.viewDidAppear()
            XCTAssertEqual(auth.initializeServerCallCount, 1, "AuthUseCaseのメソッドが呼ばれない")
        }
    }

    func test_readyToConnectServer() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let space = String.arbitrary.generate

        auth.initializeServerHandler = { space in
            return Future<AuthenticationModel.Output.InitializeServer, Error> { promise in
                promise(.success(.init(result: true)))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.readyToConnectServer(space)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(auth.initializeServerCallCount, 1, "AuthUseCaseのメソッドが呼ばれない")
    }

    func test_readyToConnectServerError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion error")
        completionExpectation.isInverted = true
        let space = String.arbitrary.generate

        auth.initializeServerHandler = { space in
            return Future<AuthenticationModel.Output.InitializeServer, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.readyToConnectServer(space)
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
        XCTAssertEqual(vc.showSpaceViewCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }
}
