//
//  JobAPIDataStoreTests.swift
//  JobOrder.APITests
//
//  Created by Yu Suzuki on 2020/07/27.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_API

class JobAPIDataStoreTests: XCTestCase {

    private let ms1000 = 1.0
    private let mock = APIRequestProtocolMock()
    private lazy var dataStore = JobAPIDataStore(api: mock)
    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_fetch() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mock.getHandler = { url, token, _ in
            return Future<APIResult<[JobAPIEntity.Data]>, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(APITestsStub().jobsResult))
            }.eraseToAnyPublisher()
        }

        fetch(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTAssert(data == APITestsStub().jobsResult, "正しい値が取得できていない: \(data)")

                guard let resultData = APITestsStub().jobsResult.data else {
                    XCTFail("読み込みエラー")
                    return
                }

                data.data?.enumerated().forEach {
                    XCTAssert(resultData[$0.offset] == $0.element, "正しい値が取得できていない: \($0.offset)")
                }
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }

    func test_fetchError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mock.getHandler = { url, token, _ in
            return Future<APIResult<[JobAPIEntity.Data]>, Error> { promise in
                handlerExpectation.fulfill()
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        fetch(
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

    func test_fetchNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mock.getHandler = { url, token, _ in
            return Future<APIResult<[JobAPIEntity.Data]>, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        fetch(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTFail("値を取得できてはいけない: \(data)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }

    func test_getTasks() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        let paging: APIPaging.Input = APIPaging.Input(page: 5, size: 10)

        let expectedQuery: [URLQueryItem] = [
            URLQueryItem(name: "size", value: "10"),
            URLQueryItem(name: "page", value: "5")
        ]

        mock.getResUrlHandler = { url, token, dataId, query in
            return Future<APIResult<[TaskAPIEntity.Data]>, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(APITestsStub().tasksFromJobResult))
                if let query = query {
                    let canonicalizedQuery = self.canonicalized(queryitems: query)
                    let canonicalizedExpected = self.canonicalized(queryitems: expectedQuery)
                    XCTAssertTrue(canonicalizedQuery.elementsEqual(canonicalizedExpected), "正しい値が設定されていない")
                } else {
                    XCTFail("クエリが設定されていない")
                }
            }.eraseToAnyPublisher()
        }

        getTasks(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTAssert(data == APITestsStub().tasksFromJobResult, "正しい値が取得できていない: \(data)")

                guard let resultData = APITestsStub().tasksFromJobResult.data else {
                    XCTFail("読み込みエラー")
                    return
                }

                data.data?.enumerated().forEach {
                    XCTAssert(resultData[$0.offset] == $0.element, "正しい値が取得できていない: \($0.offset)")
                }
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            },
            paging: paging)
    }

    func test_getTasksError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mock.getResUrlHandler = { url, token, dataId, _ in
            return Future<APIResult<[TaskAPIEntity.Data]>, Error> { promise in
                handlerExpectation.fulfill()
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        getTasks(
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

    func test_getTasksNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mock.getResUrlHandler = { url, token, dataId, _ in
            return Future<APIResult<[TaskAPIEntity.Data]>, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        getTasks(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTFail("値を取得できてはいけない: \(data)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }
}

extension JobAPIDataStoreTests {

    private func fetch(_ exps: [XCTestExpectation], onSuccess: @escaping (APIResult<[JobAPIEntity.Data]>) -> Void, onError: @escaping (Error) -> Void) {

        dataStore.fetch("test")
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

    private func getTasks(_ exps: [XCTestExpectation], onSuccess: @escaping (APIResult<[TaskAPIEntity.Data]>) -> Void, onError: @escaping (Error) -> Void, paging: APIPaging.Input? = nil) {
        let param = "test"

        dataStore.getTasks(param, id: param, paging: paging)
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
