//
//  VideoStreamingUseCaseTests.swift
//  JobOrder.DomainTests
//
//  Created by Yu Suzuki on 2020/08/08.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
import WebRTC
@testable import JobOrder_Domain
@testable import JobOrder_API

class VideoStreamingUseCaseTests: XCTestCase {

    private let ms1000 = 1.0
    private let video = JobOrder_API.VideoStreamingRepositoryMock()
    private lazy var useCase = VideoStreamingUseCase(videoRepository: video)
    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_registerSignalingConnectionStatusChange() {

        JobOrder_API.VideoStreamingEntity.Output.SignalingConnectionStatus.allCases.forEach { status in
            let handlerExpectation = expectation(description: "handler \(status)")
            let completionExpectation = expectation(description: "completion \(status)")

            video.registerSignalingConnectionStatusChangeHandler = {
                return Future<JobOrder_API.VideoStreamingEntity.Output.SignalingConnectionStatus, Never> { promise in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // PublisherのReturnより前にsendされて失敗するのでDelayを入れる
                        handlerExpectation.fulfill()
                        promise(.success(status))
                    }
                }.eraseToAnyPublisher()
            }

            useCase.registerSignalingConnectionStatusChange()
                .sink { response in
                    let model = VideoStreamingModel.Output.SignalingConnectionStatus(status)
                    XCTAssertEqual(response, model, "正しい値が取得できていない: \(model)")
                    completionExpectation.fulfill()
                }.store(in: &cancellables)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_registerSignalingConnectionStatusChangeNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        video.registerSignalingConnectionStatusChangeHandler = {
            return Future<JobOrder_API.VideoStreamingEntity.Output.SignalingConnectionStatus, Never> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.registerSignalingConnectionStatusChange()
            .sink { response in
                completionExpectation.fulfill()
            }.store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_unregisterSignalingConnectionStatusChange() {
        useCase.unregisterSignalingConnectionStatusChange()
        XCTAssertEqual(video.unregisterSignalingConnectionStatusChangeCallCount, 1, "VideoStreamingRepositoryのメソッドが呼ばれない")
    }

    func test_registerReceiveRemoteSdp() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        video.registerReceiveRemoteSdpHandler = {
            return Future<JobOrder_API.VideoStreamingEntity.Output.ReceiveRemoteSdp, Never> { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // PublisherのReturnより前にsendされて失敗するのでDelayを入れる
                    handlerExpectation.fulfill()
                    let sdp = RTCSessionDescription(type: .offer, sdp: "")
                    let entity = JobOrder_API.VideoStreamingEntity.Output.ReceiveRemoteSdp(sdp: sdp)
                    promise(.success(entity))
                }
            }.eraseToAnyPublisher()
        }

        useCase.registerReceiveRemoteSdp()
            .sink { response in
                XCTAssertNotNil(response, "値が取得できていない")
                completionExpectation.fulfill()
            }.store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_registerReceiveRemoteSdpNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        video.registerReceiveRemoteSdpHandler = {
            return Future<JobOrder_API.VideoStreamingEntity.Output.ReceiveRemoteSdp, Never> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.registerReceiveRemoteSdp()
            .sink { response in
                completionExpectation.fulfill()
            }.store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_unregisterReceiveRemoteSdp() {
        useCase.unregisterReceiveRemoteSdp()
        XCTAssertEqual(video.unregisterReceiveRemoteSdpCallCount, 1, "VideoStreamingRepositoryのめsおddお")
    }

    func test_registerReceiveIceCandidate() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        video.registerReceiveIceCandidateHandler = {
            return Future<JobOrder_API.VideoStreamingEntity.Output.ReceiveIceCandidate, Never> { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // PublisherのReturnより前にsendされて失敗するのでDelayを入れる
                    handlerExpectation.fulfill()
                    let iceCandidate = RTCIceCandidate(sdp: "", sdpMLineIndex: 1, sdpMid: nil)
                    let entity = JobOrder_API.VideoStreamingEntity.Output.ReceiveIceCandidate(candidate: iceCandidate)
                    promise(.success(entity))
                }
            }.eraseToAnyPublisher()
        }

        useCase.registerReceiveIceCandidate()
            .sink { response in
                XCTAssertNotNil(response, "値が取得できていない")
                completionExpectation.fulfill()
            }.store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_registerReceiveIceCandidateNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        video.registerReceiveIceCandidateHandler = {
            return Future<JobOrder_API.VideoStreamingEntity.Output.ReceiveIceCandidate, Never> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.registerReceiveIceCandidate()
            .sink { response in
                completionExpectation.fulfill()
            }.store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_unregisterReceiveIceCandidate() {
        useCase.unregisterReceiveIceCandidate()
        XCTAssertEqual(video.unregisterReceiveIceCandidateCallCount, 1, "VideoStreamingRepositoryのメソッドが呼ばれない")
    }

    func test_connectAsMaster() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        video.connectAsRoleHandler = { isMaster in
            return Future<JobOrder_API.VideoStreamingEntity.Output.Connect, Error> { promise in
                handlerExpectation.fulfill()
                let entity = JobOrder_API.VideoStreamingEntity.Output.Connect(iceServerList: [])
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        useCase.connectAsMaster()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertNotNil(response, "値が取得できていない")
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_connectAsMasterNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        video.connectAsRoleHandler = { isMaster in
            return Future<JobOrder_API.VideoStreamingEntity.Output.Connect, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.connectAsMaster()
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_connectAsMasterError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)

        video.connectAsRoleHandler = { isMaster in
            return Future<JobOrder_API.VideoStreamingEntity.Output.Connect, Error> { promise in
                handlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.connectAsMaster()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(error, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_connectAsViewer() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        video.connectAsRoleHandler = { isMaster in
            return Future<JobOrder_API.VideoStreamingEntity.Output.Connect, Error> { promise in
                handlerExpectation.fulfill()
                let entity = JobOrder_API.VideoStreamingEntity.Output.Connect(iceServerList: [])
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        useCase.connectAsViewer()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertNotNil(response, "値が取得できていない")
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_connectAsViewerNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        video.connectAsRoleHandler = { isMaster in
            return Future<JobOrder_API.VideoStreamingEntity.Output.Connect, Error> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.connectAsViewer()
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_connectAsViewerError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)

        video.connectAsRoleHandler = { isMaster in
            return Future<JobOrder_API.VideoStreamingEntity.Output.Connect, Error> { promise in
                handlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.connectAsViewer()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(error, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_disconnect() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        video.disconnectHandler = {
            return Future<JobOrder_API.VideoStreamingEntity.Output.Disconnect, Never> { promise in
                handlerExpectation.fulfill()
                let entity = JobOrder_API.VideoStreamingEntity.Output.Disconnect()
                promise(.success(entity))
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
                XCTAssertNotNil(response, "値が取得できていない")
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_disconnectNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        video.disconnectHandler = {
            return Future<JobOrder_API.VideoStreamingEntity.Output.Disconnect, Never> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.disconnect()
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_sendSdp() {
        let sdp = RTCSessionDescription(type: .offer, sdp: "")
        let input = VideoStreamingModel.Input.SendSdp(sdp: sdp, isOffer: true)
        useCase.sendSdp(input: input)
        XCTAssertEqual(video.sendSdpCallCount, 1, "VideoStreamingRepositoryのメソッドが呼ばれない")
    }

    func test_sendIceCandidate() {
        let iceCandidate = RTCIceCandidate(sdp: "", sdpMLineIndex: 1, sdpMid: nil)
        let input = VideoStreamingModel.Input.SendIceCandidate(candidate: iceCandidate)
        useCase.sendIceCandidate(input: input)
        XCTAssertEqual(video.sendIceCandidateCallCount, 1, "VideoStreamingRepositoryのメソッドが呼ばれない")
    }
}
