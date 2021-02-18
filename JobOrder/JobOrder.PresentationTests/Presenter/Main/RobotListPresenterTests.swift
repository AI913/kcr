//
//  RobotListPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class RobotListPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let vc = RobotListViewControllerProtocolMock()
    private let settings = JobOrder_Domain.SettingsUseCaseProtocolMock()
    private let mqtt = JobOrder_Domain.MQTTUseCaseProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private lazy var presenter = RobotListPresenter(settingsUseCase: settings,
                                                    mqttUseCase: mqtt,
                                                    dataUseCase: data,
                                                    vc: vc)
    override func setUpWithError() throws {
        mqtt.registerConnectionStatusChangeHandler = {
            return Future<JobOrder_Domain.MQTTModel.Output.ConnectionStatus, Never> { promise in }.eraseToAnyPublisher()
        }
        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in }.eraseToAnyPublisher()
        }
    }

    override func tearDownWithError() throws {}

    func test_numberOfRowsInSection() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertEqual(presenter.numberOfRowsInSection, 0, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true
            let robots = DataManageModel.Output.Robot.arbitrary.sample

            data.observeRobotDataHandler = {
                return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                    promise(.success(robots))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            // 初期化時に登録
            presenter = RobotListPresenter(settingsUseCase: settings,
                                           mqttUseCase: mqtt,
                                           dataUseCase: data,
                                           vc: vc)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            XCTAssertEqual(presenter.numberOfRowsInSection, robots.count, "正しい値が取得できていない")
        }
    }

    func test_id() {
        let robots = DataManageModel.Output.Robot.arbitrary.sample
        XCTContext.runActivity(named: "未設定の場合") { _ in
            robots.enumerated().forEach {
                XCTAssertNil(presenter.id($0.offset), "値を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            data.observeRobotDataHandler = {
                return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                    promise(.success(robots))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            // 初期化時に登録
            presenter = RobotListPresenter(settingsUseCase: settings,
                                           mqttUseCase: mqtt,
                                           dataUseCase: data,
                                           vc: vc)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            robots.enumerated().forEach {
                let id = presenter.id($0.offset)
                XCTAssertTrue(robots.contains { $0.id == id }, "正しい値が取得できていない: \($0.offset)")
            }
        }
    }

    func test_displayName() {
        let robots = DataManageModel.Output.Robot.arbitrary.sample
        XCTContext.runActivity(named: "未設定の場合") { _ in
            robots.enumerated().forEach {
                XCTAssertNil(presenter.displayName($0.offset), "値を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            data.observeRobotDataHandler = {
                return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                    promise(.success(robots))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            // 初期化時に登録
            presenter = RobotListPresenter(settingsUseCase: settings,
                                           mqttUseCase: mqtt,
                                           dataUseCase: data,
                                           vc: vc)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            robots.enumerated().forEach {
                let name = presenter.displayName($0.offset)
                XCTAssertTrue(robots.contains { $0.name == name }, "正しい値が取得できていない: \($0.offset)")
            }
        }
    }

    func test_stateName() {
        let robots = DataManageModel.Output.Robot.arbitrary.sample
        XCTContext.runActivity(named: "未設定の場合") { _ in
            robots.enumerated().forEach {
                let state = MainViewData.RobotState(.unknown)
                XCTAssertEqual(presenter.stateName($0.offset), state.displayName, "Unknown以外を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            data.observeRobotDataHandler = {
                return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                    promise(.success(robots))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            // 初期化時に登録
            presenter = RobotListPresenter(settingsUseCase: settings,
                                           mqttUseCase: mqtt,
                                           dataUseCase: data,
                                           vc: vc)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            robots.enumerated().forEach {
                let name = presenter.stateName($0.offset)
                XCTAssertTrue(robots.contains { MainViewData.RobotState($0.state).displayName == name }, "正しい値が取得できていない: \($0.offset)")
            }
        }
    }

    func test_stateImageName() {
        let robots = DataManageModel.Output.Robot.arbitrary.sample
        XCTContext.runActivity(named: "未設定の場合") { _ in
            robots.enumerated().forEach {
                let state = MainViewData.RobotState(.unknown)
                XCTAssertEqual(presenter.stateImageName($0.offset), state.iconSystemName, "Unknown以外を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            data.observeRobotDataHandler = {
                return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                    promise(.success(robots))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            // 初期化時に登録
            presenter = RobotListPresenter(settingsUseCase: settings,
                                           mqttUseCase: mqtt,
                                           dataUseCase: data,
                                           vc: vc)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            robots.enumerated().forEach {
                let name = presenter.stateImageName($0.offset)
                XCTAssertTrue(robots.contains { MainViewData.RobotState($0.state).iconSystemName == name }, "正しい値が取得できていない: \($0.offset)")
            }
        }
    }

    func test_stateTintColor() {
        let robots = DataManageModel.Output.Robot.arbitrary.sample
        XCTContext.runActivity(named: "未設定の場合") { _ in
            robots.enumerated().forEach {
                let state = MainViewData.RobotState(.unknown)
                XCTAssertEqual(presenter.stateTintColor($0.offset), state.color, "Unknown以外を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            data.observeRobotDataHandler = {
                return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                    promise(.success(robots))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            // 初期化時に登録
            presenter = RobotListPresenter(settingsUseCase: settings,
                                           mqttUseCase: mqtt,
                                           dataUseCase: data,
                                           vc: vc)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            robots.enumerated().forEach {
                let color = presenter.stateTintColor($0.offset)
                XCTAssertTrue(robots.contains { MainViewData.RobotState($0.state).color == color }, "正しい値が取得できていない: \($0.offset)")
            }
        }
    }

    func test_typeName() {
        let robots = DataManageModel.Output.Robot.arbitrary.sample
        XCTContext.runActivity(named: "未設定の場合") { _ in
            robots.enumerated().forEach {
                XCTAssertNil(presenter.typeName($0.offset), "値を取得できてはいけない")
            }
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            data.observeRobotDataHandler = {
                return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                    promise(.success(robots))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            // 初期化時に登録
            presenter = RobotListPresenter(settingsUseCase: settings,
                                           mqttUseCase: mqtt,
                                           dataUseCase: data,
                                           vc: vc)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            robots.enumerated().forEach {
                let type = presenter.typeName($0.offset)
                XCTAssertTrue(robots.contains { $0.type == type }, "正しい値が取得できていない: \($0.offset)")
            }
        }
    }

    func test_selectRow() {
        presenter.selectRow(index: 0)
        XCTAssertEqual(vc.transitionToRobotDetailCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_filterAndSort() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertEqual(vc.reloadTableCallCount, 0, "ViewControllerのメソッドが呼ばれてしまう")
        }

        XCTContext.runActivity(named: "Robotが存在する場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            data.observeRobotDataHandler = {
                return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                    promise(.success(DataManageModel.Output.Robot.arbitrary.sample))
                    handlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            // 初期化時に登録
            presenter = RobotListPresenter(settingsUseCase: settings,
                                           mqttUseCase: mqtt,
                                           dataUseCase: data,
                                           vc: vc)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
            XCTAssertEqual(vc.reloadTableCallCount, 1, "ViewControllerのメソッドが呼ばれない")
        }
    }

    func test_observeRobotsNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        data.robots = DataManageModel.Output.Robot.arbitrary.sample

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = RobotListPresenter(settingsUseCase: settings,
                                       mqttUseCase: mqtt,
                                       dataUseCase: data,
                                       vc: vc)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.reloadTableCallCount, 0, "ViewControllerのメソッドが呼ばれてしまう")
    }

    func test_observeRobotsReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        data.robots = DataManageModel.Output.Robot.arbitrary.sample

        data.observeRobotDataHandler = {
            return Future<[JobOrder_Domain.DataManageModel.Output.Robot]?, Never> { promise in
                promise(.success(DataManageModel.Output.Robot.arbitrary.sample))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        // 初期化時に登録
        presenter = RobotListPresenter(settingsUseCase: settings,
                                       mqttUseCase: mqtt,
                                       dataUseCase: data,
                                       vc: vc)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertEqual(vc.reloadTableCallCount, 1, "ViewControllerのメソッドが呼ばれない")
    }

    func test_filterAndSortParameter() {

        XCTContext.runActivity(named: "nameが全て違う場合") { _ in
            let robot1 = DataManageModel.Output.Robot.pattern(id: "2", name: "c").generate
            let robot2 = DataManageModel.Output.Robot.pattern(id: "3", name: "b").generate
            let robot3 = DataManageModel.Output.Robot.pattern(id: "1", name: "a").generate

            presenter.filterAndSort(robots: [robot1, robot2, robot3], keywordChanged: false)
            XCTAssertEqual(presenter.displayRobots?[0].id, "1", "name順にソートされていない")
            XCTAssertEqual(presenter.displayRobots?[1].id, "3", "name順にソートされていない")
            XCTAssertEqual(presenter.displayRobots?[2].id, "2", "name順にソートされていない")
        }

        XCTContext.runActivity(named: "nameが全て同じ場合") { _ in
            let robot1 = DataManageModel.Output.Robot.pattern(id: "2", name: "a").generate
            let robot2 = DataManageModel.Output.Robot.pattern(id: "3", name: "a").generate
            let robot3 = DataManageModel.Output.Robot.pattern(id: "1", name: "a").generate

            presenter.filterAndSort(robots: [robot1, robot2, robot3], keywordChanged: false)
            XCTAssertEqual(presenter.displayRobots?[0].id, "1", "id順にソートされていない")
            XCTAssertEqual(presenter.displayRobots?[1].id, "2", "id順にソートされていない")
            XCTAssertEqual(presenter.displayRobots?[2].id, "3", "id順にソートされていない")
        }

        XCTContext.runActivity(named: "nameが一部同じ場合") { _ in
            let robot1 = DataManageModel.Output.Robot.pattern(id: "2", name: "b").generate
            let robot2 = DataManageModel.Output.Robot.pattern(id: "3", name: "a").generate
            let robot3 = DataManageModel.Output.Robot.pattern(id: "1", name: "a").generate

            presenter.filterAndSort(robots: [robot1, robot2, robot3], keywordChanged: false)
            XCTAssertEqual(presenter.displayRobots?[0].id, "1", "name順にソートされ、同じ場合はid順にソートされていない")
            XCTAssertEqual(presenter.displayRobots?[1].id, "3", "name順にソートされ、同じ場合はid順にソートされていない")
            XCTAssertEqual(presenter.displayRobots?[2].id, "2", "name順にソートされ、同じ場合はid順にソートされていない")
        }
    }
}
