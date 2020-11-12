//
//  MQTTEntity.swift
//  JobOrder.API
//
//  Created by Yu Suzuki on 2020/03/31.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

/// MQTTエンティティ
public struct MQTTEntity {

    /// Domainへ出力するためのデータ形式
    public struct Output {

        /// 接続状態
        public enum ConnectionStatus: CaseIterable {
            /// 接続済
            case connected
            /// 接続中
            case connecting
            /// 接続エラー
            case connectionError
            /// 接続失敗
            case connectionRefused
            /// 切断中
            case disconnected
            /// プロトコルエラー
            case protocolError
            /// 不明
            case unknown
        }

        /// MQTT購読メッセージ
        public struct SubscribedMessage {
            /// トピック
            public let topic: String
            /// ペイロード
            public let payload: String

            /// イニシャライザ
            /// - Parameters:
            ///   - topic: トピック
            ///   - data: 受信データ
            init(topic: String, data: Data) {
                self.topic = topic
                self.payload = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
            }
        }

        /// MQTT接続
        public struct ConnectWithSetup {
            /// MQTT接続結果
            public var result: Bool = false
        }

        /// MQTT切断
        public struct DisconnectWithCleanup {
            /// MQTT切断結果
            public var result: Bool = false
        }

        /// Job作成
        public struct CreateJob {
            /// State
            public let state: APITaskEntity.State
            /// ID
            public let id: String?
            /// ARN
            public let arn: String?
        }

        /// Jobドキュメント
        struct JobDocument: Codable {
            /// File URL
            let distFileUrl: String
        }
    }
}
