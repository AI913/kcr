//
//  ConnectionSettingsViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/07/30.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class ConnectionSettingsViewControllerTests: XCTestCase {

    private let mock = ConnectionSettingsPresenterProtocolMock()
    private let vc = StoryboardScene.PasswordAuthentication.connectionSettings.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.spaceTextField, "spaceTextFieldがOutletに接続されていない")
        XCTAssertNotNil(vc.urlTextField, "urlTextFieldがOutletに接続されていない")
        XCTAssertNotNil(vc.useCloudServerSwitch, "useCloudServerSwitchがOutletに接続されていない")
        XCTAssertNotNil(vc.saveButton, "saveButtonがOutletに接続されていない")
    }

    func test_actions() throws {
        let spaceTextField = try XCTUnwrap(vc.spaceTextField, "Unwrap失敗")
        let urlTextField = try XCTUnwrap(vc.urlTextField, "Unwrap失敗")
        let useCloudServerSwitch = try XCTUnwrap(vc.useCloudServerSwitch, "Unwrap失敗")
        let saveButton = try XCTUnwrap(vc.saveButton, "Unwrap失敗")
        XCTAssertNoThrow(spaceTextField.sendActions(for: .editingChanged), "文字入力で例外発生: \(spaceTextField)")
        XCTAssertNoThrow(spaceTextField.sendActions(for: .editingDidEndOnExit), "文字入力完了で例外発生: \(spaceTextField)")
        XCTAssertNoThrow(urlTextField.sendActions(for: .editingChanged), "文字入力で例外発生: \(urlTextField)")
        XCTAssertNoThrow(urlTextField.sendActions(for: .editingDidEndOnExit), "文字入力完了で例外発生: \(urlTextField)")
        XCTAssertNoThrow(useCloudServerSwitch.sendActions(for: .valueChanged), "変更で例外発生: \(useCloudServerSwitch)")
        XCTAssertNoThrow(saveButton.sendActions(for: .touchUpInside), "タップで例外発生: \(saveButton)")
    }

    func test_viewWillAppear() throws {
        let spaceTextField = try XCTUnwrap(vc.spaceTextField, "Unwrap失敗")
        let useCloudServerSwitch = try XCTUnwrap(vc.useCloudServerSwitch, "Unwrap失敗")
        let urlTextField = try XCTUnwrap(vc.urlTextField, "Unwrap失敗")
        let param = "test"

        XCTContext.runActivity(named: "Spaceが未設定の場合") { _ in
            mock.isRegisteredSpace = false
            vc.viewWillAppear(true)
            XCTAssertEqual(spaceTextField.text, "", "テキストを設定してはいけない: \(spaceTextField)")
            XCTAssertTrue(useCloudServerSwitch.isOn, "スイッチがOFFになってはいけない: \(useCloudServerSwitch)")
            XCTAssertEqual(urlTextField.text, "", "テキストを設定してはいけない: \(urlTextField)")
            XCTAssertEqual(mock.changedUseCloudServerSwitchCallCount, 1, "Presenterのメソッドが呼ばれない")
        }

        XCTContext.runActivity(named: "Spaceが設定済みでUseCloudServerがOFFの場合") { _ in
            mock.isRegisteredSpace = true
            mock.registeredSpaceName = param
            mock.registeredServerUrl = param
            mock.registeredUseCloudServer = false
            vc.viewWillAppear(true)
            XCTAssertEqual(spaceTextField.text, param, "テキストが設定されていない: \(spaceTextField)")
            XCTAssertEqual(urlTextField.text, param, "テキストが設定されていない: \(urlTextField)")
            XCTAssertFalse(useCloudServerSwitch.isOn, "スイッチがONになってはいけない: \(useCloudServerSwitch)")
        }

        XCTContext.runActivity(named: "Spaceが設定済みでUseCloudServerがONの場合") { _ in
            mock.isRegisteredSpace = true
            mock.registeredSpaceName = param
            mock.registeredServerUrl = param
            mock.registeredUseCloudServer = true
            vc.viewWillAppear(true)
            XCTAssertEqual(spaceTextField.text, param, "テキストが設定されていない: \(spaceTextField)")
            XCTAssertTrue(useCloudServerSwitch.isOn, "スイッチがOFFになってはいけない: \(useCloudServerSwitch)")
            XCTAssertEqual(urlTextField.text, "", "テキストを設定してはいけない: \(urlTextField)")
        }
    }

    func test_urlTextFieldEnabled() throws {
        let urlTextField = try XCTUnwrap(vc.urlTextField, "Unwrap失敗")

        XCTContext.runActivity(named: "スイッチがONの場合") { _ in
            vc.useCloudServerSwitch.isOn = true
            vc.useCloudServerSwitch.sendActions(for: .valueChanged)
            XCTAssertFalse(urlTextField.isEnabled, "テキストフィールドが有効になってはいけない: \(urlTextField)")
        }

        XCTContext.runActivity(named: "スイッチがOFFの場合") { _ in
            vc.useCloudServerSwitch.isOn = false
            vc.useCloudServerSwitch.sendActions(for: .valueChanged)
            XCTAssertTrue(urlTextField.isEnabled, "テキストフィールドが無効になってはいけない: \(urlTextField)")
        }
    }

    func test_saveButtonEnabled() throws {
        let saveButton = try XCTUnwrap(vc.saveButton, "Unwrap失敗")
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            mock.isEnabledSaveButton = false
            vc.spaceTextField.text = param
            vc.spaceTextField.sendActions(for: .editingChanged)
            XCTAssertFalse(saveButton.isEnabled, "ボタンが有効になってはいけない: \(saveButton)")
        }

        XCTContext.runActivity(named: "spaceを入力") { _ in
            mock.isEnabledSaveButton = true
            vc.spaceTextField.text = param
            vc.spaceTextField.sendActions(for: .editingChanged)
            XCTAssertTrue(saveButton.isEnabled, "ボタンが無効になってはいけない: \(saveButton)")
        }
    }
}
