//
//  AWSIoTDataStoreTests.swift
//  JobOrder.APITests
//
//  Created by Yu Suzuki on 2020/08/05.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import AWSIoT
@testable import JobOrder_API

class AWSIoTDataStoreTests: XCTestCase {

    private let ms200 = 0.2
    private let ms1000 = 1.0
    private let dataManager = AWSIoTDataManagerProtocolMock()
    private let iot = AWSIoTProtocolMock()
    private let mobileClient = AWSMobileClientProtocolMock()
    private let dataStore = AWSIoTDataStore()
    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        dataStore.awsMobileClient = mobileClient
        dataStore.dataManager = dataManager
        dataStore.awsIot = iot
    }

    override func tearDownWithError() throws {}

    func test_registerConnectionStatusChange() {
        let param = "test"
        var exps: [XCTestExpectation] = []

        dataStore.registerConnectionStatusChange()
            .sink { response in
                XCTAssertNotNil(response, "正しい値が取得できていない: \(response)")
                let exp = exps.first(where: { $0.expectationDescription == "completion \(response)" })
                exp?.fulfill()
            }.store(in: &self.cancellables)

        AWSIoTMQTTStatus.allValues.forEach { status in
            let output = MQTTEntity.Output.ConnectionStatus(status)
            let handlerExpectation = expectation(description: "handler \(output)")
            let completionExpectation = expectation(description: "completion \(output)")
            exps.append(completionExpectation)

            dataManager.connectUsingWebSocketHandler = { clientId, cleanSession, statusCallback in
                handlerExpectation.fulfill()
                statusCallback(status)
                return true
            }

            dataStore.connect(clientId: param, callback: { _, _ in })

            wait(for: [handlerExpectation], timeout: ms200)
        }
        wait(for: exps, timeout: ms1000)
    }

    func test_registerConnectionStatusChangeNotReceived() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        dataStore.registerConnectionStatusChange()
            .sink { response in
                completionExpectation.fulfill()
            }.store(in: &self.cancellables)

        dataManager.connectUsingWebSocketHandler = { clientId, cleanSession, statusCallback in
            handlerExpectation.fulfill()
            return true
        }

        dataStore.connect(clientId: param, callback: { _, _ in })

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_registerSubscribedMessage() {
        let param = "test"
        let connectionHandlerExpectation = expectation(description: "Connection handler")
        let subscribeHandlerExpectation = expectation(description: "Subscribe handler")
        let completionExpectation = expectation(description: "completion")

        dataManager.getConnectionStatusHandler = {
            connectionHandlerExpectation.fulfill()
            return .connected
        }

        dataManager.subscribeHandler = { topic, qos, extendedCallback in
            subscribeHandlerExpectation.fulfill()
            extendedCallback(NSObject(), param, Data(param.utf8))
            return true
        }

        dataStore.registerSubscribedMessage()
            .sink { response in
                XCTAssertEqual(response.topic, param, "正しい値が取得できていない: \(param)")
                XCTAssertEqual(response.payload, param, "正しい値が取得できていない: \(param)")
                completionExpectation.fulfill()
            }.store(in: &self.cancellables)

        let result = dataStore.subscribe(topic: param)
        XCTAssertTrue(result, "無効になってはいけない")

        wait(for: [connectionHandlerExpectation, subscribeHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_registerSubscribedMessageNotReceived() {
        let param = "test"
        let connectionHandlerExpectation = expectation(description: "Connection handler")
        let subscribeHandlerExpectation = expectation(description: "Subscribe handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        dataManager.getConnectionStatusHandler = {
            connectionHandlerExpectation.fulfill()
            return .connected
        }

        dataManager.subscribeHandler = { topic, qos, extendedCallback in
            subscribeHandlerExpectation.fulfill()
            return true
        }

        dataStore.registerSubscribedMessage()
            .sink { response in
                completionExpectation.fulfill()
            }.store(in: &self.cancellables)

        let result = dataStore.subscribe(topic: param)
        XCTAssertTrue(result, "無効になってはいけない")

        wait(for: [connectionHandlerExpectation, subscribeHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_connectWithSetup() {
        let param = "test"
        let getIdentityHandlerExpectation = expectation(description: "GetIdentity handler")
        let attachPolicyHandlerExpectation = expectation(description: "AttachPolicy handler")
        let connectHandlerExpectation = expectation(description: "Connect handler")
        let completionExpectation = expectation(description: "completion")

        mobileClient.getIdentityIdHandler = {
            getIdentityHandlerExpectation.fulfill()
            return AWSTask(result: param as NSString)
        }

        iot.attachPolicyHandler = { request in
            attachPolicyHandlerExpectation.fulfill()
            return AWSTask(result: param as NSString)
        }

        dataManager.connectUsingWebSocketHandler = { clientId, cleanSession, statusCallback in
            connectHandlerExpectation.fulfill()
            return true
        }

        dataStore.connectWithSetup()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertNotNil(response, "値が取得できていない: \(response)")
            }).store(in: &self.cancellables)

        wait(for: [getIdentityHandlerExpectation, attachPolicyHandlerExpectation, connectHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_connectWithSetupError() {
        let param = "test"

        XCTContext.runActivity(named: "GetIdentityIdに失敗した場合") { _ in
            let getIdentityHandlerExpectation = expectation(description: "GetIdentity handler")
            let completionExpectation = expectation(description: "completion")

            mobileClient.getIdentityIdHandler = {
                getIdentityHandlerExpectation.fulfill()
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                return AWSTask(error: error)
            }

            dataStore.connectWithSetup()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("値を取得できてはいけない")
                    case .failure(let error):
                        XCTAssertNotNil(error, "値が取得できていない: \(error)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { _ in
                }).store(in: &self.cancellables)

            wait(for: [getIdentityHandlerExpectation, completionExpectation], timeout: ms1000)
        }

        XCTContext.runActivity(named: "AttachPolicyに失敗した場合") { _ in
            let getIdentityHandlerExpectation = expectation(description: "GetIdentity handler")
            let attachPolicyHandlerExpectation = expectation(description: "AttachPolicy handler")
            let completionExpectation = expectation(description: "completion")

            mobileClient.getIdentityIdHandler = {
                getIdentityHandlerExpectation.fulfill()
                return AWSTask(result: param as NSString)
            }

            iot.attachPolicyHandler = { request in
                attachPolicyHandlerExpectation.fulfill()
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                return AWSTask(error: error)
            }

            dataStore.connectWithSetup()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("値を取得できてはいけない")
                    case .failure(let error):
                        XCTAssertNotNil(error, "値が取得できていない: \(error)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { _ in
                }).store(in: &self.cancellables)

            wait(for: [getIdentityHandlerExpectation, attachPolicyHandlerExpectation, completionExpectation], timeout: ms1000)
        }

        XCTContext.runActivity(named: "connectに失敗した場合") { _ in
            let getIdentityHandlerExpectation = expectation(description: "GetIdentity handler")
            let attachPolicyHandlerExpectation = expectation(description: "AttachPolicy handler")
            let connectHandlerExpectation = expectation(description: "Connect handler")
            let completionExpectation = expectation(description: "completion")

            mobileClient.getIdentityIdHandler = {
                getIdentityHandlerExpectation.fulfill()
                return AWSTask(result: param as NSString)
            }

            iot.attachPolicyHandler = { request in
                attachPolicyHandlerExpectation.fulfill()
                return AWSTask(result: param as NSString)
            }

            dataManager.connectUsingWebSocketHandler = { clientId, cleanSession, statusCallback in
                connectHandlerExpectation.fulfill()
                return false
            }

            dataStore.connectWithSetup()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("値を取得できてはいけない")
                    case .failure(let error):
                        XCTAssertNotNil(error, "値が取得できていない: \(error)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { _ in
                }).store(in: &self.cancellables)

            wait(for: [getIdentityHandlerExpectation, attachPolicyHandlerExpectation, connectHandlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_disconnectWithCleanUp() {
        let param = "test"
        let getIdentityHandlerExpectation = expectation(description: "GetIdentity handler")
        let detachPolicyHandlerExpectation = expectation(description: "DetachPolicy handler")
        let completionExpectation = expectation(description: "completion")

        mobileClient.getIdentityIdHandler = {
            getIdentityHandlerExpectation.fulfill()
            return AWSTask(result: param as NSString)
        }

        iot.detachPolicyHandler = { request in
            detachPolicyHandlerExpectation.fulfill()
            return AWSTask(result: nil)
        }

        dataStore.disconnectWithCleanUp()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertNotNil(response, "値が取得できていない")
            }).store(in: &self.cancellables)

        wait(for: [getIdentityHandlerExpectation, detachPolicyHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_disconnectWithCleanUpError() {
        let param = "test"

        XCTContext.runActivity(named: "getIdentityIdに失敗した場合") { _ in
            let getIdentityHandlerExpectation = expectation(description: "GetIdentity handler")
            let completionExpectation = expectation(description: "completion")

            mobileClient.getIdentityIdHandler = {
                getIdentityHandlerExpectation.fulfill()
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                return AWSTask(error: error)
            }

            dataStore.disconnectWithCleanUp()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("値を取得できてはいけない")
                    case .failure(let error):
                        XCTAssertNotNil(error, "値が取得できていない: \(error)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { _ in
                }).store(in: &self.cancellables)

            wait(for: [getIdentityHandlerExpectation, completionExpectation], timeout: ms1000)
        }

        XCTContext.runActivity(named: "DetachPolicyに失敗した場合") { _ in
            let getIdentityHandlerExpectation = expectation(description: "GetIdentity handler")
            let detachPolicyHandlerExpectation = expectation(description: "DetachPolicy handler")
            let completionExpectation = expectation(description: "completion")

            mobileClient.getIdentityIdHandler = {
                getIdentityHandlerExpectation.fulfill()
                return AWSTask(result: param as NSString)
            }

            iot.detachPolicyHandler = { request in
                detachPolicyHandlerExpectation.fulfill()
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                return AWSTask(error: error)
            }

            dataStore.disconnectWithCleanUp()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("値を取得できてはいけない")
                    case .failure(let error):
                        XCTAssertNotNil(error, "値が取得できていない: \(error)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { _ in
                }).store(in: &self.cancellables)

            wait(for: [getIdentityHandlerExpectation, detachPolicyHandlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_subscribeWithTrue() {
        let param = "test"
        var callCount = 0

        AWSIoTMQTTStatus.allValues.forEach { status in

            dataManager.getConnectionStatusHandler = {
                return status
            }

            dataManager.subscribeHandler = { topic, qos, extendedCallback in
                return true
            }

            let result = dataStore.subscribe(topic: param)
            if status == .connected {
                callCount += 1
                XCTAssertTrue(result, "無効になってはいけない")
            } else {
                XCTAssertFalse(result, "有効になってはいけない")
            }
            XCTAssertEqual(dataManager.subscribeCallCount, callCount, "AWSIoTDataManagerのメソッドが呼ばれない")
        }
    }

    func test_subscribeWithFalse() {
        let param = "test"
        var callCount = 0

        AWSIoTMQTTStatus.allValues.forEach { status in

            dataManager.getConnectionStatusHandler = {
                return status
            }

            dataManager.subscribeHandler = { topic, qos, extendedCallback in
                return false
            }

            let result = dataStore.subscribe(topic: param)

            if status == .connected {
                callCount += 1
            }
            XCTAssertEqual(dataManager.subscribeCallCount, callCount, "AWSIoTDataManagerのメソッドが呼ばれない")
            XCTAssertFalse(result, "有効になってはいけない")
        }
    }

    func test_unsubscribe() {
        let param = "test"
        var callCount = 0

        AWSIoTMQTTStatus.allValues.forEach { status in

            dataManager.getConnectionStatusHandler = {
                return status
            }

            dataStore.unSubscribe(topic: param)

            if status == .connected {
                callCount += 1
            }
            XCTAssertEqual(dataManager.unsubscribeTopicCallCount, callCount, "AWSIoTDataManagerのメソッドが呼ばれない")
        }
    }

    func test_publishWithTrue() {
        let param = "test"
        var callCount = 0

        AWSIoTMQTTStatus.allValues.forEach { status in

            dataManager.getConnectionStatusHandler = {
                return status
            }

            dataManager.publishStringHandler = { message, topic, qos in
                return true
            }

            let result = dataStore.publish(topic: param, message: param)
            if status == .connected {
                callCount += 1
                XCTAssertTrue(result, "無効になってはいけない")
            } else {
                XCTAssertFalse(result, "有効になってはいけない")
            }
            XCTAssertEqual(dataManager.publishStringCallCount, callCount, "AWSIoTDataManagerのメソッドが呼ばれない")
        }
    }

    func test_publishWithFalse() {
        let param = "test"
        var callCount = 0

        AWSIoTMQTTStatus.allValues.forEach { status in

            dataManager.getConnectionStatusHandler = {
                return status
            }

            dataManager.publishStringHandler = { topic, qos, extendedCallback in
                return false
            }

            let result = dataStore.publish(topic: param, message: param)
            XCTAssertFalse(result, "有効になってはいけない")
            if status == .connected {
                callCount += 1
            }
            XCTAssertEqual(dataManager.publishStringCallCount, callCount, "AWSIoTDataManagerのメソッドが呼ばれない")
        }
    }

    func test_listTaskExecutions() {
        // TODO: Cloud側のAPI仕様変更待ち
    }

    func test_createJob() {
        // TODO: Cloud側のAPI仕様変更待ち
    }

    func test_shadowState() {

        XCTContext.runActivity(named: "TopicがGetAcceptedの場合") { _ in
            let thingName = "Robot-KC-1"
            let param = "$aws/things/\(thingName)/shadow/get/accepted"
            XCTAssertNotNil(dataStore.shadowState(topic: param, payload: ""), "値が取得できていない: \(param)")
        }

        XCTContext.runActivity(named: "TopicがUpdateDocumentsの場合") { _ in
            let thingName = "Robot-KC-1"
            let param = "$aws/things/\(thingName)/shadow/update/documents"
            XCTAssertNotNil(dataStore.shadowState(topic: param, payload: ""), "値が取得できていない: \(param)")
        }

        XCTContext.runActivity(named: "TopicにThing名が含まれない場合") { _ in
            XCTAssertNil(dataStore.shadowState(topic: "", payload: ""), "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "Topicが対象外の場合") { _ in
            let thingName = "Robot-KC-1"
            let param = "$aws/things/\(thingName)/#"
            XCTAssertNil(dataStore.shadowState(topic: param, payload: ""), "値を取得できてはいけない")
        }
    }

    func test_thingName() {

        XCTContext.runActivity(named: "Topicが正しい場合") { _ in
            let thingName = "Robot-KC-1"
            let param = "$aws/things/\(thingName)/#"
            XCTAssertEqual(dataStore.thingName(topic: param), thingName, "値が取得できていない: \(param)")
        }

        XCTContext.runActivity(named: "Topicが不正な場合") { _ in
            XCTAssertNil(dataStore.thingName(topic: ""), "値を取得できてはいけない")
        }
    }

    func test_topicThingAll() {

        XCTContext.runActivity(named: "Thing名が正しい場合") { _ in
            let thingName = "Robot-KC-1"
            let result = "$aws/things/\(thingName)/#"
            XCTAssertEqual(dataStore.topicThingAll(thingName), result, "値が取得できていない: \(result)")
        }

        XCTContext.runActivity(named: "Thing名が不正な場合") { _ in
            XCTAssertNil(dataStore.topicThingAll(""), "値を取得できてはいけない")
        }
    }

    func test_topicGetThisThingShadow() {

        XCTContext.runActivity(named: "Thing名が正しい場合") { _ in
            let thingName = "Robot-KC-1"
            let result = "$aws/things/\(thingName)/shadow/get"
            XCTAssertEqual(dataStore.topicGetThisThingShadow(thingName), result, "値が取得できていない: \(result)")
        }

        XCTContext.runActivity(named: "Thing名が不正な場合") { _ in
            XCTAssertNil(dataStore.topicGetThisThingShadow(""), "値を取得できてはいけない")
        }
    }

    func test_connect() {
        let param = "test"
        let connectHandlerExpectation = expectation(description: "Connect handler")
        let completionExpectation = expectation(description: "completion")

        dataManager.connectUsingWebSocketHandler = { clientId, cleanSession, statusCallback in
            connectHandlerExpectation.fulfill()
            return true
        }

        dataStore.connect(clientId: param) {
            XCTAssertEqual($0, .completed, "正しい値が取得できていない")
            XCTAssertNil($1, "エラーを取得できてはいけない: \($1!.localizedDescription)")
            completionExpectation.fulfill()
        }

        wait(for: [connectHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_connectCheck() {
        XCTContext.runActivity(named: "ClientIdがnilの場合") { _ in
            dataStore.connect(clientId: nil) {
                XCTAssertEqual($0, .faulted, "正しい値が取得できていない")
                XCTAssertNotNil($1, "正しい値が取得できていない")
            }
        }
    }

    func test_connectError() {
        let param = "test"
        let connectHandlerExpectation = expectation(description: "Connect handler")
        let completionExpectation = expectation(description: "completion")

        dataManager.connectUsingWebSocketHandler = { clientId, cleanSession, statusCallback in
            connectHandlerExpectation.fulfill()
            return false
        }

        dataStore.connect(clientId: param) {
            XCTAssertEqual($0, .faulted, "正しい値が取得できていない")
            XCTAssertNotNil($1, "正しい値が取得できていない")
            completionExpectation.fulfill()
        }

        wait(for: [connectHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_disconnect() {

        dataStore.disconnect {
            XCTAssertEqual($0, .completed, "正しい値が取得できていない")
            XCTAssertNil($1, "エラーを取得できてはいけない: \($1!.localizedDescription)")
        }
    }
}

extension AWSIoTMQTTStatus {
    static let allValues = [unknown, connecting, connected, disconnected, connectionRefused, connectionError, protocolError]
}
