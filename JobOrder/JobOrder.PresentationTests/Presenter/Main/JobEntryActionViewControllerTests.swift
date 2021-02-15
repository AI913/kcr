//
//  JobEntryActionViewControllerTests.swift
//  JobOrderTests
//
//  Created by Frontarc on 2021/02/15.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class JobEntryActionViewControllerTests: XCTestCase {

//    private let mock = JobEntryActionViewPresenterProtocolMock()
    private let vc = StoryboardScene.OrderEntry.jobSelection.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
//        vc.presenter = mock
    }

    override func tearDownWithError() throws {
        let cancelBarButtonItem = try XCTUnwrap(vc.cancelBarButtonItem, "Unwrap失敗")
        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")
        XCTAssertNoThrow(cancelBarButtonItem.target?.perform(cancelBarButtonItem.action, with: nil), "タップで例外発生: \(cancelBarButtonItem)")
        XCTAssertNoThrow(continueButton.sendActions(for: .touchUpInside), "タップで例外発生: \(continueButton)")
    }

    func testExample() throws {
        let param = "test"
        vc.inject(jobId: param, robotId: param)
        XCTAssertEqual(vc.viewData.form.robotIds, [param], "正常に値が設定されていない")
        XCTAssertEqual(vc.viewData.form.jobId, param, "正常に値が設定されていない")
    }
}

//
//  OrderEntryJobSelectionViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

//import XCTest
//@testable import JobOrder_Presentation
//
//class OrderEntryJobSelectionViewControllerTests: XCTestCase {
//
//    private let mock = OrderEntryJobSelectionPresenterProtocolMock()
//    private let vc = StoryboardScene.OrderEntry.jobSelection.instantiate()
//
//    override func setUpWithError() throws {
//        let window = UIWindow(frame: UIScreen.main.bounds)
//        window.rootViewController = vc
//        window.makeKeyAndVisible()
//        vc.presenter = mock
//    }
//
//    override func tearDownWithError() throws {}
//
//    func test_outlets() {
//        XCTAssertNotNil(vc.jobCollection, "jobCollectionがOutletに接続されていない")
//        XCTAssertNotNil(vc.cancelBarButtonItem, "cancelBarButtonItemがOutletに接続されていない")
//        XCTAssertNotNil(vc.continueButton, "continueButtonがOutletに接続されていない")
//    }
//
//    func test_actions() throws {
//        let cancelBarButtonItem = try XCTUnwrap(vc.cancelBarButtonItem, "Unwrap失敗")
//        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")
//        XCTAssertNoThrow(cancelBarButtonItem.target?.perform(cancelBarButtonItem.action, with: nil), "タップで例外発生: \(cancelBarButtonItem)")
//        XCTAssertNoThrow(continueButton.sendActions(for: .touchUpInside), "タップで例外発生: \(continueButton)")
//    }
//
//    func test_inject() {
//        let param = "test"
//        vc.inject(jobId: param, robotId: param)
//        XCTAssertEqual(vc.viewData.form.robotIds, [param], "正常に値が設定されていない")
//        XCTAssertEqual(vc.viewData.form.jobId, param, "正常に値が設定されていない")
//    }
//
//    func test_viewWillAppear() throws {
//        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")
//
//        XCTContext.runActivity(named: "Trueの場合") { _ in
//            mock.isEnabledContinueButton = true
//            vc.viewWillAppear(true)
//            XCTAssertTrue(continueButton.isEnabled, "ボタンが無効になってはいけない: \(continueButton)")
//        }
//
//        XCTContext.runActivity(named: "Falseの場合") { _ in
//            mock.isEnabledContinueButton = false
//            vc.viewWillAppear(true)
//            XCTAssertFalse(continueButton.isEnabled, "ボタンが有効になってはいけない: \(continueButton)")
//        }
//
//    }
//
//    func test_tapContinueButton() {
//        vc.continueButton.sendActions(for: .touchUpInside)
//        XCTAssertEqual(mock.tapContinueButtonCallCount, 1, "Presenterのメソッドが呼ばれない")
//    }
//
//    func test_numberOfItemsInSection() {
//        mock.numberOfItemsInSection = 1
//        let num = vc.jobCollection.dataSource?.collectionView(vc.jobCollection, numberOfItemsInSection: 0)
//        XCTAssertEqual(num, 1, "正常に値が設定されていない")
//    }
//
//    func test_didSelectItemWithContinueButtonEnable() throws {
//        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")
//        mock.isEnabledContinueButton = true
//        vc.jobCollection.delegate?.collectionView?(vc.jobCollection, didSelectItemAt: IndexPath())
//        XCTAssertEqual(mock.selectItemCallCount, 1, "Presenterのメソッドが呼ばれない")
//        XCTAssertTrue(continueButton.isEnabled, "ボタンが無効になってはいけない: \(continueButton)")
//    }
//
//    func test_didSelectItemWithContinueButtonDisable() throws {
//        let continueButton = try XCTUnwrap(vc.continueButton, "Unwrap失敗")
//        mock.isEnabledContinueButton = false
//        vc.jobCollection.delegate?.collectionView?(vc.jobCollection, didSelectItemAt: IndexPath())
//        XCTAssertEqual(mock.selectItemCallCount, 1, "Presenterのメソッドが呼ばれない")
//        XCTAssertFalse(continueButton.isEnabled, "ボタンが有効になってはいけない: \(continueButton)")
//    }
//}
