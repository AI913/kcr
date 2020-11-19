//
//  TaskAPITests.swift
//  JobOrder.APITests
//
//  Created by frontarc on 2020/10/29.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Foundation
import Combine
@testable import JobOrder_API

class TaskAPIDataStoreTests: XCTestCase {
    private let ms1000 = 1.0
    private let mock = APIRequestProtocolMock()
    private lazy var dataStore = TaskAPIDataStore(api: mock)
    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_getCommandFromTask() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mock.getResUrlHandler = { url, token, dataId in
            return Future<APIResult<CommandEntity.Data>, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(APITestsStub().commandFromTaskResult))
            }.eraseToAnyPublisher()
        }

        getCommandFromTask(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTAssert(data == APITestsStub().commandFromTaskResult, "正しい値が取得できていない: \(data)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }

    func test_getCommandFromTaskError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mock.getResUrlHandler = { url, token, dataId in
            return Future<APIResult<CommandEntity.Data>, Error> { promise in
                handlerExpectation.fulfill()
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        getCommandFromTask(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTFail("値を取得できてはいけない: \(data)")
            },
            onError: { error in
                let error = error as NSError
                XCTAssertEqual(error.code, -1, "正しい値が取得できていない: \(error.code)")
                XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (Error error -1.)", "正しい値が取得できていない: \(error.localizedDescription)")
            })
    }

    func test_getCommandFromTaskNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mock.getResUrlHandler = { url, token, dataId in
            return Future<APIResult<CommandEntity.Data>, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        getCommandFromTask(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTFail("値を取得できてはいけない: \(data)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }
}

extension TaskAPIDataStoreTests {
    private func getCommandFromTask(_ exps: [XCTestExpectation], onSuccess: @escaping (APIResult<CommandEntity.Data>) -> Void, onError: @escaping (Error) -> Void) {
        let param = "test"

        dataStore.getCommand(param, taskId: param, robotId: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    onError(error)
                }
                exps.last?.fulfill()
            }, receiveValue: { response in
                onSuccess(response)
            }).store(in: &cancellables)

        wait(for: exps, timeout: ms1000)
    }
}
