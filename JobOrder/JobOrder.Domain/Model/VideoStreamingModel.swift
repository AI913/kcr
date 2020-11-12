//
//  VideoStreamingModel.swift
//  JobOrder.Domain
//
//  Created by Yu Suzuki on 2020/07/10.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import JobOrder_API
import WebRTC

/// VideoStreamingモデル
public struct VideoStreamingModel {

    /// Presentationへ出力するためのデータ形式
    public struct Output {

        /// Signaling接続状態
        public enum SignalingConnectionStatus {
            /// 接続済
            case connected
            /// 切断中
            case disconnected

            /// エンティティ -> モデル変換
            /// - Parameter entity: VideoStreamingエンティティ
            init(_ entity: JobOrder_API.VideoStreamingEntity.Output.SignalingConnectionStatus) {
                switch entity {
                case .connected: self = .connected
                case .disconnected: self = .disconnected
                }
            }
        }

        /// 接続
        public struct Connect {
            /// ICEサーバーリスト
            public let iceServerList: [RTCIceServer]

            /// エンティティ -> モデル変換
            /// - Parameter entity: VideoStreamingエンティティ
            init(_ entity: JobOrder_API.VideoStreamingEntity.Output.Connect) {
                self.iceServerList = entity.iceServerList
            }
        }

        /// 切断
        public struct Disconnect {}

        /// Signalingから受信したSDP
        public struct ReceiveRemoteSdp {
            /// SDP
            public let sdp: RTCSessionDescription

            /// エンティティ -> モデル変換
            /// - Parameter entity: VideoStreamingエンティティ
            init(_ entity: JobOrder_API.VideoStreamingEntity.Output.ReceiveRemoteSdp) {
                self.sdp = entity.sdp
            }
        }

        /// Signalingから受信したICE Candidate
        public struct ReceiveIceCandidate {
            /// ICE Candidate
            public let candidate: RTCIceCandidate

            /// エンティティ -> モデル変換
            /// - Parameter entity: VideoStreamingエンティティ
            init(_ entity: JobOrder_API.VideoStreamingEntity.Output.ReceiveIceCandidate) {
                self.candidate = entity.candidate
            }
        }
    }

    /// Presentationから入力されるデータ形式
    public struct Input {

        /// Signalingへ送信するSDP
        public struct SendSdp {
            /// SDP
            let sdp: RTCSessionDescription
            /// Offer or Answer
            let isOffer: Bool

            /// イニシャライザ
            public init(sdp: RTCSessionDescription, isOffer: Bool) {
                self.sdp = sdp
                self.isOffer = isOffer
            }
        }

        /// Signalingへ送信するICE Candidate
        public struct SendIceCandidate {
            /// ICE Candidate
            let candidate: RTCIceCandidate

            /// イニシャライザ
            /// - Parameter candidate: ICE Candidate
            public init(candidate: RTCIceCandidate) {
                self.candidate = candidate
            }
        }
    }
}
