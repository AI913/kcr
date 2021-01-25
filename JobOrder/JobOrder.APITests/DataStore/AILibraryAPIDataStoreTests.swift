//
//  AILibraryAPIDataStoreTests.swift
//  JobOrder.APITests
//
//  Created by Yu Suzuki on 2020/07/27.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_API

class AILibraryAPIDataStoreTests: XCTestCase {

    private let ms1000 = 1.0
    private let mock = APIRequestProtocolMock()
    private lazy var dataStore = AILibraryAPIDataStore(api: mock)
    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_fetch() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let aiLibrariesResult: APIResult<[AILibraryAPIEntity.Data]> = APIResult.arbitrary.generate

        mock.getHandler = { url, token, _ in
            return Future<APIResult<[AILibraryAPIEntity.Data]>, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(aiLibrariesResult))
            }.eraseToAnyPublisher()
        }

        fetch(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTAssert(data == aiLibrariesResult, "正しい値が取得できていない: \(data)")

                guard let resultData = aiLibrariesResult.data else {
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
            return Future<APIResult<[AILibraryAPIEntity.Data]>, Error> { promise in
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
            return Future<APIResult<[AILibraryAPIEntity.Data]>, Error> { promise in
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
}

extension AILibraryAPIDataStoreTests {

    private func fetch(_ exps: [XCTestExpectation], onSuccess: @escaping (APIResult<[AILibraryAPIEntity.Data]>) -> Void, onError: @escaping (Error) -> Void) {

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
}
