//
//  RobotDetailViewControllerTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_Presentation

class RobotDetailViewControllerTests: XCTestCase {

    private let mock = RobotDetailPresenterProtocolMock()
    private let vc = StoryboardScene.Main.robotDetail.instantiate()

    override func setUpWithError() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.presenter = mock
    }

    override func tearDownWithError() throws {}

    func test_outlets() {
        XCTAssertNotNil(vc.moreBarButtonItem, "moreBarButtonItemがOutletに接続されていない")
        XCTAssertNotNil(vc.displayNameValueLabel, "displayNameValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.robotImageView, "robotImageViewがOutletに接続されていない")
        XCTAssertNotNil(vc.robotTypeValueLabel, "robotTypeValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.serialValueLabel, "serialValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.overviewValueLabel, "overviewValueLabelがOutletに接続されていない")
        XCTAssertNotNil(vc.segmentedControl, "segmentedControlがOutletに接続されていない")
        XCTAssertNotNil(vc.containerView, "containerViewがOutletに接続されていない")
        XCTAssertNotNil(vc.containerViewHeight, "containerViewHeightがOutletに接続されていない")
        XCTAssertNotNil(vc.orderButton, "orderButtonがOutletに接続されていない")
    }

    func test_actions() throws {
        let moreBarButtonItem = try XCTUnwrap(vc.moreBarButtonItem, "Unwrap失敗")
        let segmentedControl = try XCTUnwrap(vc.segmentedControl, "Unwrap失敗")
        let orderButton = try XCTUnwrap(vc.orderButton, "Unwrap失敗")
        XCTAssertNoThrow(moreBarButtonItem.target?.perform(moreBarButtonItem.action, with: nil), "タップで例外発生: \(moreBarButtonItem)")
        XCTAssertNoThrow(segmentedControl.sendActions(for: .valueChanged), "セグメント選択で例外発生: \(segmentedControl)")
        XCTAssertNoThrow(orderButton.sendActions(for: .touchUpInside), "タップで例外発生: \(orderButton)")
    }

    func test_inject() {
        let param = "test"
        vc.inject(viewData: MainViewData.Robot(id: param))
        XCTAssertEqual(vc.viewData.id, param, "正常に値が設定されていない")
    }

    func test_viewWillAppear() throws {
        let param = "test"
        let bundle = Bundle(identifier: "jp.co.kyocera.robotics.client.joborder-Presentation")
        let noImage = UIImage(named: "img_robot_no_image.png", in: bundle, with: nil)
        let displayNameValueLabel = try XCTUnwrap(vc.displayNameValueLabel, "Unwrap失敗")
        let overviewValueLabel = try XCTUnwrap(vc.overviewValueLabel, "Unwrap失敗")
        let robotTypeValueLabel = try XCTUnwrap(vc.robotTypeValueLabel, "Unwrap失敗")
        let serialValueLabel = try XCTUnwrap(vc.serialValueLabel, "Unwrap失敗")
        let robotImageView = try XCTUnwrap(vc.robotImageView, "Unwrap失敗")

        XCTContext.runActivity(named: "Robot未選択の場合") { _ in
            mock.data = MainViewData.Robot(id: nil)
            mock.displayName = param
            mock.overview = param
            mock.typeName = param
            mock.stateImageName = param
            mock.serialName = param
            mock.imageHandler = { completion in
                completion(Data())
            }
            vc.viewWillAppear(true)
            XCTAssertNotEqual(displayNameValueLabel.text, param, "テキストを設定してはいけない: \(displayNameValueLabel)")
            XCTAssertNotEqual(overviewValueLabel.text, param, "テキストを設定してはいけない: \(overviewValueLabel)")
            XCTAssertNotEqual(robotTypeValueLabel.text, param, "テキストを設定してはいけない: \(robotTypeValueLabel)")
            XCTAssertNotEqual(serialValueLabel.text, param, "テキストを設定してはいけない: \(serialValueLabel)")
            XCTAssertEqual(robotImageView.image?.pngData(), noImage?.pngData(), "NoImage画像が設定されていない: \(robotImageView)")
        }

        XCTContext.runActivity(named: "Robot選択済みの場合") { _ in
            mock.data = MainViewData.Robot(id: param)
            mock.displayName = param
            mock.overview = param
            mock.typeName = param
            mock.stateImageName = param
            mock.serialName = param
            mock.imageHandler = { completion in
                completion(Data())
            }
            vc.viewWillAppear(true)
            XCTAssertEqual(displayNameValueLabel.text, param, "テキストが設定されていない: \(displayNameValueLabel)")
            XCTAssertEqual(overviewValueLabel.text, param, "テキストが設定されていない: \(overviewValueLabel)")
            XCTAssertEqual(robotTypeValueLabel.text, param, "テキストが設定されていない: \(robotTypeValueLabel)")
            XCTAssertTrue(robotTypeValueLabel.isEnabled, "テキストが設定されていない: \(robotTypeValueLabel)")
            XCTAssertEqual(serialValueLabel.text, param, "テキストが設定されていない: \(serialValueLabel)")
            XCTAssertTrue(serialValueLabel.isEnabled, "テキストが設定されていない: \(serialValueLabel)")
            XCTAssertEqual(robotImageView.image, UIImage(data: Data()), "画像が設定されていない: \(robotImageView)")
        }
    }

    func test_showActionSheet() {
        vc.showActionSheet(vc.moreBarButtonItem)
        XCTAssertTrue(vc.presentedViewController is UIAlertController, "アクションシートが表示されない")
    }

    func test_tapOrderButton() {
        vc.orderButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(mock.tapOrderEntryButtonCallCount, 1, "Presenterのメソッドが呼ばれない")
    }
}
