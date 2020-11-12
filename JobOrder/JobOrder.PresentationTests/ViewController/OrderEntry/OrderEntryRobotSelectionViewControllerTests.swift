//
//  OrderEntryRobotSelectionViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class OrderEntryRobotSelectionViewControllerTests: XCTestCase {

    private let mock = OrderEntryRobotSelectionPresenterProtocolMock()
    private let vc = StoryboardScene.OrderEntry.robotSelection.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.robotCollection, "robotCollectionがOutletに接続されていない")
        XCTAssertNotNil(vc.continueButton, "continueButtonがOutletに接続されていない")
    }

    func test_actions() throws {
        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")
        XCTAssertNoThrow(continueButton.sendActions(for: .touchUpInside), "タップで例外発生: \(continueButton)")
    }

    func test_inject() {
        let param = "test"
        vc.inject(viewData: OrderEntryViewData(param, param))
        XCTAssertEqual(vc.viewData.form.robotIds, [param], "正常に値が設定されていない")
        XCTAssertEqual(vc.viewData.form.jobId, param, "正常に値が設定されていない")
    }

    func test_viewWillAppear() throws {
        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")

        XCTContext.runActivity(named: "Trueの場合") { _ in
            mock.isEnabledContinueButton = true
            vc.viewWillAppear(true)
            XCTAssertTrue(continueButton.isEnabled, "ボタンが無効になってはいけない: \(continueButton)")
        }

        XCTContext.runActivity(named: "Falseの場合") { _ in
            mock.isEnabledContinueButton = false
            vc.viewWillAppear(true)
            XCTAssertFalse(continueButton.isEnabled, "ボタンが有効になってはいけない: \(continueButton)")
        }

    }

    func test_tapContinueButton() {
        vc.continueButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(mock.tapContinueButtonCallCount, 1, "Presenterのメソッドが呼ばれない")
    }

    func test_numberOfItemsInSection() {
        mock.numberOfItemsInSection = 1
        let num = vc.robotCollection.dataSource?.collectionView(vc.robotCollection, numberOfItemsInSection: 0)
        XCTAssertEqual(num, 1, "正常に値が設定されていない")
    }

    func test_didSelectItemWithContinueButtonEnable() throws {
        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")
        mock.isEnabledContinueButton = true
        vc.robotCollection.delegate?.collectionView?(vc.robotCollection, didSelectItemAt: IndexPath())
        XCTAssertEqual(mock.selectItemCallCount, 1, "Presenterのメソッドが呼ばれない")
        XCTAssertTrue(continueButton.isEnabled, "ボタンが無効になってはいけない: \(continueButton)")
    }

    func test_didSelectItemWithContinueButtonDisable() throws {
        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")
        mock.isEnabledContinueButton = false
        vc.robotCollection.delegate?.collectionView?(vc.robotCollection, didSelectItemAt: IndexPath())
        XCTAssertEqual(mock.selectItemCallCount, 1, "Presenterのメソッドが呼ばれない")
        XCTAssertFalse(continueButton.isEnabled, "ボタンが有効になってはいけない: \(continueButton)")
    }

    func test_didDeselectItemWithContinueButtonEnable() throws {
        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")
        mock.isEnabledContinueButton = true
        vc.robotCollection.delegate?.collectionView?(vc.robotCollection, didSelectItemAt: IndexPath())
        XCTAssertEqual(mock.selectItemCallCount, 1, "Presenterのメソッドが呼ばれない")
        XCTAssertTrue(continueButton.isEnabled, "ボタンが無効になってはいけない: \(continueButton)")
    }

    func test_didDeselectItemWithContinueButtonDisable() throws {
        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")
        mock.isEnabledContinueButton = false
        vc.robotCollection.delegate?.collectionView?(vc.robotCollection, didSelectItemAt: IndexPath())
        XCTAssertEqual(mock.selectItemCallCount, 1, "Presenterのメソッドが呼ばれない")
        XCTAssertFalse(continueButton.isEnabled, "ボタンが有効になってはいけない: \(continueButton)")
    }
}
