//
//  RealmDataStoreTests.swift
//  JobOrder.DataTests
//
//  Created by Yu Suzuki on 2020/07/22.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import RealmSwift
@testable import JobOrder_Data

class RealmDataStoreTests: TestCaseBase {

    private let ms1000 = 1.0
    private let dataStore = RealmDataStore()

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_add() {

        XCTContext.runActivity(named: "Robotを設定した場合") { _ in
            dataStore.add(entities: DataTestsStub().robots)

            let realm = try! Realm()
            let entities: [RobotEntity]? = realm.objects(RobotEntity.self).map({ $0 })

            entities?.enumerated().forEach {
                XCTAssert(DataTestsStub().robots[$0.offset] == $0.element, "Robotが設定されていない: \($0.element)")
            }
        }
    }

    func test_read() throws {

        try XCTContext.runActivity(named: "未設定の場合") { _ in
            let entities = try XCTUnwrap(dataStore.read(type: RobotEntity.self), "Unwrap失敗")
            XCTAssertTrue(entities.isEmpty, "空の配列が設定されていない")
        }

        XCTContext.runActivity(named: "Robotが設定済みの場合") { _ in
            let realm = try! Realm()
            try! realm.write {
                realm.add(DataTestsStub().robots, update: .modified)
            }

            let entities = dataStore.read(type: RobotEntity.self)
            entities?.enumerated().forEach {
                XCTAssert(DataTestsStub().robots[$0.offset] == $0.element, "Robotが設定されていない: \($0.element)")
            }
        }
    }

    func test_update() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            dataStore.update(type: RobotEntity.self, key: DataTestsStub().robot1.id) { _ in }
            wait(for: [completionExpectation], timeout: ms1000)
        }

        XCTContext.runActivity(named: "Robotが設定済みの場合") { _ in
            let completionExpectation = expectation(description: "completion")

            let realm = try! Realm()
            try! realm.write {
                realm.add(DataTestsStub().robots, update: .modified)
            }

            dataStore.update(type: RobotEntity.self, key: DataTestsStub().robot1.id) {
                XCTAssert($0 == DataTestsStub().robot1, "Robotが設定されていない: \($0)")
                completionExpectation.fulfill()
            }
            wait(for: [completionExpectation], timeout: ms1000)
        }
    }

    func test_delete() throws {
        let param = "test"

        try XCTContext.runActivity(named: "未設定の場合") { _ in
            dataStore.delete(type: RobotEntity.self, key: DataTestsStub().robot1.id)

            let realm = try! Realm()
            let entities = try XCTUnwrap(realm.objects(RobotEntity.self).map({ $0 }), "Unwrap失敗")
            XCTAssertTrue(entities.isEmpty, "空の配列が設定されていない")
        }

        XCTContext.runActivity(named: "存在しないRobotを指定した場合") { _ in
            var realm = try! Realm()
            try! realm.write {
                realm.add(DataTestsStub().robots, update: .modified)
            }

            dataStore.delete(type: RobotEntity.self, key: param)

            realm = try! Realm()
            let entities: [RobotEntity]? = realm.objects(RobotEntity.self).map({ $0 })
            entities?.enumerated().forEach {
                XCTAssert(DataTestsStub().robots[$0.offset] == $0.element, "Robotが設定されていない: \($0.element)")
            }
        }

        try XCTContext.runActivity(named: "設定済みのRobotを指定した場合") { _ in
            var realm = try! Realm()
            try! realm.write {
                realm.add(DataTestsStub().robots, update: .modified)
            }

            dataStore.delete(type: RobotEntity.self, key: DataTestsStub().robot1.id)

            realm = try! Realm()
            let entities = try XCTUnwrap(realm.objects(RobotEntity.self).map({ $0 }), "Unwrap失敗")
            XCTAssertFalse(entities.contains(DataTestsStub().robot1), "削除したデータが含まれてはいけない")
        }
    }

    func test_deleteAll() throws {

        try XCTContext.runActivity(named: "未設定の場合") { _ in
            dataStore.deleteAll(type: RobotEntity.self)

            let realm = try! Realm()
            let entities = try XCTUnwrap(realm.objects(RobotEntity.self).map({ $0 }), "Unwrap失敗")
            XCTAssertTrue(entities.isEmpty, "空の配列が設定されていない")
        }

        try XCTContext.runActivity(named: "設定済みの場合") { _ in
            var realm = try! Realm()
            try! realm.write {
                realm.add(DataTestsStub().robots, update: .modified)
            }

            dataStore.deleteAll(type: RobotEntity.self)

            realm = try! Realm()
            let entities = try XCTUnwrap(realm.objects(RobotEntity.self).map({ $0 }), "Unwrap失敗")
            XCTAssertFalse(entities.contains(DataTestsStub().robot1), "削除したデータが含まれてはいけない")
        }
    }

    func test_observe() {

        XCTContext.runActivity(named: "データに変化がない場合") { _ in
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            dataStore.observe(type: RobotEntity.self) { _ in
                completionExpectation.fulfill()
            }
            wait(for: [completionExpectation], timeout: ms1000)
        }

        XCTContext.runActivity(named: "データに変化があった場合") { _ in
            let completionExpectation = expectation(description: "completion")
            let realm = try! Realm()

            dataStore.observe(type: RobotEntity.self) { _ in
                let entities: [RobotEntity]? = realm.objects(RobotEntity.self).map({ $0 })
                entities?.enumerated().forEach {
                    XCTAssert(DataTestsStub().robots[$0.offset] == $0.element, "Robotが設定されていない: \($0.element)")
                }
                completionExpectation.fulfill()
            }

            try! realm.write {
                realm.add(DataTestsStub().robots, update: .modified)
            }

            wait(for: [completionExpectation], timeout: ms1000)
        }
    }
}

// A base class which each of your Realm-using tests should inherit from rather
// than directly from XCTestCase
class TestCaseBase: XCTestCase {
    override func setUp() {
        super.setUp()
        // テストケース名で区別して、テストごとにIn-memoryなRealmを使うようにします。
        // こうすることで、テストによってアプリケーションのデータを変更してしまうことと、
        // 他のテストに影響が及ぶことを防ぎます。
        // そして、In-memoryなRealmを使うので
        // 後始末として、データを削除する必要はありません。
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }
}
