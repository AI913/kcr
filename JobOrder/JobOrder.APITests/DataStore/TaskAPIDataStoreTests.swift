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
        let commandFromTaskResult: APIResult<CommandEntity.Data> = APIResult.arbitrary.generate

        mock.getResUrlHandler = { url, token, dataId, _ in
            return Future<APIResult<CommandEntity.Data>, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(commandFromTaskResult))
            }.eraseToAnyPublisher()
        }

        getCommandFromTask(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTAssert(data == commandFromTaskResult, "正しい値が取得できていない: \(data)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }

    func test_getCommandFromTaskError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mock.getResUrlHandler = { url, token, dataId, _ in
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

        mock.getResUrlHandler = { url, token, dataId, _ in
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

    func test_getCommandsFromTask() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let commandsFromTaskResult: APIResult<[CommandEntity.Data]> = APIResult.arbitrary.generate

        mock.getResUrlHandler = { url, token, dataId, _ in
            return Future<APIResult<[CommandEntity.Data]>, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(commandsFromTaskResult))
            }.eraseToAnyPublisher()
        }

        getCommandsFromTask(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTAssert(data == commandsFromTaskResult, "正しい値が取得できていない: \(data)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }

    func test_getCommandsFromTaskError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mock.getResUrlHandler = { url, token, dataId, _ in
            return Future<APIResult<[CommandEntity.Data]>, Error> { promise in
                handlerExpectation.fulfill()
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        getCommandsFromTask(
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

    func test_getCommandsFromTaskNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mock.getResUrlHandler = { url, token, dataId, _ in
            return Future<APIResult<[CommandEntity.Data]>, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        getCommandsFromTask(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTFail("値を取得できてはいけない: \(data)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }

    func test_getExecutionsFromTask() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let executionsFromTaskResult: APIResult<[ExecutionEntity.LogData]> = APIResult.arbitrary.generate

        let paging: APIPaging.Input = APIPaging.Input(page: 5, size: 10)

        let expectedQuery: [URLQueryItem] = [
            URLQueryItem(name: "size", value: "10"),
            URLQueryItem(name: "page", value: "5")
        ]

        mock.getResUrlHandler = { url, token, dataId, query in
            return Future<APIResult<[ExecutionEntity.LogData]>, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(executionsFromTaskResult))
                if let query = query {
                    let canonicalizedQuery = self.canonicalized(queryitems: query)
                    let canonicalizedExpected = self.canonicalized(queryitems: expectedQuery)
                    XCTAssertTrue(canonicalizedQuery.elementsEqual(canonicalizedExpected), "正しい値が設定されていない")
                } else {
                    XCTFail("クエリが設定されていない")
                }
            }.eraseToAnyPublisher()
        }

        getExecutionLogsFromTask(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTAssert(data == executionsFromTaskResult, "正しい値が取得できていない: \(data)")
                guard let expectedData = executionsFromTaskResult.data, let actualData = data.data else {
                    XCTFail("読み込みエラー")
                    return
                }
                guard let expectedPaging = executionsFromTaskResult.paging, let actualPaging = data.paging else {
                    XCTFail("読み込みエラー")
                    return
                }
                XCTAssert(actualData.elementsEqual(expectedData), "正しい値が取得できていない: \(actualData)")
                XCTAssertEqual(actualPaging, expectedPaging, "正しい値が取得できていない: \(actualPaging)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            },
            paging: paging)
    }

    func test_getExecutionsFromTaskError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mock.getResUrlHandler = { url, token, dataId, query in
            return Future<APIResult<[ExecutionEntity.LogData]>, Error> { promise in
                handlerExpectation.fulfill()
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        getExecutionLogsFromTask(
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

    func test_getExecutionsFromTaskNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mock.getResUrlHandler = { url, token, dataId, query in
            return Future<APIResult<[ExecutionEntity.LogData]>, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        getExecutionLogsFromTask(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTFail("値を取得できてはいけない: \(data)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }

    func test_postTask() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let postTaskResult: APIResult<TaskAPIEntity.Data> = APIResult.arbitrary.generate

        mock.postHandler = { url, token, _ in
            return Future<APIResult<TaskAPIEntity.Data>, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(postTaskResult))
            }.eraseToAnyPublisher()
        }

        postTask(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTAssert(data == postTaskResult, "正しい値が取得できていない: \(data)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }

    func test_postTaskError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mock.postHandler = { url, token, _ in
            return Future<APIResult<TaskAPIEntity.Data>, Error> { promise in
                handlerExpectation.fulfill()
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        postTask(
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

    func test_postTaskNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mock.postHandler = { url, token, _ in
            return Future<APIResult<TaskAPIEntity.Data>, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        postTask(
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

    private func getCommandsFromTask(_ exps: [XCTestExpectation], onSuccess: @escaping (APIResult<[CommandEntity.Data]>) -> Void, onError: @escaping (Error) -> Void) {
        let param = "test"

        dataStore.getCommands(param, taskId: param)
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

    private func getExecutionLogsFromTask(_ exps: [XCTestExpectation], onSuccess: @escaping (APIResult<[ExecutionEntity.LogData]>) -> Void, onError: @escaping (Error) -> Void, paging: APIPaging.Input? = nil) {
        let param = "test"

        dataStore.getExecutionLogs(param, taskId: param, robotId: param, paging: paging)
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

    private func postTask(_ exps: [XCTestExpectation], onSuccess: @escaping (APIResult<TaskAPIEntity.Data>) -> Void, onError: @escaping (Error) -> Void) {
        let param = "test"

        dataStore.postTask(param, task: TaskAPIEntity.Input.Data())
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

    private func canonicalized(queryitems: [URLQueryItem]) -> [URLQueryItem] {
        let sortRule = { (lhs: URLQueryItem, rhs: URLQueryItem) -> Bool in
            if lhs.name == rhs.name {
                switch (lhs.value, rhs.value) {
                case let (lhs?, rhs?): return lhs < rhs
                case (_, nil): return true
                case (nil, _): return false
                }
            } else {
                return lhs.name < rhs.name
            }
        }
        return queryitems.sorted(by: sortRule)
    }
}
