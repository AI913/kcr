//
//  VideoStreamingRepository.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

/// クラウドに対してビデオストリーミングを行うためのプロトコル
/// @mockable
public protocol VideoStreamingRepository {
    /// 初期化
    func initialize()
    /// Signaling接続状態通知イベントの登録
    func registerSignalingConnectionStatusChange() -> AnyPublisher<VideoStreamingEntity.Output.SignalingConnectionStatus, Never>
    /// Signaling接続状態通知イベントの解除
    func unregisterSignalingConnectionStatusChange()
    /// SDP受信通知イベントの登録
    func registerReceiveRemoteSdp() -> AnyPublisher<VideoStreamingEntity.Output.ReceiveRemoteSdp, Never>
    /// SDP受信通知イベントの解除
    func unregisterReceiveRemoteSdp()
    /// ICE Candidate受信通知イベントの登録
    func registerReceiveIceCandidate() -> AnyPublisher<VideoStreamingEntity.Output.ReceiveIceCandidate, Never>
    /// ICE Candidate受信通知イベントの解除
    func unregisterReceiveIceCandidate()
    /// 指定したRoleで接続
    /// - Parameter isMaster: Master or Viewer
    func connectAsRole(isMaster: Bool) -> AnyPublisher<VideoStreamingEntity.Output.Connect, Error>
    /// 切断
    func disconnect() -> AnyPublisher<VideoStreamingEntity.Output.Disconnect, Never>
    /// シグナリングサーバーへSDP送信
    /// - Parameter input: sdp, isOffer
    func sendSdp(input: VideoStreamingEntity.Input.SendSdp)
    /// シグナリングサーバーへICE Candidate送信
    /// - Parameter input: ICE Candidate
    func sendIceCandidate(input: VideoStreamingEntity.Input.SendIceCandidate)
}
