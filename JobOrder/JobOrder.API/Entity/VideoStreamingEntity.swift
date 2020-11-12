//
//  VideoStreamingEntity.swift
//  JobOrder.API
//
//  Created by Yu Suzuki on 2020/03/31.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import WebRTC

/// VideoStreamingエンティティ
public struct VideoStreamingEntity {

    /// Domainへ出力するためのデータ形式
    public struct Output {

        /// Signaling接続状態
        public enum SignalingConnectionStatus: CaseIterable {
            /// 接続済
            case connected
            /// 切断中
            case disconnected
        }

        /// 接続
        public struct Connect {
            /// ICEサーバーリスト
            public let iceServerList: [RTCIceServer]
        }

        /// 切断
        public struct Disconnect {
            static func == (lhs: Disconnect, rhs: Disconnect) -> Bool {
                return true
            }
        }

        /// Signalingから受信したSDP
        public struct ReceiveRemoteSdp {
            /// SDP
            public let sdp: RTCSessionDescription

            static func == (lhs: ReceiveRemoteSdp, rhs: ReceiveRemoteSdp) -> Bool {
                return lhs.sdp == rhs.sdp
            }
        }

        /// Signalingから受信したICE Candidate
        public struct ReceiveIceCandidate {
            /// ICE Candidate
            public let candidate: RTCIceCandidate

            static func == (lhs: ReceiveIceCandidate, rhs: ReceiveIceCandidate) -> Bool {
                return lhs.candidate == rhs.candidate
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
            public init(candidate: RTCIceCandidate) {
                self.candidate = candidate
            }
        }
    }
}
