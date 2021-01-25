//
//  JobDataStoreTests.swift
//  JobOrder.DataTests
//
//  Created by Yu Suzuki on 2020/07/21.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Data

class JobDataStoreTests: XCTestCase {

    private let ms1000 = 1.0
    private let ud = UserDefaultsRepositoryMock()
    private let realm = RealmDataStoreProtocolMock()
    private lazy var dataStore = JobDataStore(ud: ud, realm: realm)
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

        XCTContext.runActivity(named: "Jobを設定した場合") { _ in
            dataStore.add(entities: JobEntity.arbitrary.sample)
            XCTAssertEqual(realm.addCallCount, 1, "RealmDataStoreのメソッドが呼ばれない")
        }
    }

    func test_read() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(dataStore.read(), "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Job設定済みの場合") { _ in
            let jobs = JobEntity.arbitrary.sample

            realm.readHandler = { type in
                return jobs
            }

            guard let output = dataStore.read() else {
                XCTFail("読み込みエラー")
                return
            }

            jobs.enumerated().forEach {
                XCTAssert(output[$0.offset] === $0.element, "Jobが設定されていない: \($0.element)")
            }
        }
    }

    func test_delete() {

        XCTContext.runActivity(named: "Job設定済みの場合") { _ in
            dataStore.delete(entity: JobEntity.arbitrary.generate)
            XCTAssertEqual(realm.deleteCallCount, 1, "RealmDataStoreのメソッドが呼ばれない")
        }
    }

    func test_deleteAll() {

        XCTContext.runActivity(named: "Job設定済みの場合") { _ in
            dataStore.deleteAll()
            XCTAssertEqual(ud.setCallCount, 1, "UserDefaultsRepositoryのメソッドが呼ばれない")
            XCTAssertEqual(realm.deleteAllCallCount, 1, "RealmDataStoreのメソッドが呼ばれない")
        }
    }

    func test_observe() {

        XCTContext.runActivity(named: "通知が来た場合") { _ in
            let completionExpectation = expectation(description: "completion")
            let jobs = JobEntity.arbitrary.sample

            dataStore.observe()
                .sink { response in
                    response?.enumerated().forEach {
                        XCTAssert(jobs[$0.offset] === $0.element, "Jobが設定されていない: \($0.element)")
                    }
                    completionExpectation.fulfill()
                }.store(in: &cancellables)

            dataStore.publisher.send(jobs)
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
