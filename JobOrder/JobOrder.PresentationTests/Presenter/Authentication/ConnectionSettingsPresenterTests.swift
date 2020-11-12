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

    private let vc = ConnectionSettingsViewControllerProtocolMock()
    private let settings = JobOrder_Domain.SettingsUseCaseProtocolMock()
    private lazy var presenter = ConnectionSettingsPresenter(useCase: settings,
                                                             vc: vc)

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_isRegisterdSpace() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(presenter.isRegisteredSpace, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "設定済みの場合") { _ in
            settings.spaceName = param
            XCTAssertTrue(presenter.isRegisteredSpace, "無効になってはいけない")
        }

        XCTContext.runActivity(named: "nilの場合") { _ in
            settings.spaceName = nil
            XCTAssertFalse(presenter.isRegisteredSpace, "有効になってはいけない")
        }
    }

    func test_registerdSpaceName() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(presenter.registeredSpaceName, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            settings.spaceName = param
            XCTAssertEqual(presenter.registeredSpaceName, param, "正しい値が取得できていない: \(param)")
        }
    }

    func test_registeredServerUrl() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(presenter.registeredServerUrl, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            settings.serverUrl = param
            XCTAssertEqual(presenter.registeredServerUrl, param, "正しい値が取得できていない: \(param)")
        }
    }

    func test_registeredUseCloudServer() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(presenter.registeredUseCloudServer, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Trueが設定されている場合") { _ in
            settings.useCloudServer = true
            XCTAssertTrue(presenter.registeredUseCloudServer, "無効になってはいけない")
        }

        XCTContext.runActivity(named: "Falseが設定されている場合") { _ in
            settings.useCloudServer = false
            XCTAssertFalse(presenter.registeredUseCloudServer, "有効になってはいけない")
        }
    }

    func test_isEnabledSaveButton() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(presenter.isEnabledSaveButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "SpaceNameが設定されていない場合") { _ in
            presenter.changedSpaceNameTextField(nil)
            XCTAssertFalse(presenter.isEnabledSaveButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "CloudServerがOFFでServerUrlがnilの場合") { _ in
            presenter.changedSpaceNameTextField(param)
            presenter.changedUseCloudServerSwitch(false)
            presenter.changedServerUrlTextField(nil)
            XCTAssertFalse(presenter.isEnabledSaveButton, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "CloudServerがONの場合") { _ in
            presenter.changedSpaceNameTextField(param)
            presenter.changedUseCloudServerSwitch(true)
            XCTAssertTrue(presenter.isEnabledSaveButton, "無効になってはいけない")
        }

        XCTContext.runActivity(named: "CloudServerがOFFでServerUrlが設定されている場合") { _ in
            presenter.changedSpaceNameTextField(param)
            presenter.changedUseCloudServerSwitch(false)
            presenter.changedServerUrlTextField(param)
            XCTAssertTrue(presenter.isEnabledSaveButton, "無効になってはいけない")
        }
    }

    func test_tapSaveButton() {
        presenter.tapSaveButton()
        XCTAssertEqual(settings.spaceNameSetCallCount, 1, "SettingsUseCaseのメソッドが呼ばれない")
        XCTAssertEqual(settings.serverUrlSetCallCount, 1, "SettingsUseCaseのメソッドが呼ばれない")
        XCTAssertEqual(settings.useCloudServerSetCallCount, 1, "SettingsUseCaseのメソッドが呼ばれない")
        XCTAssertEqual(vc.backCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_isEnabled() {
        let param = "test"
        XCTAssertTrue(presenter.isEnabled(param), "無効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(""), "有効になってはいけない")
        XCTAssertFalse(presenter.isEnabled(nil), "有効になってはいけない")
    }
}
