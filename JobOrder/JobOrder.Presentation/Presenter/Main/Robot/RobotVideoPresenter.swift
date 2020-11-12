//
//  RobotVideoPresenter.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/07/10.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import UIKit
import Combine
import JobOrder_Domain
import JobOrder_Utility
import WebRTC

// MARK: - Interface
/// RobotVideoPresenterProtocol
/// @mockable
protocol RobotVideoPresenterProtocol: class {
    /// Connectボタンをタップ
    func tapConnectButton()
    /// 戻るボタンをタップ
    func tapBackButton()
    /// ビデオViewの貼り付け先をセット
    /// - Parameter view: 貼り付け先のView
    func setContainerView(view: UIView)
}

// MARK: - Implementation
/// RobotVideoPresenter
class RobotVideoPresenter {

    /// VideoStreamingUseCaseProtocol
    private let useCase: JobOrder_Domain.VideoStreamingUseCaseProtocol
    /// RobotVideoViewControllerProtocol
    private let vc: RobotVideoViewControllerProtocol
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// WebRTCClient
    private var webRTCClient: WebRTCClient?
    /// 貼り付け先のView
    private var containerView: UIView?
    /// ビデオView
    private var remoteRenderer: (UIView & RTCVideoRenderer)?

    /// イニシャライザ
    /// - Parameters:
    ///   - useCase: VideoStreamingUseCaseProtocol
    ///   - vc: RobotVideoViewControllerProtocol
    required init(useCase: JobOrder_Domain.VideoStreamingUseCaseProtocol,
                  vc: RobotVideoViewControllerProtocol) {
        self.useCase = useCase
        self.vc = vc
        registerStateChanges()
    }

    /// デイニシャライザ
    deinit {
        unregisterStateChanges()
    }
}

// MARK: - Interface Function
extension RobotVideoPresenter: RobotVideoPresenterProtocol {

    /// Connectボタンをタップ
    func tapConnectButton() {
        vc.showIndicator(isShown: true)
        connect(isMaster: false)
    }

    /// 戻るボタンをタップ
    func tapBackButton() {
        disconnect()
    }

    /// VideoViewの貼り付け先をセット
    /// - Parameter view: 貼り付け先のView
    func setContainerView(view: UIView) {
        containerView = view
    }
}

// MARK: - Private Function
extension RobotVideoPresenter {

    private func registerStateChanges() {

        useCase.registerSignalingConnectionStatusChange()
            .receive(on: DispatchQueue.main)
            .sink { response in
                Logger.debug(target: self, "SignalingConnectionStatus: \(response)")
                if response == .connected {
                    self.createVideoView()
                    self.sendOffer()
                }
            }.store(in: &cancellables)

        useCase.registerReceiveRemoteSdp()
            .receive(on: DispatchQueue.main)
            .sink { response in
                // Logger.debug(target: self, "RemoteSdp: \(response)")
                self.webRTCClient?.set(remoteSdp: response.sdp) { _ in
                    self.sendAnswer()
                }
            }.store(in: &cancellables)

        useCase.registerReceiveIceCandidate()
            .receive(on: DispatchQueue.main)
            .sink { response in
                // Logger.debug(target: self, "Candidate: \(response)")
                self.webRTCClient?.set(remoteCandidate: response.candidate)
            }.store(in: &cancellables)
    }

    private func unregisterStateChanges() {
        useCase.unregisterSignalingConnectionStatusChange()
        useCase.unregisterReceiveRemoteSdp()
        useCase.unregisterReceiveIceCandidate()
    }

    /// Video接続
    /// - Parameters:
    ///   - isMaster: isMaster: Master or Viewer
    private func connect(isMaster: Bool) {
        vc.changedProcessing(true)

        if isMaster {
            useCase.connectAsMaster()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                }, receiveValue: { response in
                    // Logger.debug(target: self, "\(response)")
                }).store(in: &cancellables)
        } else {
            useCase.connectAsViewer()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                }, receiveValue: { response in
                    // Logger.debug(target: self, "\(response)")
                    self.webRTCClient = WebRTCClient(iceServers: response.iceServerList, isAudioOn: false)
                    self.webRTCClient?.delegate = self
                }).store(in: &cancellables)
        }
    }

    /// Video切断
    private func disconnect() {
        webRTCClient?.shutdown()
        useCase.disconnect()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
            }, receiveValue: { response in
                // Logger.debug(target: self, "\(response)")
            }).store(in: &cancellables)
    }

    private func createVideoView() {
        #if arch(arm64) // Using metal (arm64 only)
        remoteRenderer = RTCMTLVideoView(frame: containerView?.frame ?? .zero)
        if let remoteRenderer = remoteRenderer as? RTCMTLVideoView {
            remoteRenderer.videoContentMode = .scaleAspectFill
        }
        #else // Using OpenGLES for the rest
        remoteRenderer = RTCEAGLVideoView(frame: containerView?.frame ?? .zero)
        #endif

        if let remoteRenderer = remoteRenderer {
            webRTCClient?.renderRemoteVideo(to: remoteRenderer)
        }
    }

    private func sendOffer() {
        webRTCClient?.offer { sdp in
            let model = JobOrder_Domain.VideoStreamingModel.Input.SendSdp(sdp: sdp, isOffer: true)
            self.useCase.sendSdp(input: model)
        }
    }

    private func sendAnswer() {
        webRTCClient?.answer { sdp in
            let model = JobOrder_Domain.VideoStreamingModel.Input.SendSdp(sdp: sdp, isOffer: false)
            self.useCase.sendSdp(input: model)
        }
    }

    private func sendIceCandidate(candidate: RTCIceCandidate) {
        let model = JobOrder_Domain.VideoStreamingModel.Input.SendIceCandidate(candidate: candidate)
        useCase.sendIceCandidate(input: model)
    }

    private func addView() {
        vc.showIndicator(isShown: false)
        vc.addVideoView(view: remoteRenderer)
    }

    private func removeView() {
        vc.changedProcessing(false)
        vc.removeVideoView(view: remoteRenderer)
    }
}

// MARK: - Implement WebRTCClientDelegate
extension RobotVideoPresenter: WebRTCClientDelegate {

    func webRTCClient(_ client: WebRTCClient, didGenerate candidate: RTCIceCandidate) {
        sendIceCandidate(candidate: candidate)
    }

    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {

        switch state {
        case .connected, .completed:
            Logger.debug(target: self, "WebRTC connected/completed state")
            DispatchQueue.main.async { self.addView() }
        case .disconnected:
            Logger.debug(target: self, "WebRTC disconnected state")
            DispatchQueue.main.async { self.removeView() }
        case .new:
            Logger.debug(target: self, "WebRTC new state")
        case .checking:
            Logger.debug(target: self, "WebRTC checking state")
        case .failed:
            Logger.debug(target: self, "WebRTC failed state")
        case .closed:
            Logger.debug(target: self, "WebRTC closed state")
            DispatchQueue.main.async { self.removeView() }
        case .count:
            Logger.debug(target: self, "WebRTC count state")
        @unknown default:
            Logger.debug(target: self, "WebRTC unknown state")
        }
    }

    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        Logger.debug(target: self, "Received local data")
    }
}
