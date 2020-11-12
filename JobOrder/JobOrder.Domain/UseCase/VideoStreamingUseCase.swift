//
//  VideoStreamingUseCase.swift
//  JobOrder.Domain
//
//  Created by Yu Suzuki on 2020/07/10.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_API
import JobOrder_Utility

// MARK: - Interface
/// VideoStreamingUseCaseProtocol
/// @mockable
public protocol VideoStreamingUseCaseProtocol: class {
    /// 接続状態通知イベントの登録
    func registerSignalingConnectionStatusChange() -> AnyPublisher<VideoStreamingModel.Output.SignalingConnectionStatus, Never>
    /// 接続状態通知イベントの解除
    func unregisterSignalingConnectionStatusChange()
    /// SDP受信通知イベントの登録
    func registerReceiveRemoteSdp() -> AnyPublisher<VideoStreamingModel.Output.ReceiveRemoteSdp, Never>
    /// SDP受信通知イベントの解除
    func unregisterReceiveRemoteSdp()
    /// ICE Candidate受信通知イベントの登録
    func registerReceiveIceCandidate() -> AnyPublisher<VideoStreamingModel.Output.ReceiveIceCandidate, Never>
    /// ICE Candidate受信通知イベントの解除
    func unregisterReceiveIceCandidate()
    /// Masterとして接続
    func connectAsMaster() -> AnyPublisher<VideoStreamingModel.Output.Connect, Error>
    /// Viewerとして接続
    func connectAsViewer() -> AnyPublisher<VideoStreamingModel.Output.Connect, Error>
    /// 切断
    func disconnect() -> AnyPublisher<VideoStreamingModel.Output.Disconnect, Never>
    /// SDP送信
    /// - Parameter input: SDP, isOffer
    func sendSdp(input: VideoStreamingModel.Input.SendSdp)
    /// ICE Candidate送信
    /// - Parameter input: ICE Candidate
    func sendIceCandidate(input: VideoStreamingModel.Input.SendIceCandidate)
}

// MARK: - Implementation
/// VideoStreamingUseCase
public class VideoStreamingUseCase: VideoStreamingUseCaseProtocol {

    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// VideoStreamingレポジトリ
    private let video: JobOrder_API.VideoStreamingRepository

    /// イニシャライザ
    /// - Parameters:
    ///   - videoRepository: VideoStreamingレポジトリ
    public required init(videoRepository: JobOrder_API.VideoStreamingRepository) {
        self.video = videoRepository
    }

    /// 接続状態通知イベントの登録
    public func registerSignalingConnectionStatusChange() -> AnyPublisher<VideoStreamingModel.Output.SignalingConnectionStatus, Never> {
        Logger.info(target: self)

        let publisher = PassthroughSubject<VideoStreamingModel.Output.SignalingConnectionStatus, Never>()
        video.registerSignalingConnectionStatusChange()
            .map { value -> VideoStreamingModel.Output.SignalingConnectionStatus in
                return VideoStreamingModel.Output.SignalingConnectionStatus(value)
            }.sink { response in
                // Logger.debug(target: self, "\(response)")
                publisher.send(response)
            }.store(in: &cancellables)
        return publisher.eraseToAnyPublisher()
    }

    /// 接続状態通知イベントの解除
    public func unregisterSignalingConnectionStatusChange() {
        Logger.info(target: self)
        video.unregisterSignalingConnectionStatusChange()
    }

    /// SDP受信通知イベントの登録
    /// - Returns: 接続状態
    public func registerReceiveRemoteSdp() -> AnyPublisher<VideoStreamingModel.Output.ReceiveRemoteSdp, Never> {
        Logger.info(target: self)

        let publisher = PassthroughSubject<VideoStreamingModel.Output.ReceiveRemoteSdp, Never>()
        video.registerReceiveRemoteSdp()
            .map { value -> VideoStreamingModel.Output.ReceiveRemoteSdp in
                return VideoStreamingModel.Output.ReceiveRemoteSdp(value)
            }.sink { response in
                // Logger.debug(target: self, "\(response)")
                publisher.send(response)
            }.store(in: &cancellables)
        return publisher.eraseToAnyPublisher()
    }

    /// SDP受信通知イベントの解除
    public func unregisterReceiveRemoteSdp() {
        Logger.info(target: self)
        video.unregisterReceiveRemoteSdp()
    }

    /// ICE Candidate受信通知イベントの登録
    /// - Returns: 接続状態
    public func registerReceiveIceCandidate() -> AnyPublisher<VideoStreamingModel.Output.ReceiveIceCandidate, Never> {
        Logger.info(target: self)

        let publisher = PassthroughSubject<VideoStreamingModel.Output.ReceiveIceCandidate, Never>()
        video.registerReceiveIceCandidate()
            .map { value -> VideoStreamingModel.Output.ReceiveIceCandidate in
                return VideoStreamingModel.Output.ReceiveIceCandidate(value)
            }.sink { response in
                // Logger.debug(target: self, "\(response)")
                publisher.send(response)
            }.store(in: &cancellables)
        return publisher.eraseToAnyPublisher()
    }

    /// ICE Candidate受信通知イベントの解除
    public func unregisterReceiveIceCandidate() {
        Logger.info(target: self)
        video.unregisterReceiveIceCandidate()
    }

    /// Masterとして接続
    /// - Returns: 接続結果
    public func connectAsMaster() -> AnyPublisher<VideoStreamingModel.Output.Connect, Error> {
        Logger.info(target: self)

        return Future<VideoStreamingModel.Output.Connect, Error> { promise in
            self.video.connectAsRole(isMaster: true)
                .map { value -> VideoStreamingModel.Output.Connect in
                    return VideoStreamingModel.Output.Connect(value)
                }.sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    // Logger.debug(target: self, "\(response)")
                    promise(.success(response))
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }

    /// Viewerとして接続
    /// - Returns: 接続結果
    public func connectAsViewer() -> AnyPublisher<VideoStreamingModel.Output.Connect, Error> {
        Logger.info(target: self)

        return Future<VideoStreamingModel.Output.Connect, Error> { promise in
            self.video.connectAsRole(isMaster: false)
                .map { value -> VideoStreamingModel.Output.Connect in
                    return VideoStreamingModel.Output.Connect(value)
                }.sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    // Logger.debug(target: self, "\(response)")
                    promise(.success(response))
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }

    /// 切断
    /// - Returns: 切断結果
    public func disconnect() -> AnyPublisher<VideoStreamingModel.Output.Disconnect, Never> {
        Logger.info(target: self)

        return Future<VideoStreamingModel.Output.Disconnect, Never> { promise in
            self.video.disconnect()
                .map { value -> VideoStreamingModel.Output.Disconnect in
                    return VideoStreamingModel.Output.Disconnect()
                }.sink { response in
                    // Logger.debug(target: self, "\(response)")
                    promise(.success(response))
                }.store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }

    /// SDP送信
    /// - Parameter input: SDP, isOffer
    public func sendSdp(input: VideoStreamingModel.Input.SendSdp) {
        let entity = JobOrder_API.VideoStreamingEntity.Input.SendSdp(sdp: input.sdp, isOffer: input.isOffer)
        video.sendSdp(input: entity)
    }

    /// ICE Candidate送信
    /// - Parameter input: ICE Candidate
    public func sendIceCandidate(input: VideoStreamingModel.Input.SendIceCandidate) {
        let entity = JobOrder_API.VideoStreamingEntity.Input.SendIceCandidate(candidate: input.candidate)
        video.sendIceCandidate(input: entity)
    }
}
