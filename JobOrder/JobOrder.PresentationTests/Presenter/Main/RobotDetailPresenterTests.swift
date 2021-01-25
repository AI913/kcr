//
//  RobotDetailPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class RobotDetailPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let vc = RobotDetailViewControllerProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let viewData = MainViewData.Robot()
    private lazy var presenter = RobotDetailPresenter(useCase: data,
                                                      vc: vc,
                                                      viewData: viewData)
    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_displayName() {
        let robots = DataManageModel.Output.Robot.arbitrary.sample
        let obj = robots.randomElement()!
        let param = obj.id
        XCTContext.runActivity(named: "Dataが未設定の場合") { _ in
            presenter.data.id = nil
            data.robots = robots
            XCTAssertNil(presenter.displayName, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Robotsが未設定の場合") { _ in
            presenter.data.id = param
            data.robots = nil
            XCTAssertNil(presenter.displayName, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            presenter.data.id = param
            data.robots = robots
            XCTAssertEqual(presenter.displayName, obj.name, "正しい値が取得できていない: \(obj)")
        }
    }

    func test_overview() {
        let robots = DataManageModel.Output.Robot.arbitrary.sample
        let obj = robots.randomElement()!
        let param = obj.id
        XCTContext.runActivity(named: "Dataが未設定の場合") { _ in
            presenter.data.id = nil
            data.robots = robots
            XCTAssertNil(presenter.overview, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Robotsが未設定の場合") { _ in
            presenter.data.id = param
            data.robots = nil
            XCTAssertNil(presenter.overview, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            presenter.data.id = param
            data.robots = robots
            XCTAssertEqual(presenter.overview, obj.overview, "正しい値が取得できていない: \(obj)")
        }
    }

    func test_stateName() {
        let robots = DataManageModel.Output.Robot.arbitrary.suchThat({ $0.state != .unknown }).sample
        let obj = robots.randomElement()!
        let param = obj.id
        XCTContext.runActivity(named: "Dataが未設定の場合") { _ in
            presenter.data.id = nil
            data.robots = robots
            let state = MainViewData.RobotState(.unknown)
            XCTAssertEqual(presenter.stateName, state.displayName, "デフォルト値が取得できていない: \(state.displayName)")
        }

        XCTContext.runActivity(named: "Robotsが未設定の場合") { _ in
            presenter.data.id = param
            data.robots = nil
            let state = MainViewData.RobotState(.unknown)
            XCTAssertEqual(presenter.stateName, state.displayName, "デフォルト値が取得できていない: \(state.displayName)")
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            presenter.data.id = param
            data.robots = robots
            let state = MainViewData.RobotState(obj.state)
            XCTAssertEqual(presenter.stateName, state.displayName, "正しい値が取得できていない: \(obj)")
        }
    }

    func test_stateImageName() {
        let robots = DataManageModel.Output.Robot.arbitrary.suchThat({ $0.state != .unknown }).sample
        let obj = robots.randomElement()!
        let param = obj.id
        XCTContext.runActivity(named: "Dataが未設定の場合") { _ in
            presenter.data.id = nil
            data.robots = robots
            let state = MainViewData.RobotState(.unknown)
            XCTAssertEqual(presenter.stateImageName, state.iconSystemName, "デフォルト値が取得できていない: \(state.iconSystemName)")
        }

        XCTContext.runActivity(named: "Robotsが未設定の場合") { _ in
            presenter.data.id = param
            data.robots = nil
            let state = MainViewData.RobotState(.unknown)
            XCTAssertEqual(presenter.stateImageName, state.iconSystemName, "デフォルト値が取得できていない: \(state.iconSystemName)")
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            presenter.data.id = param
            data.robots = robots
            let state = MainViewData.RobotState(obj.state)
            XCTAssertEqual(presenter.stateImageName, state.iconSystemName, "正しい値が取得できていない: \(obj)")
        }
    }

    func test_stateTintColor() {
        let robots = DataManageModel.Output.Robot.arbitrary.suchThat({ $0.state != .unknown }).sample
        let obj = robots.randomElement()!
        let param = obj.id
        XCTContext.runActivity(named: "Dataが未設定の場合") { _ in
            presenter.data.id = nil
            data.robots = robots
            let state = MainViewData.RobotState(.unknown)
            XCTAssertEqual(presenter.stateTintColor, state.color, "デフォルト値が取得できていない: \(state.color)")
        }

        XCTContext.runActivity(named: "Robotsが未設定の場合") { _ in
            presenter.data.id = param
            data.robots = nil
            let state = MainViewData.RobotState(.unknown)
            XCTAssertEqual(presenter.stateTintColor, state.color, "デフォルト値が取得できていない: \(state.color)")
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            presenter.data.id = param
            data.robots = robots
            let state = MainViewData.RobotState(obj.state)
            XCTAssertEqual(presenter.stateTintColor, state.color, "正しい値が取得できていない: \(obj)")
        }
    }

    func test_typeName() {
        let robots = DataManageModel.Output.Robot.arbitrary.sample
        let obj = robots.randomElement()!
        let param = obj.id
        XCTContext.runActivity(named: "Dataが未設定の場合") { _ in
            presenter.data.id = nil
            data.robots = robots
            XCTAssertNil(presenter.typeName, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Robotsが未設定の場合") { _ in
            presenter.data.id = param
            data.robots = nil
            XCTAssertNil(presenter.typeName, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            presenter.data.id = param
            data.robots = robots
            XCTAssertEqual(presenter.typeName, obj.type, "正しい値が取得できていない: \(obj)")
        }
    }

    func test_serialName() {
        let robots = DataManageModel.Output.Robot.arbitrary.sample
        let obj = robots.randomElement()!
        let param = obj.id
        XCTContext.runActivity(named: "Dataが未設定の場合") { _ in
            presenter.data.id = nil
            data.robots = robots
            XCTAssertNil(presenter.serialName, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Robotsが未設定の場合") { _ in
            presenter.data.id = param
            data.robots = nil
            XCTAssertNil(presenter.serialName, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            presenter.data.id = param
            data.robots = robots
            XCTAssertEqual(presenter.serialName, obj.serial, "正しい値が取得できていない: \(obj)")
        }
    }

    func test_remarks() {
        let robots = DataManageModel.Output.Robot.arbitrary.sample
        let obj = robots.randomElement()!
        let param = obj.id
        XCTContext.runActivity(named: "Dataが未設定の場合") { _ in
            presenter.data.id = nil
            data.robots = robots
            XCTAssertNil(presenter.remarks, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Robotsが未設定の場合") { _ in
            presenter.data.id = param
            data.robots = nil
            XCTAssertNil(presenter.remarks, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            presenter.data.id = param
            data.robots = robots
            XCTAssertEqual(presenter.remarks, obj.remarks, "正しい値が取得できていない: \(obj)")
        }
    }

    func test_tapMoreBarButton() {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.data.id = nil
            presenter.tapMoreBarButton(UIBarButtonItem())
            XCTAssertEqual(vc.showActionSheetCallCount, 0, "ViewControllerのメソッドが呼ばれてしまう")
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            presenter.data.id = param
            presenter.tapMoreBarButton(UIBarButtonItem())
            XCTAssertEqual(vc.showActionSheetCallCount, 1, "ViewControllerのメソッドが呼ばれない")
        }
    }

    func test_image() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        presenter.data.id = param

        data.robotImageHandler = { id in
            return Future<JobOrder_Domain.DataManageModel.Output.RobotImage, Error> { promise in
                promise(.success(.init(data: Data())))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.image {
            XCTAssertEqual($0, Data(), "正しい値が取得できていない")
            completionExpectation.fulfill()
        }

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_imageError() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion error")
        completionExpectation.isInverted = true
        presenter.data.id = param

        data.robotImageHandler = { id in
            return Future<JobOrder_Domain.DataManageModel.Output.RobotImage, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        presenter.image { _ in
            XCTFail("呼ばれてはいけない")
        }

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        // TODO: エラーケース
    }

    func test_imageNoId() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion error")
        handlerExpectation.isInverted = true
        completionExpectation.isInverted = true
        presenter.data.id = nil

        data.robotImageHandler = { id in
            return Future<JobOrder_Domain.DataManageModel.Output.RobotImage, Error> { promise in
                XCTFail("呼ばれてはいけない")
            }.eraseToAnyPublisher()
        }

        presenter.image { _ in
            XCTFail("呼ばれてはいけない")
        }

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        // TODO: エラーケース
    }

    func test_tapOrderEntryButton() {
        presenter.tapOrderEntryButton()
        XCTAssertEqual(vc.launchOrderEntryCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }
}
