//
//  MQTTUseCaseTests.swift
//  JobOrder.DomainTests
//
//  Created by Yu Suzuki on 2020/08/08.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Domain
@testable import JobOrder_API
@testable import JobOrder_Data

class MQTTUseCaseTests: XCTestCase {

    private let ms1000 = 1.0
    private let auth = JobOrder_API.AuthenticationRepositoryMock()
    private let mqtt = JobOrder_API.MQTTRepositoryMock()
    private let storage = JobOrder_API.CloudStorageRepositoryMock()
    private let settings = JobOrder_Data.SettingsRepositoryMock()
    private let keychain = JobOrder_Data.KeychainRepositoryMock()
    private let robot = JobOrder_Data.RobotRepositoryMock()
    private lazy var useCase = MQTTUseCase(authRepository: auth,
                                           mqttRepository: mqtt,
                                           storageRepository: storage,
                                           keychainRepository: keychain,
                                           robotDataRepository: robot)
    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_registerConnectionStatusChange() {

        JobOrder_API.MQTTEntity.Output.ConnectionStatus.allCases.forEach { status in
            let handlerExpectation = expectation(description: "handler \(status)")
            let completionExpectation = expectation(description: "completion \(status)")

            mqtt.registerConnectionStatusChangeHandler = {
                return Future<JobOrder_API.MQTTEntity.Output.ConnectionStatus, Never> { promise in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // PublisherのReturnより前にsendされて失敗するのでDelayを入れる
                        handlerExpectation.fulfill()
                        promise(.success(status))
                    }
                }.eraseToAnyPublisher()
            }

            useCase.registerConnectionStatusChange()
                .sink { response in
                    let model = MQTTModel.Output.ConnectionStatus(status)
                    XCTAssertEqual(response, model, "正しい値が取得できていない: \(model)")
                    switch response {
                    case .connected:
                        XCTAssertEqual(self.robot.readCallCount, 1, "RobotRepositoryのメソッドが呼ばれない")
                    default: break
                    }
                    completionExpectation.fulfill()
                }.store(in: &cancellables)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_registerConnectionStatusChangeNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mqtt.registerConnectionStatusChangeHandler = {
            return Future<JobOrder_API.MQTTEntity.Output.ConnectionStatus, Never> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.registerConnectionStatusChange()
            .sink { response in
                completionExpectation.fulfill()
            }.store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_connect() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mqtt.connectWithSetupHandler = {
            return Future<JobOrder_API.MQTTEntity.Output.ConnectWithSetup, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(.init(result: true)))
            }.eraseToAnyPublisher()
        }

        useCase.connect()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertTrue(response.result, "無効になってはいけない")
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_connectFailed() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mqtt.connectWithSetupHandler = {
            return Future<JobOrder_API.MQTTEntity.Output.ConnectWithSetup, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(.init(result: false)))
            }.eraseToAnyPublisher()
        }

        useCase.connect()
            .sink(receiveCompletion: { completion in
                XCTAssertEqual(self.keychain.setCallCount, 0, "KeychainRepositoryメソッドが呼ばれてしまう")
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertFalse(response.result, "有効になってはいけない")
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_connectNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mqtt.connectWithSetupHandler = {
            return Future<JobOrder_API.MQTTEntity.Output.ConnectWithSetup, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.connect()
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_connectError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)
        let expected = JobOrderError.internalError(error: error) as NSError

        mqtt.connectWithSetupHandler = {
            return Future<JobOrder_API.MQTTEntity.Output.ConnectWithSetup, Error> { promise in
                handlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.connect()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_disconnect() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mqtt.disconnectWithCleanUpHandler = {
            return Future<JobOrder_API.MQTTEntity.Output.DisconnectWithCleanup, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(.init(result: true)))
            }.eraseToAnyPublisher()
        }

        useCase.disconnect()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertTrue(response.result, "無効になってはいけない")
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_disconnectFailed() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mqtt.disconnectWithCleanUpHandler = {
            return Future<JobOrder_API.MQTTEntity.Output.DisconnectWithCleanup, Error> { promise in
                handlerExpectation.fulfill()
                promise(.success(.init(result: false)))
            }.eraseToAnyPublisher()
        }

        useCase.disconnect()
            .sink(receiveCompletion: { completion in
                XCTAssertEqual(self.keychain.setCallCount, 0, "KeychainRepositoryメソッドが呼ばれてしまう")
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertFalse(response.result, "有効になってはいけない")
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_disconnectNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mqtt.disconnectWithCleanUpHandler = {
            return Future<JobOrder_API.MQTTEntity.Output.DisconnectWithCleanup, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.disconnect()
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_disconnectError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)
        let expected = JobOrderError.internalError(error: error) as NSError

        mqtt.disconnectWithCleanUpHandler = {
            return Future<JobOrder_API.MQTTEntity.Output.DisconnectWithCleanup, Error> { promise in
                handlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.disconnect()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_subscribeRobots() {

        robot.readHandler = {
            return []
        }

        mqtt.subscribeHandler = { topic in
            return true
        }

        mqtt.registerSubscribedMessageHandler = {
            return Future<JobOrder_API.MQTTEntity.Output.SubscribedMessage, Never> { promise in
            }.eraseToAnyPublisher()
        }

        useCase.subscribeRobots()
        XCTAssertEqual(robot.readCallCount, 1, "RobotRepositoryのメソッドが呼ばれない")
    }

    func test_listTaskExecutions() {
        // TODO: Cloud側のAPI仕様変更待ち
    }

    func test_createJob() {
        // TODO: Cloud側のAPI仕様変更待ち
    }

    func test_subscribe() {
        let param = "test"
        let subscribeHandlerExpectation = expectation(description: "Subscribe handler")
        let registerSubscribeHandlerExpectation = expectation(description: "Subscribe handler")
        let completionExpectation = expectation(description: "completion")
        let entity = JobOrder_API.MQTTEntity.Output.SubscribedMessage(topic: param, data: Data())
        completionExpectation.isInverted = true

        mqtt.subscribeHandler = { topic in
            subscribeHandlerExpectation.fulfill()
            return true
        }

        mqtt.registerSubscribedMessageHandler = {
            return Future<JobOrder_API.MQTTEntity.Output.SubscribedMessage, Never> { promise in
                registerSubscribeHandlerExpectation.fulfill()
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        useCase.subscribe(thingName: param)

        XCTAssertEqual(mqtt.topicThingAllCallCount, 1, "MQTTRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(mqtt.topicGetThisThingShadowCallCount, 1, "MQTTRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(mqtt.unSubscribeCallCount, 0, "MQTTRepositoryのメソッドが呼ばれてしまう")
        XCTAssertEqual(mqtt.registerSubscribedMessageCallCount, 1, "MQTTRepositoryのメソッドが呼ばれない")

        wait(for: [subscribeHandlerExpectation, registerSubscribeHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertEqual(mqtt.publishCallCount, 1, "MQTTRepositoryのメソッドが呼ばれない")
    }

    func test_subscribeFailed() {
        let param = "test"
        let subscribeHandlerExpectation = expectation(description: "Subscribe handler")
        let registerSubscribeHandlerExpectation = expectation(description: "Subscribe handler")
        let completionExpectation = expectation(description: "completion")
        let entity = JobOrder_API.MQTTEntity.Output.SubscribedMessage(topic: param, data: Data())
        completionExpectation.isInverted = true

        mqtt.subscribeHandler = { topic in
            subscribeHandlerExpectation.fulfill()
            return false
        }

        mqtt.registerSubscribedMessageHandler = {
            return Future<JobOrder_API.MQTTEntity.Output.SubscribedMessage, Never> { promise in
                registerSubscribeHandlerExpectation.fulfill()
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        useCase.subscribe(thingName: param)

        XCTAssertEqual(mqtt.topicThingAllCallCount, 1, "MQTTRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(mqtt.topicGetThisThingShadowCallCount, 0, "MQTTRepositoryのメソッドが呼ばれてしまう")
        XCTAssertEqual(mqtt.unSubscribeCallCount, 1, "MQTTRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(mqtt.registerSubscribedMessageCallCount, 1, "MQTTRepositoryのメソッドが呼ばれない")

        wait(for: [registerSubscribeHandlerExpectation, subscribeHandlerExpectation, completionExpectation], timeout: ms1000)

        XCTAssertEqual(mqtt.publishCallCount, 0, "MQTTRepositoryのメソッドが呼ばれてしまう")
    }

    func test_unSubscribe() {
        let param = "test"

        useCase.unSubscribe(thingName: param)
        XCTAssertEqual(mqtt.topicThingAllCallCount, 1, "MQTTRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(mqtt.unSubscribeCallCount, 1, "MQTTRepositoryのメソッドが呼ばれない")
    }

    func test_updateData() {
        let param = "test"
        let message = MQTTModel.Output.SubscribedMessage(topic: param, payload: param)

        robot.readHandler = {
            let entity = RobotEntity()
            entity.thingName = "test"
            return [entity]
        }

        mqtt.thingNameHandler = { topic in
            return param
        }

        mqtt.shadowStateHandler = { topic, payload in
            return param
        }

        useCase.updateData(message: message)
        XCTAssertEqual(robot.updateCallCount, 1, "RobotRepositoryのメソッドが呼ばれない")
    }

    func test_updateDataFailed() {

        XCTContext.runActivity(named: "Payloadが空の場合") { _ in
            let param = ""
            let message = MQTTModel.Output.SubscribedMessage(topic: param, payload: param)

            useCase.updateData(message: message)
            XCTAssertEqual(robot.updateCallCount, 0, "RobotRepositoryのメソッドが呼ばれてしまう")
        }

        XCTContext.runActivity(named: "Robotが見つからない場合") { _ in
            let param = "test"
            let message = MQTTModel.Output.SubscribedMessage(topic: param, payload: param)

            robot.readHandler = {
                return []
            }

            useCase.updateData(message: message)
            XCTAssertEqual(robot.updateCallCount, 0, "RobotRepositoryのメソッドが呼ばれてしまう")
        }

        XCTContext.runActivity(named: "Stateが取得できない場合") { _ in
            let param = "test"
            let message = MQTTModel.Output.SubscribedMessage(topic: param, payload: param)

            robot.readHandler = {
                let entity = RobotEntity()
                entity.thingName = "test"
                return [entity]
            }

            mqtt.thingNameHandler = { topic in
                return param
            }

            mqtt.shadowStateHandler = { topic, payload in
                return nil
            }

            useCase.updateData(message: message)
            XCTAssertEqual(robot.updateCallCount, 0, "RobotRepositoryのメソッドが呼ばれてしまう")
        }
    }
}
