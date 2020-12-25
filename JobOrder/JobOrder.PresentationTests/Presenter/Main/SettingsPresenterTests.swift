//
//  SettingsPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class SettingsPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    @Published private var authProcessing: Bool = false
    @Published private var dataProcessing: Bool = false
    private let vc = SettingsViewControllerProtocolMock()
    private let settings = JobOrder_Domain.SettingsUseCaseProtocolMock()
    private let auth = JobOrder_Domain.AuthenticationUseCaseProtocolMock()
    private let mqtt = JobOrder_Domain.MQTTUseCaseProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let analytics = JobOrder_Domain.AnalyticsUseCaseProtocolMock()
    private lazy var presenter = SettingsPresenter(useCase: settings,
                                                   authUseCase: auth,
                                                   mqttUseCase: mqtt,
                                                   dataUseCase: data,
                                                   analyticsUseCase: analytics,
                                                   vc: vc)
    override func setUpWithError() throws {
        auth.processingPublisher = $authProcessing
        data.processingPublisher = $dataProcessing
        auth.signOutHandler = {
            return Future<JobOrder_Domain.AuthenticationModel.Output.SignOutResult, Error> { promise in }.eraseToAnyPublisher()
        }
        data.syncDataHandler = {
            return Future<JobOrder_Domain.DataManageModel.Output.SyncData, Error> { promise in }.eraseToAnyPublisher()
        }
    }

    override func tearDownWithError() throws {}

    func test_numberOfSections() {
        XCTAssertEqual(presenter.numberOfSections, SettingsViewData.SettingsMenuSection.allCases.count, "正しい値が取得できていない")
    }

    func test_titleForHeaderInSection() {
        SettingsViewData.SettingsMenuSection.allCases.enumerated().forEach {
            XCTAssertEqual(presenter.titleForHeaderInSection(section: $0.offset), $0.element.titleForHeader, "正しい値が取得できていない")
        }
    }

    func test_titleForFooterInSection() {
        SettingsViewData.SettingsMenuSection.allCases.enumerated().forEach {
            XCTAssertEqual(presenter.titleForFooterInSection(section: $0.offset), $0.element.titleForFooter, "正しい値が取得できていない")
        }
    }

    func test_numberOfRowsInSection() {
        SettingsViewData.SettingsMenuSection.allCases.enumerated().forEach { section in
            let count = SettingsViewData.SettingsMenu.allCases.filter { $0.section == section.element }.count
            XCTAssertEqual(presenter.numberOfRowsInSection(section: section.offset), count, "正しい値が取得できていない")
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

    func test_isRestoreIdentifierWithSet() {
        presenter.isRestoredIdentifier = true
        XCTAssertEqual(settings.restoreIdentifierSetCallCount, 1, "SettingsUseCaseのメソッドが呼ばれない")
    }

    func test_isUsedBiometricsAuthentication() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(presenter.isUsedBiometricsAuthentication, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Trueが設定済みの場合") { _ in
            settings.useBiometricsAuthentication = true
            XCTAssertTrue(presenter.isUsedBiometricsAuthentication, "無効になってはいけない")
        }

        XCTContext.runActivity(named: "Falseが設定済みの場合") { _ in
            settings.useBiometricsAuthentication = false
            XCTAssertFalse(presenter.isUsedBiometricsAuthentication, "有効になってはいけない")
        }
    }

    func test_isUsedBiometricsAuthenticationWithSet() {
        presenter.isUsedBiometricsAuthentication = true
        XCTAssertEqual(settings.useBiometricsAuthenticationSetCallCount, 1, "SettingsUseCaseのメソッドが呼ばれない")
        XCTAssertEqual(analytics.recordEventSwitchCallCount, 1, "AnalyticsUseCaseのメソッドが呼ばれない")
    }

    func test_canUseBiometricsWithErrorDescription() {

        XCTContext.runActivity(named: "Trueの場合") { _ in
            auth.canUseBiometricsAuthentication = AuthenticationModel.Output.BiometricsAuthentication(result: true, errorDescription: nil)
            XCTAssertTrue(presenter.canUseBiometricsWithErrorDescription.0, "無効になってはいけない")
            XCTAssertNil(presenter.canUseBiometricsWithErrorDescription.1, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Falseの場合") { _ in
            let param = "test"
            auth.canUseBiometricsAuthentication = AuthenticationModel.Output.BiometricsAuthentication(result: false, errorDescription: param)
            XCTAssertFalse(presenter.canUseBiometricsWithErrorDescription.0, "有効になってはいけない")
            XCTAssertEqual(presenter.canUseBiometricsWithErrorDescription.1, param, "正しい値が取得できていない: \(param)")
        }
    }

    func test_syncedDate() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            settings.lastSynced = nil
            XCTAssertNil(presenter.syncedDate, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "設定されている場合") { _ in
            settings.lastSynced = 1_592_477_407_000
            XCTAssertNotNil(presenter.syncedDate, "値が取得できなければいけない")
        }
    }

    func test_endpointId() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            analytics.endpointId = nil
            XCTAssertNil(presenter.endpointId, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "設定されている場合") { _ in
            analytics.endpointId = param
            #if DEBUG
            XCTAssertNotNil(presenter.endpointId, "値が取得できなければいけない")
            #else
            XCTAssertNil(presenter.endpointId, "値を取得できてはいけない")
            #endif
        }
    }

    func test_email() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let param = "test"

        auth.emailHandler = {
            return Future<JobOrder_Domain.AuthenticationModel.Output.Email, Error> { promise in
                promise(.success(.init(param)))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.email { address in
            completionExpectation.fulfill()
        }

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_emailError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.emailHandler = {
            return Future<JobOrder_Domain.AuthenticationModel.Output.Email, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.email { address in
            completionExpectation.fulfill()
        }

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_selectRow() {

        XCTContext.runActivity(named: "RobotVideoの場合") { _ in
            let indexPath = IndexPath(row: 1, section: 1)
            presenter.selectRow(indexPath: indexPath)
            XCTAssertEqual(analytics.recordEventButtonCallCount, 1, "AnalyticsUseCaseのメソッドが呼ばれない")
            XCTAssertEqual(vc.transitionToRobotVideoScreenCallCount, 1, "ViewControllerのメソッドが呼ばれない")
        }

        XCTContext.runActivity(named: "AboutAppの場合") { _ in
            let indexPath = IndexPath(row: 0, section: 2)
            presenter.selectRow(indexPath: indexPath)
            XCTAssertEqual(analytics.recordEventButtonCallCount, 2, "AnalyticsUseCaseのメソッドが呼ばれない")
            XCTAssertEqual(vc.transitionToAboutAppScreenCallCount, 1, "ViewControllerのメソッドが呼ばれない")
        }
    }

    func test_subscribeUseCaseProcessing() {
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        // 初期化時に登録
        presenter = SettingsPresenter(useCase: settings,
                                      authUseCase: auth,
                                      mqttUseCase: mqtt,
                                      dataUseCase: data,
                                      analyticsUseCase: analytics,
                                      vc: vc)

        wait(for: [completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.changedProcessingCallCount, 2, "ViewControllerのメソッドが呼ばれない")
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
                XCTAssertEqual(vc.backCallCount, 1, "ViewControllerのメソッドが呼ばれない")
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

    func test_sync() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        data.syncDataHandler = {
            return Future<JobOrder_Domain.DataManageModel.Output.SyncData, Error> { promise in
                let model = JobOrder_Domain.DataManageModel.Output.SyncData(jobEntities: [],
                                                                            robotEntities: [],
                                                                            actionLibraryEntities: [],
                                                                            aiLibraryEntities: [])
                promise(.success(model))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.sync()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(mqtt.subscribeRobotsCallCount, 1, "MQTTUseCaseのメソッドが呼ばれない")
        XCTAssertEqual(vc.reloadTableCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_syncError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion error")
        completionExpectation.isInverted = true

        data.syncDataHandler = {
            return Future<JobOrder_Domain.DataManageModel.Output.SyncData, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.sync()

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.showErrorAlertCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }
}
