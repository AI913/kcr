//
//  MQTTModel.swift
//  JobOrder.Domain
//
//  Created by Yu Suzuki on 2020/03/31.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import JobOrder_API

/// MQTTモデル
public struct MQTTModel {

    /// Presentationへ出力するためのデータ形式
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

            /// エンティティ -> モデルl変換
            /// - Parameter status: エンティティ
            init(_ status: JobOrder_API.MQTTEntity.Output.ConnectionStatus?) {
                switch status {
                case .connecting: self = .connecting
                case .connected:  self = .connected
                case .disconnected: self = .disconnected
                case .connectionRefused: self = .connectionRefused
                case .connectionError: self = .connectionError
                case .protocolError: self = .protocolError
                default: self = .unknown
                }
            }
        }

        /// MQTT接続
        public struct Connect {
            /// 接続結果
            public let result: Bool
        }

        /// MQTT切断
        public struct Disconnect {
            /// 切断結果
            public let result: Bool
        }

        /// MQTT購読メッセージ
        public struct SubscribedMessage {
            /// トピック
            public let topic: String
            /// ペイロード
            public let payload: String
        }

        /// Job作成状態
        public enum CreateJobState: CaseIterable {
            /// スキップ
            case skipped
            /// 成功
            case completed
            /// キャンセル
            case cancelled
            /// 失敗
            case faulted
            /// 不明
            case unknown

            /// エンティティ -> モデルl変換
            /// - Parameter state: エンティティ
            init(_ state: JobOrder_API.APITaskEntity.State) {
                switch state {
                case .skipped: self = .skipped
                case .completed: self = .completed
                case .cancelled: self = .cancelled
                case .faulted: self = .faulted
                default: self = .unknown
                }
            }
        }
    }

    /// Presentationから入力されるデータ形式
    public struct Input {

        /// Job作成
        public struct CreateJob {
            /// Job ID
            public var jobId: String?
            /// Robot ID
            public var robotIds: [String]?
            /// 稼働開始条件
            public var startCondition: StartCondition?
            /// 稼働終了条件
            public var exitCondition: ExitCondition?
            /// 稼働回数
            public var numberOfRuns: Int?
            /// 備考
            public var remarks: String?

            public init() {}

            /// 開始条件
            public enum StartCondition: String, CaseIterable {
                case immediately
                case unknown

                public init(key: String?) {
                    self = StartCondition.toEnum(key)
                }

                public var key: String {
                    switch self {
                    case .immediately: return "Immediately"
                    case .unknown: return "Unknown"
                    }
                }

                static func toEnum(_ value: String?) -> StartCondition {
                    return StartCondition.allCases.first { $0.key == value } ?? .unknown
                }
            }

            /// 終了条件
            public enum ExitCondition: String, CaseIterable {
                case specifiedNumberOfTimes
                case unknown

                public init(key: String?) {
                    self = ExitCondition.toEnum(key)
                }

                public var key: String {
                    switch self {
                    case .specifiedNumberOfTimes: return "Specified number of times"
                    case .unknown: return "Unknown"
                    }
                }

                static func toEnum(_ value: String?) -> ExitCondition {
                    return ExitCondition.allCases.first { $0.key == value } ?? .unknown
                }
            }
        }
    }
}
