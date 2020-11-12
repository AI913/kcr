//
//  RobotDataStoreTests.swift
//  JobOrder.DataTests
//
//  Created by Yu Suzuki on 2020/07/21.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Data

class RobotDataStoreTests: XCTestCase {

    private let ms1000 = 1.0
    private let ud = UserDefaultsRepositoryMock()
    private let realm = RealmDataStoreProtocolMock()
    private lazy var dataStore = RobotDataStore(ud: ud, realm: realm)
    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_getTimestamp() {
        let param = 1

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertEqual(dataStore.timestamp, 0, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            ud.integerHandler = { key in
                return param
            }
            XCTAssertEqual(dataStore.timestamp, param, "正しい値が取得できていない: \(param)")
        }
    }

    func test_setTimestamp() {
        let param = 1

        XCTContext.runActivity(named: "\(param)を設定した場合") { _ in
            dataStore.timestamp = param
            XCTAssertEqual(ud.setCallCount, 1, "UserDefaultsRepositoryのメソッドが呼ばれない")
        }
    }

    func test_add() {

        XCTContext.runActivity(named: "Robotを設定した場合") { _ in
            dataStore.add(entities: DataTestsStub().robots)
            XCTAssertEqual(realm.addCallCount, 1, "RealmRepositoryのメソッドが呼ばれない")
        }
    }

    func test_read() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(dataStore.read(), "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Robot設定済みの場合") { _ in
            realm.readHandler = { type in
                return DataTestsStub().robots
            }

            guard let output = dataStore.read() else {
                XCTFail("読み込みエラー")
                return
            }

            DataTestsStub().robots.enumerated().forEach {
                XCTAssert(output[$0.offset] === $0.element, "Robotが設定されていない: \($0.element)")
            }
        }
    }

    func test_update() {
        let param = "test"
        XCTContext.runActivity(named: "Robotが設定済みの場合") { _ in
            dataStore.update(state: param, entity: DataTestsStub().robot1)
            XCTAssertEqual(realm.updateCallCount, 1, "RealmDataStoreのメソッドが呼ばれない")
        }
    }

    func test_delete() {

        XCTContext.runActivity(named: "Robot設定済みの場合") { _ in
            dataStore.delete(entity: DataTestsStub().robot1)
            XCTAssertEqual(realm.deleteCallCount, 1, "RealmDataStoreのメソッドが呼ばれない")
        }
    }

    func test_deleteAll() {

        XCTContext.runActivity(named: "Robot設定済みの場合") { _ in
            dataStore.deleteAll()
            XCTAssertEqual(ud.setCallCount, 1, "UserDefaultsRepositoryのメソッドが呼ばれない")
            XCTAssertEqual(realm.deleteAllCallCount, 1, "RealmDataStoreのメソッドが呼ばれない")
        }
    }

    func test_observe() {

        XCTContext.runActivity(named: "通知が来た場合") { _ in
            let completionExpectation = expectation(description: "completion")

            dataStore.observe()
                .sink { response in
                    response?.enumerated().forEach {
                        XCTAssert(DataTestsStub().robots[$0.offset] === $0.element, "Robotが設定されていない: \($0.element)")
                    }
                    completionExpectation.fulfill()
                }.store(in: &cancellables)

            dataStore.publisher.send(DataTestsStub().robots)
            wait(for: [completionExpectation], timeout: ms1000)
        }

        XCTContext.runActivity(named: "通知が来ない場合") { _ in
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            dataStore.observe()
                .sink { response in
                    completionExpectation.fulfill()
                }.store(in: &cancellables)

            wait(for: [completionExpectation], timeout: ms1000)
        }
    }
}
