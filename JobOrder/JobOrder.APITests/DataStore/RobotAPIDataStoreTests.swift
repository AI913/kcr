//
//  RobotAPIDataStoreTests.swift
//  JobOrder.APITests
//
//  Created by Yu Suzuki on 2020/07/27.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_API

class RobotAPIDataStoreTests: XCTestCase {

    private let ms1000 = 1.0
    private let mock = APIRequestProtocolMock()
    private lazy var dataStore = RobotAPIDataStore(api: mock)
    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_fetch() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let robotsResult: APIResult<[RobotAPIEntity.Data]> = APIResult.arbitrary.generate

        mock.getHandler = { url, token, _ in
            return Future<APIResult<[RobotAPIEntity.Data]>, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(robotsResult))
            }.eraseToAnyPublisher()
        }

        fetch(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTAssert(data == robotsResult, "正しい値が取得できていない: \(data)")

                guard let resultData = robotsResult.data else {
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
            return Future<APIResult<[RobotAPIEntity.Data]>, Error> { promise in
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
            return Future<APIResult<[RobotAPIEntity.Data]>, Error> { promise in
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

    func test_getRobot() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let robotResult: APIResult<RobotAPIEntity.Data> = APIResult.arbitrary.generate

        mock.getResUrlHandler = { url, token, dataId, _ in
            return Future<APIResult<RobotAPIEntity.Data>, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(robotResult))
            }.eraseToAnyPublisher()
        }

        getRobot(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTAssert(data == robotResult, "正しい値が取得できていない: \(data)")

                guard let data = data.data, let resultData = robotResult.data else {
                    XCTFail("読み込みエラー")
                    return
                }

                XCTAssert(data == resultData, "正しい値が取得できていない: \(data)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }

    func test_getRobotError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mock.getResUrlHandler = { url, token, dataId, _ in
            return Future<APIResult<RobotAPIEntity.Data>, Error> { promise in
                handlerExpectation.fulfill()
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        getRobot(
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

    func test_getRobotNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mock.getResUrlHandler = { url, token, dataId, _ in
            return Future<APIResult<RobotAPIEntity.Data>, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        getRobot(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTFail("値を取得できてはいけない: \(data)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }

    func test_getCommand() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let commandsFromRobotResult: APIResult<[CommandEntity.Data]> = APIResult.arbitrary.generate

        let status: [String] = ["Unissued", "Queued", "Processing", "Suspended"]
        let paging: APIPaging.Input = APIPaging.Input(page: 5, size: 10)

        let expectedQuery: [URLQueryItem] = [
            URLQueryItem(name: "status", value: "Processing"),
            URLQueryItem(name: "status", value: "Suspended"),
            URLQueryItem(name: "status", value: "Unissued"),
            URLQueryItem(name: "status", value: "Queued"),
            URLQueryItem(name: "size", value: "10"),
            URLQueryItem(name: "page", value: "5")
        ]

        mock.getResUrlHandler = { url, token, dataId, query in
            return Future<APIResult<[CommandEntity.Data]>, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(commandsFromRobotResult))
                if let query = query {
                    let canonicalizedQuery = self.canonicalized(queryitems: query)
                    let canonicalizedExpected = self.canonicalized(queryitems: expectedQuery)
                    XCTAssertTrue(canonicalizedQuery.elementsEqual(canonicalizedExpected), "正しい値が設定されていない")
                } else {
                    XCTFail("クエリが設定されていない")
                }
            }.eraseToAnyPublisher()
        }
        getCommand(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTAssert(data == commandsFromRobotResult, "正しい値が取得できていない: \(data)")

                guard let resultData = commandsFromRobotResult.data else {
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
            status: status,
            paging: paging)

    }

    func test_getCommandError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mock.getResUrlHandler = { url, token, dataId, _ in
            return Future<APIResult<[CommandEntity.Data]>, Error> { promise in
                handlerExpectation.fulfill()
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        getCommand(
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

    func test_getCommandNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mock.getResUrlHandler = { url, token, dataId, _ in
            return Future<APIResult<[CommandEntity.Data]>, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        getCommand(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTFail("値を取得できてはいけない: \(data)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }

    func test_getImage() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mock.getImageHandler = { url, token, dataId in
            return Future<Data, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(Data()))
            }.eraseToAnyPublisher()
        }

        getImage(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTAssert(data == Data(), "正しい値が取得できていない: \(data)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }

    func test_getImageError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mock.getImageHandler = { url, token, dataId in
            return Future<Data, Error> { promise in
                handlerExpectation.fulfill()
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        getImage(
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

    func test_getImageNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mock.getImageHandler = { url, token, dataId in
            return Future<Data, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        getImage(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTFail("値を取得できてはいけない: \(data)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }

    func test_getSwconf() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let swconfResult: APIResult<RobotAPIEntity.Swconf> = APIResult.arbitrary.generate

        mock.getResUrlHandler = { url, token, dataId, _ in
            return Future<APIResult<RobotAPIEntity.Swconf>, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(swconfResult))
            }.eraseToAnyPublisher()
        }
        getSwconf(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTAssert(data == swconfResult, "正しい値が取得できていない: \(data)")

                guard let expected = swconfResult.data, let actual = data.data else {
                    XCTFail("読み込みエラー")
                    return
                }

                XCTAssertEqual(actual, expected, "正しい値が取得できていない: \(actual)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }

    func test_getSwconfError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mock.getResUrlHandler = { url, token, dataId, _ in
            return Future<APIResult<RobotAPIEntity.Swconf>, Error> { promise in
                handlerExpectation.fulfill()
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        getSwconf(
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

    func test_getSwconfNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mock.getResUrlHandler = { url, token, dataId, _ in
            return Future<APIResult<RobotAPIEntity.Swconf>, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        getSwconf(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTFail("値を取得できてはいけない: \(data)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }

    func test_getAssets() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let assetsResult: APIResult<[RobotAPIEntity.Asset]> = APIResult.arbitrary.generate

        mock.getResUrlHandler = { url, token, dataId, _ in
            return Future<APIResult<[RobotAPIEntity.Asset]>, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(assetsResult))
            }.eraseToAnyPublisher()
        }
        getAssets(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTAssert(data == assetsResult, "正しい値が取得できていない: \(data)")

                guard let expected = assetsResult.data, let actual = data.data else {
                    XCTFail("読み込みエラー")
                    return
                }

                XCTAssertTrue(actual.elementsEqual(expected), "正しい値が取得できていない: \(actual)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }

    func test_getAssetsError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mock.getResUrlHandler = { url, token, dataId, _ in
            return Future<APIResult<[RobotAPIEntity.Asset]>, Error> { promise in
                handlerExpectation.fulfill()
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        getAssets(
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

    func test_getAssetsNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mock.getResUrlHandler = { url, token, dataId, _ in
            return Future<APIResult<[RobotAPIEntity.Asset]>, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        getAssets(
            [handlerExpectation, completionExpectation],
            onSuccess: { data in
                XCTFail("値を取得できてはいけない: \(data)")
            },
            onError: { error in
                XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
            })
    }
}

extension RobotAPIDataStoreTests {

    private func fetch(_ exps: [XCTestExpectation], onSuccess: @escaping (APIResult<[RobotAPIEntity.Data]>) -> Void, onError: @escaping (Error) -> Void) {

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

    private func getRobot(_ exps: [XCTestExpectation], onSuccess: @escaping (APIResult<RobotAPIEntity.Data>) -> Void, onError: @escaping (Error) -> Void) {
        let param = "test"

        dataStore.getRobot(param, id: param)
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

    private func getImage(_ exps: [XCTestExpectation], onSuccess: @escaping (Data) -> Void, onError: @escaping (Error) -> Void) {
        let param = "test"

        dataStore.getImage(param, id: param)
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

    private func getCommand(_ exps: [XCTestExpectation], onSuccess: @escaping (APIResult<[CommandEntity.Data]>) -> Void, onError: @escaping (Error) -> Void, status: [String]? = nil, paging: APIPaging.Input? = nil) {
        let param = "test"
        dataStore.getCommands(param, id: param, status: status, paging: paging)
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

    private func getSwconf(_ exps: [XCTestExpectation], onSuccess: @escaping (APIResult<RobotAPIEntity.Swconf>) -> Void, onError: @escaping (Error) -> Void) {
        let param = "test"

        dataStore.getRobotSwconf(param, id: param)
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

    private func getAssets(_ exps: [XCTestExpectation], onSuccess: @escaping (APIResult<[RobotAPIEntity.Asset]>) -> Void, onError: @escaping (Error) -> Void) {
        let param = "test"

        dataStore.getRobotAssets(param, id: param)
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
