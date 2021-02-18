//
//  AWSKVSDataStoreTests.swift
//  JobOrder.APITests
//
//  Created by Yu Suzuki on 2020/09/07.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import AWSKinesisVideo
@testable import AWSKinesisVideoSignaling
@testable import WebRTC
@testable import JobOrder_API

class AWSKVSDataStoreTests: XCTestCase {

    private let ms1000 = 1.0
    private let signalingClient = SignalingClientProtocolMock()
    private let kinesisVideo = AWSKinesisVideoProtocolMock()
    private let awsMobileClient = AWSMobileClientProtocolMock()
    private let awsKinesisVideoSignaling = AWSKinesisVideoSignalingProtocolMock()
    private let awsKinesisVideoSignalingClass = AWSKinesisVideoSignalingProtocolMock.self
    private let kvsSigner = KVSSignerProtocolMock.self
    private let dataStore = AWSKVSDataStore()
    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        dataStore.signalingClient = signalingClient
        dataStore.factory.kinesisVideo = kinesisVideo
        dataStore.factory.mobileClient = awsMobileClient
        dataStore.factory.kinesisVideoSignaling = awsKinesisVideoSignaling
        dataStore.factory.kinesisVideoSignalingClass = awsKinesisVideoSignalingClass
        dataStore.factory.kvsSignerClass = kvsSigner
    }

    override func tearDownWithError() throws {}

    func test_disconnect() {
        let completionExpectation = expectation(description: "completion")

        dataStore.disconnect()
            .sink { response in
                let entity = VideoStreamingEntity.Output.Disconnect()
                XCTAssert(response == entity, "正しい値が取得できていない: \(entity)")
                completionExpectation.fulfill()
            }.store(in: &self.cancellables)

        wait(for: [completionExpectation], timeout: ms1000)
    }

    func test_sendSdpWithOffer() {
        let param = "test"
        let sdp = RTCSessionDescription(type: .offer, sdp: param)
        let input = VideoStreamingEntity.Input.SendSdp(sdp: sdp, isOffer: true)
        dataStore.sendSdp(input: input)
        XCTAssertEqual(signalingClient.sendOfferCallCount, 1, "SignalingClientのメソッドが呼ばれていない")
        XCTAssertEqual(signalingClient.sendAnswerCallCount, 0, "SignalingClientのメソッドが呼ばれてはいけない")
    }

    func test_sendSdpWithAnswer() {
        let param = "test"
        let sdp = RTCSessionDescription(type: .answer, sdp: param)
        let input = VideoStreamingEntity.Input.SendSdp(sdp: sdp, isOffer: false)
        dataStore.sendSdp(input: input)
        XCTAssertEqual(signalingClient.sendOfferCallCount, 0, "SignalingClientのメソッドが呼ばれてはいけない")
        XCTAssertEqual(signalingClient.sendAnswerCallCount, 1, "SignalingClientのメソッドが呼ばれていない")
    }

    func test_sendIceCandidate() {
        let param = "test"
        let candidate = RTCIceCandidate(sdp: param, sdpMLineIndex: 3, sdpMid: param)
        let input = VideoStreamingEntity.Input.SendIceCandidate(candidate: candidate)
        dataStore.sendIceCandidate(input: input)
        XCTAssertEqual(signalingClient.sendIceCandidateCallCount, 1, "SignalingClientのメソッドが呼ばれていない")
    }

    func test_getChannelArn() {
        let param = "test"
        let describeSignalingChannelHandlerExpectation = expectation(description: "describe handler")
        let createSignalingChannelHandlerExpectation = expectation(description: "create handler")
        createSignalingChannelHandlerExpectation.isInverted = true
        let completionExpectation = expectation(description: "completion")

        kinesisVideo.describeSignalingChannelHandler = { output -> AWSTask<AWSKinesisVideoDescribeSignalingChannelOutput> in
            describeSignalingChannelHandlerExpectation.fulfill()
            let output = AWSKinesisVideoDescribeSignalingChannelOutput()
            output?.channelInfo = AWSKinesisVideoChannelInfo()
            output?.channelInfo?.channelARN = param
            return AWSTask(result: output)
        }

        kinesisVideo.createSignalingChannelHandler = { output -> AWSTask<AWSKinesisVideoCreateSignalingChannelOutput> in
            createSignalingChannelHandlerExpectation.fulfill()
            return AWSTask(result: nil)
        }

        dataStore.getChannelArn(param) {
            XCTAssertEqual($0, .completed, "正しい値が取得できていない")
            XCTAssertNotNil($1, "正しい値が取得できていない: \(param)")
            XCTAssertNil($2, "エラーを取得できてはいけない: \($2!.localizedDescription)")
            completionExpectation.fulfill()
        }

        wait(for: [describeSignalingChannelHandlerExpectation, createSignalingChannelHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_getChannelArnNotReceived() {
        let param = "test"
        let describeSignalingChannelHandlerExpectation = expectation(description: "describe handler")
        let createSignalingChannelHandlerExpectation = expectation(description: "create handler")
        let completionExpectation = expectation(description: "completion")

        kinesisVideo.describeSignalingChannelHandler = { output -> AWSTask<AWSKinesisVideoDescribeSignalingChannelOutput> in
            describeSignalingChannelHandlerExpectation.fulfill()
            return AWSTask(result: nil)
        }

        kinesisVideo.createSignalingChannelHandler = { output -> AWSTask<AWSKinesisVideoCreateSignalingChannelOutput> in
            createSignalingChannelHandlerExpectation.fulfill()
            let output = AWSKinesisVideoCreateSignalingChannelOutput()
            output?.channelARN = param
            return AWSTask(result: output)
        }

        dataStore.getChannelArn(param) {
            XCTAssertEqual($0, .completed, "正しい値が取得できていない")
            XCTAssertNotNil($1, "正しい値が取得できていない: \(param)")
            XCTAssertNil($2, "エラーを取得できてはいけない: \($2!.localizedDescription)")
            completionExpectation.fulfill()
        }

        wait(for: [describeSignalingChannelHandlerExpectation, createSignalingChannelHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_retrieveChannelArn() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        kinesisVideo.describeSignalingChannelHandler = { output -> AWSTask<AWSKinesisVideoDescribeSignalingChannelOutput> in
            handlerExpectation.fulfill()
            let output = AWSKinesisVideoDescribeSignalingChannelOutput()
            output?.channelInfo = AWSKinesisVideoChannelInfo()
            output?.channelInfo?.channelARN = param
            return AWSTask(result: output)
        }

        dataStore.retrieveChannelArn(param) {
            XCTAssertEqual($0, .completed, "正しい値が取得できていない")
            XCTAssertNotNil($1, "正しい値が取得できていない: \(param)")
            XCTAssertNil($2, "エラーを取得できてはいけない: \($2!.localizedDescription)")
            completionExpectation.fulfill()
        }

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_retrieveChannelArnError() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        kinesisVideo.describeSignalingChannelHandler = { output -> AWSTask<AWSKinesisVideoDescribeSignalingChannelOutput> in
            handlerExpectation.fulfill()
            let error = NSError(domain: "Error", code: -1, userInfo: nil)
            return AWSTask(error: error)
        }

        dataStore.retrieveChannelArn(param) {
            XCTAssertEqual($0, .faulted, "正しい値が取得できていない")
            XCTAssertNil($1, "値を取得できてはいけない")
            XCTAssertNotNil($2, "正しい値が取得できていない")
            completionExpectation.fulfill()
        }

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_createChannel() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        kinesisVideo.createSignalingChannelHandler = { output -> AWSTask<AWSKinesisVideoCreateSignalingChannelOutput> in
            handlerExpectation.fulfill()
            let output = AWSKinesisVideoCreateSignalingChannelOutput()
            output?.channelARN = param
            return AWSTask(result: output)
        }

        dataStore.createChannel(param) {
            XCTAssertEqual($0, .completed, "正しい値が取得できていない")
            XCTAssertNotNil($1, "正しい値が取得できていない: \(param)")
            XCTAssertNil($2, "エラーを取得できてはいけない: \($2!.localizedDescription)")
            completionExpectation.fulfill()
        }

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_createChannelError() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        kinesisVideo.createSignalingChannelHandler = { output -> AWSTask<AWSKinesisVideoCreateSignalingChannelOutput> in
            handlerExpectation.fulfill()
            let error = NSError(domain: "Error", code: -1, userInfo: nil)
            return AWSTask(error: error)
        }

        dataStore.createChannel(param) {
            XCTAssertEqual($0, .faulted, "正しい値が取得できていない")
            XCTAssertNil($1, "値を取得できてはいけない")
            XCTAssertNotNil($2, "正しい値が取得できていない")
            completionExpectation.fulfill()
        }

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_getSignedWSSUrl() {
        let param = "test"
        let paramHttps = "test/https"
        let paramWss = "test/wss"
        let signalingHandlerExpectation = expectation(description: "Signaling handler")
        let credentialsHandlerExpectation = expectation(description: "Credentials handler")
        let signHandlerExpectation = expectation(description: "Sign handler")
        let iceServerHandlerExpectation = expectation(description: "IceServer handler")
        let completionExpectation = expectation(description: "completion")

        kinesisVideo.getSignalingChannelEndpointHandler = { output -> AWSTask<AWSKinesisVideoGetSignalingChannelEndpointOutput> in
            signalingHandlerExpectation.fulfill()
            let output = AWSKinesisVideoGetSignalingChannelEndpointOutput()
            let endpoint1 = AWSKinesisVideoResourceEndpointListItem()!
            endpoint1.resourceEndpoint = paramHttps
            endpoint1.protocols = .https
            let endpoint2 = AWSKinesisVideoResourceEndpointListItem()!
            endpoint2.resourceEndpoint = paramWss
            endpoint2.protocols = .wss
            output?.resourceEndpointList = [endpoint1, endpoint2]
            return AWSTask(result: output)
        }

        awsMobileClient.getAWSCredentialsHandler = { completionHandler in
            let output = AWSCredentials(accessKey: param, secretKey: param, sessionKey: param, expiration: Date())
            completionHandler(output, nil)
            credentialsHandlerExpectation.fulfill()
        }

        kvsSigner.signHandler = { signRequest, secretKey, accessKey, sessionToken, wssRequest, region in
            signHandlerExpectation.fulfill()
            return URL(string: paramWss)
        }

        awsKinesisVideoSignaling.getIceServerConfigHandler = { request in
            iceServerHandlerExpectation.fulfill()
            let response = AWSKinesisVideoSignalingGetIceServerConfigResponse()
            response?.iceServerList = []
            return AWSTask(result: response)
        }

        dataStore.getSignedWSSUrl(param, param) {
            XCTAssertEqual($0, .completed, "正しい値が取得できていない")
            XCTAssertEqual($1?.0, URL(string: paramWss), "正しい値が取得できていない: \(paramWss)")
            XCTAssertEqual($1?.1, URL(string: paramHttps), "正しい値が取得できていない: \(paramHttps)")
            XCTAssertNotNil($1?.2, "正しい値が取得できていない")
            XCTAssertNil($2, "エラーを取得できてはいけない: \($2!.localizedDescription)")
            completionExpectation.fulfill()
        }

        wait(for: [signalingHandlerExpectation, credentialsHandlerExpectation, signHandlerExpectation, iceServerHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_getSignedWSSUrlError() {
        let param = "test"
        let paramHttps = "test/https"
        let paramWss = "test/wss"

        XCTContext.runActivity(named: "SignalingEndpointの取得に失敗した場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")

            kinesisVideo.getSignalingChannelEndpointHandler = { output -> AWSTask<AWSKinesisVideoGetSignalingChannelEndpointOutput> in
                handlerExpectation.fulfill()
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                return AWSTask(error: error)
            }

            dataStore.getSignedWSSUrl(param, param) {
                XCTAssertEqual($0, .faulted, "正しい値が取得できていない")
                XCTAssertNil($1, "値を取得できてはいけない")
                XCTAssertNotNil($2, "正しい値が取得できていない")
                completionExpectation.fulfill()
            }

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }

        XCTContext.runActivity(named: "IceServerConfigの取得に成功した場合") { _ in
            let signalingHandlerExpectation = expectation(description: "Signaling handler")
            let credentialsHandlerExpectation = expectation(description: "Credentials handler")
            let completionExpectation = expectation(description: "completion")

            kinesisVideo.getSignalingChannelEndpointHandler = { output -> AWSTask<AWSKinesisVideoGetSignalingChannelEndpointOutput> in
                signalingHandlerExpectation.fulfill()
                let output = AWSKinesisVideoGetSignalingChannelEndpointOutput()
                let endpoint1 = AWSKinesisVideoResourceEndpointListItem()!
                endpoint1.resourceEndpoint = paramHttps
                endpoint1.protocols = .https
                let endpoint2 = AWSKinesisVideoResourceEndpointListItem()!
                endpoint2.resourceEndpoint = paramWss
                endpoint2.protocols = .wss
                output?.resourceEndpointList = [endpoint1, endpoint2]
                return AWSTask(result: output)
            }

            awsMobileClient.getAWSCredentialsHandler = { completionHandler in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                completionHandler(nil, error)
                credentialsHandlerExpectation.fulfill()
            }

            dataStore.getSignedWSSUrl(param, param) {
                XCTAssertEqual($0, .faulted, "正しい値が取得できていない")
                XCTAssertNil($1, "値を取得できてはいけない")
                XCTAssertNotNil($2, "正しい値が取得できていない")
                completionExpectation.fulfill()
            }

            wait(for: [signalingHandlerExpectation, credentialsHandlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_getSignalingChannelEndpoint() {
        let param = "test"
        let paramHttps = "test/https"
        let paramWss = "test/wss"
        let signalingHandlerExpectation = expectation(description: "Signaling handler")
        let credentialsHandlerExpectation = expectation(description: "Credentials handler")
        let signHandlerExpectation = expectation(description: "Sign handler")
        let completionExpectation = expectation(description: "completion")

        kinesisVideo.getSignalingChannelEndpointHandler = { output -> AWSTask<AWSKinesisVideoGetSignalingChannelEndpointOutput> in
            signalingHandlerExpectation.fulfill()
            let output = AWSKinesisVideoGetSignalingChannelEndpointOutput()
            let endpoint1 = AWSKinesisVideoResourceEndpointListItem()!
            endpoint1.resourceEndpoint = paramHttps
            endpoint1.protocols = .https
            let endpoint2 = AWSKinesisVideoResourceEndpointListItem()!
            endpoint2.resourceEndpoint = paramWss
            endpoint2.protocols = .wss
            output?.resourceEndpointList = [endpoint1, endpoint2]
            return AWSTask(result: output)
        }

        awsMobileClient.getAWSCredentialsHandler = { completionHandler in
            credentialsHandlerExpectation.fulfill()
            let output = AWSCredentials(accessKey: param, secretKey: param, sessionKey: param, expiration: Date())
            completionHandler(output, nil)
        }

        kvsSigner.signHandler = { signRequest, secretKey, accessKey, sessionToken, wssRequest, region in
            signHandlerExpectation.fulfill()
            return URL(string: paramWss)
        }

        dataStore.getSignalingChannelEndpoint(param, param) {
            XCTAssertEqual($0, .completed, "正しい値が取得できていない")
            XCTAssertEqual($1?.0, URL(string: paramWss), "正しい値が取得できていない: \(paramWss)")
            XCTAssertEqual($1?.1, URL(string: paramHttps), "正しい値が取得できていない: \(paramHttps)")
            XCTAssertNil($2, "エラーを取得できてはいけない: \($2!.localizedDescription)")
            completionExpectation.fulfill()
        }

        wait(for: [signalingHandlerExpectation, credentialsHandlerExpectation, signHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_getSignalingChannelEndpointError() {
        let param = "test"
        let paramHttps = "test/https"
        let paramWss = "test/wss"

        XCTContext.runActivity(named: "SignalingChannelEndpointの取得に失敗した場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")

            kinesisVideo.getSignalingChannelEndpointHandler = { output -> AWSTask<AWSKinesisVideoGetSignalingChannelEndpointOutput> in
                handlerExpectation.fulfill()
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                return AWSTask(error: error)
            }

            dataStore.getSignalingChannelEndpoint(param, param) {
                XCTAssertEqual($0, .faulted, "正しい値が取得できていない")
                XCTAssertNil($1, "値を取得できてはいけない")
                XCTAssertNotNil($2, "正しい値が取得できていない")
                completionExpectation.fulfill()
            }

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }

        XCTContext.runActivity(named: "wssResourceEndpointの取得に失敗した場合") { _ in
            let handlerExpectation = expectation(description: "handler")
            let completionExpectation = expectation(description: "completion")

            kinesisVideo.getSignalingChannelEndpointHandler = { output -> AWSTask<AWSKinesisVideoGetSignalingChannelEndpointOutput> in
                handlerExpectation.fulfill()
                let output = AWSKinesisVideoGetSignalingChannelEndpointOutput()
                let endpoint1 = AWSKinesisVideoResourceEndpointListItem()!
                endpoint1.resourceEndpoint = paramHttps
                endpoint1.protocols = .https
                output?.resourceEndpointList = [endpoint1]
                return AWSTask(result: output)
            }

            dataStore.getSignalingChannelEndpoint(param, param) {
                XCTAssertEqual($0, .faulted, "正しい値が取得できていない")
                XCTAssertNil($1, "値を取得できてはいけない")
                XCTAssertNotNil($2, "正しい値が取得できていない")
                completionExpectation.fulfill()
            }

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }

        XCTContext.runActivity(named: "credentialsの取得に失敗した場合") { _ in
            let signalingHandlerExpectation = expectation(description: "Signaling handler")
            let credentialsHandlerExpectation = expectation(description: "Credentials handler")
            let completionExpectation = expectation(description: "completion")

            kinesisVideo.getSignalingChannelEndpointHandler = { output -> AWSTask<AWSKinesisVideoGetSignalingChannelEndpointOutput> in
                signalingHandlerExpectation.fulfill()
                let output = AWSKinesisVideoGetSignalingChannelEndpointOutput()
                let endpoint1 = AWSKinesisVideoResourceEndpointListItem()!
                endpoint1.resourceEndpoint = paramHttps
                endpoint1.protocols = .https
                let endpoint2 = AWSKinesisVideoResourceEndpointListItem()!
                endpoint2.resourceEndpoint = paramWss
                endpoint2.protocols = .wss
                output?.resourceEndpointList = [endpoint1, endpoint2]
                return AWSTask(result: output)
            }

            awsMobileClient.getAWSCredentialsHandler = { completionHandler in
                credentialsHandlerExpectation.fulfill()
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                completionHandler(nil, error)
            }

            dataStore.getSignalingChannelEndpoint(param, param) {
                XCTAssertEqual($0, .faulted, "正しい値が取得できていない")
                XCTAssertNil($1, "値を取得できてはいけない")
                XCTAssertNotNil($2, "正しい値が取得できていない")
                completionExpectation.fulfill()
            }

            wait(for: [signalingHandlerExpectation, credentialsHandlerExpectation, completionExpectation], timeout: ms1000)
        }

        XCTContext.runActivity(named: "wssUrlの取得に失敗した場合") { _ in
            let signalingHandlerExpectation = expectation(description: "Signaling handler")
            let credentialsHandlerExpectation = expectation(description: "Credentials handler")
            let signHandlerExpectation = expectation(description: "Sign handler")
            let completionExpectation = expectation(description: "completion")

            kinesisVideo.getSignalingChannelEndpointHandler = { output -> AWSTask<AWSKinesisVideoGetSignalingChannelEndpointOutput> in
                signalingHandlerExpectation.fulfill()
                let output = AWSKinesisVideoGetSignalingChannelEndpointOutput()
                let endpoint1 = AWSKinesisVideoResourceEndpointListItem()!
                endpoint1.resourceEndpoint = paramHttps
                endpoint1.protocols = .https
                let endpoint2 = AWSKinesisVideoResourceEndpointListItem()!
                endpoint2.resourceEndpoint = paramWss
                endpoint2.protocols = .wss
                output?.resourceEndpointList = [endpoint1, endpoint2]
                return AWSTask(result: output)
            }

            awsMobileClient.getAWSCredentialsHandler = { completionHandler in
                credentialsHandlerExpectation.fulfill()
                let output = AWSCredentials(accessKey: param, secretKey: param, sessionKey: param, expiration: Date())
                completionHandler(output, nil)
            }

            kvsSigner.signHandler = { signRequest, secretKey, accessKey, sessionToken, wssRequest, region in
                signHandlerExpectation.fulfill()
                return nil
            }

            dataStore.getSignalingChannelEndpoint(param, param) {
                XCTAssertEqual($0, .faulted, "正しい値が取得できていない")
                XCTAssertNil($1, "値を取得できてはいけない")
                XCTAssertNotNil($2, "正しい値が取得できていない")
                completionExpectation.fulfill()
            }

            wait(for: [signalingHandlerExpectation, credentialsHandlerExpectation, signHandlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_getIceServerConfig() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        awsKinesisVideoSignaling.getIceServerConfigHandler = { request in
            handlerExpectation.fulfill()
            let response = AWSKinesisVideoSignalingGetIceServerConfigResponse()
            response?.iceServerList = []
            return AWSTask(result: response)
        }

        dataStore.getIceServerConfig(URL(string: param)!, param, param) {
            XCTAssertEqual($0, .completed, "正しい値が取得できていない")
            XCTAssertNotNil($1, "正しい値が取得できていない")
            XCTAssertNil($2, "エラーを取得できてはいけない: \($2!.localizedDescription)")
            completionExpectation.fulfill()
        }

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_getIceServerConfigError() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        awsKinesisVideoSignaling.getIceServerConfigHandler = { request in
            handlerExpectation.fulfill()
            let error = NSError(domain: "Error", code: -1, userInfo: nil)
            return AWSTask(error: error)
        }

        dataStore.getIceServerConfig(URL(string: param)!, param, param) {
            XCTAssertEqual($0, .faulted, "正しい値が取得できていない")
            XCTAssertNil($1, "値を取得できてはいけない")
            XCTAssertNotNil($2, "正しい値が取得できていない")
            completionExpectation.fulfill()
        }

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_signalClientDidConnect() {
        let param = "test"
        let completionExpectation = expectation(description: "completion")
        let url = URL(string: param)!
        let client = SignalingClient(serverUrl: url)

        dataStore.registerSignalingConnectionStatusChange()
            .sink { response in
                XCTAssertEqual(response, .connected, "正しい値が取得できていない")
                completionExpectation.fulfill()
            }.store(in: &cancellables)

        dataStore.signalClientDidConnect(client)

        wait(for: [completionExpectation], timeout: ms1000)
    }

    func test_signalClientDidDisconnect() {
        let param = "test"
        let completionExpectation = expectation(description: "completion")
        let url = URL(string: param)!
        let client = SignalingClient(serverUrl: url)

        dataStore.registerSignalingConnectionStatusChange()
            .sink { response in
                XCTAssertEqual(response, .disconnected, "正しい値が取得できていない")
                completionExpectation.fulfill()
            }.store(in: &cancellables)

        dataStore.signalClientDidDisconnect(client)

        wait(for: [completionExpectation], timeout: ms1000)
    }

    func test_signalClientDidReceiveRemoteSdp() {
        let param = "test"
        let completionExpectation = expectation(description: "completion")
        let url = URL(string: param)!
        let client = SignalingClient(serverUrl: url)
        let sdp = RTCSessionDescription(type: .answer, sdp: param)

        dataStore.registerReceiveRemoteSdp()
            .sink { response in
                let entity = VideoStreamingEntity.Output.ReceiveRemoteSdp(sdp: sdp)
                XCTAssert(response == entity, "正しい値が取得できていない: \(entity)")
                completionExpectation.fulfill()
            }.store(in: &cancellables)

        dataStore.signalClient(client, senderClientId: param, didReceiveRemoteSdp: sdp)

        wait(for: [completionExpectation], timeout: ms1000)
    }

    func test_signalClientDidReceiveCandidate() {
        let param = "test"
        let completionExpectation = expectation(description: "completion")
        let url = URL(string: param)!
        let client = SignalingClient(serverUrl: url)
        let candidate = RTCIceCandidate(sdp: param, sdpMLineIndex: 3, sdpMid: param)

        dataStore.registerReceiveIceCandidate()
            .sink { response in
                let entity = VideoStreamingEntity.Output.ReceiveIceCandidate(candidate: candidate)
                XCTAssert(response == entity, "正しい値が取得できていない: \(entity)")
                completionExpectation.fulfill()
            }.store(in: &cancellables)

        dataStore.signalClient(client, senderClientId: param, didReceiveCandidate: candidate)

        wait(for: [completionExpectation], timeout: ms1000)
    }
}
