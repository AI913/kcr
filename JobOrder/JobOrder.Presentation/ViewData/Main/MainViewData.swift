//
//  MainViewData.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import UIKit
import JobOrder_Domain

/// MainViewData
struct MainViewData {

    /// 選択したRobot情報
    struct Robot {
        /// Robot ID
        var id: String?

        /// Robot System画面
        let detailSystem: DetailSystem = DetailSystem()

        struct DetailSystem {
            // 表示アイテムのタイトル
            let softwareSystemTitle: String = "System"
            let softwareDistributionTitle: String = "Distribution"
            let softwareInstalledsoftwareTitle: String = "Installed software"
            let hardwareMakerTitle: String = "Maker"
            let hardwareSerialNoTitle: String = "Serial No"
            let accessoryOpened = "-"
            let accessoryClosed = "+"
        }
    }

    /// 選択したJob情報
    struct Job {
        /// Job ID
        var id: String?
    }

    /// 接続情報
    struct ConnectionInfo {
        /// 接続状態
        let status: Status
        /// 表示名
        let displayName: String
        /// アイコンカラー
        let color: UIColor

        /// モデル -> ViewModel変換
        /// - Parameter status: モデル
        init(_ status: JobOrder_Domain.MQTTModel.Output.ConnectionStatus?) {
            self.status = Status(status)
            self.displayName = Details(status).name
            self.color = Details(status).color
        }

        /// 接続状態
        enum Status {
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

            /// モデル -> ViewModel変換
            /// - Parameter status: モデル
            init(_ status: JobOrder_Domain.MQTTModel.Output.ConnectionStatus?) {
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

        /// 詳細情報
        struct Details {
            /// 表示名
            let name: String
            /// アイコンカラー
            let color: UIColor

            /// モデル -> ViewModel変換
            /// - Parameter status: モデル
            init(_ status: JobOrder_Domain.MQTTModel.Output.ConnectionStatus?) {
                switch status {
                case .connected:
                    name = "Connected"
                    color = .link
                case .connecting:
                    name = "Connecting"
                    color = .secondaryLabel
                case .connectionError:
                    name = "Connection error"
                    color = .secondaryLabel
                case .connectionRefused:
                    name = "Connection refused"
                    color = .secondaryLabel
                case .disconnected:
                    name = "Disconnected"
                    color = .secondaryLabel
                case .protocolError:
                    name = "Protocol error"
                    color = .secondaryLabel
                default:
                    name = "Unknown"
                    color = .secondaryLabel
                }
            }
        }
    }

    /// Robotの稼働状態
    enum RobotState {
        /// 不明
        case unknown
        /// 中断中
        case terminated
        /// 停止中
        case stopped
        /// 稼働中
        case starting
        /// 稼働待ち
        case waiting
        /// 処理中
        case processing

        /// モデル -> ViewModel変換
        /// - Parameter status: モデル
        init(_ status: JobOrder_Domain.DataManageModel.Output.Robot.State?) {
            switch status {
            case .terminated: self = .terminated
            case .stopped: self = .stopped
            case .starting: self = .starting
            case .waiting: self = .waiting
            case .processing: self = .processing
            default: self = .unknown
            }
        }
        /// Robotの稼働状態名
        var displayName: String {
            switch self {
            case .unknown: return "Unknown"
            case .terminated: return "Terminated"
            case .stopped: return "Stopped"
            case .starting: return "Starting"
            case .waiting: return "Waiting"
            case .processing: return "Processing"
            }
        }

        /// Robotの稼働状態アイコン名
        var iconSystemName: String {
            switch self {
            case .unknown: return "questionmark.circle.fill"
            case .terminated: return "stop.circle.fill"
            case .stopped: return "exclamationmark.triangle.fill"
            case .starting: return "pause.circle.fill"
            case .waiting: return "pause.circle.fill"
            case .processing: return "play.circle.fill"
            }
        }

        /// Robotの稼働状態カラー
        var color: UIColor {
            switch self {
            case .unknown: return .systemGray
            case .terminated: return .systemGray2
            case .stopped: return .systemRed
            case .starting: return .systemYellow
            case .waiting: return .systemTeal
            case .processing: return .systemIndigo
            }
        }

        /// ソート番号
        var sortOrder: Int {
            switch self {
            case .unknown: return 9
            case .terminated: return 5
            case .stopped: return 4
            case .starting: return 3
            case .waiting: return 2
            case .processing: return 1
            }
        }
    }

    /// 実行Task情報
    struct TaskExecution {

        /// 実行状態
        enum Status: CaseIterable {
            /// キャンセル
            case canceled
            /// 失敗
            case failed
            /// 進行中
            case inProgress
            /// 実行待ち
            case queued
            /// 拒否
            case rejected
            /// 削除
            case removed
            /// 成功
            case succeeded
            /// タイムアウト
            case timedOut
            /// 不明
            case unknown

            /// モデル -> ViewModel変換
            /// - Parameter status: モデル
            init(_ key: String) {
                self = Status.toEnum(key)
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(self.key)
            }

            var key: String {
                switch self {
                case .canceled: return "canceled"
                case .failed: return "failed"
                case .inProgress: return "inProgress"
                case .queued: return "queued"
                case .rejected: return "rejected"
                case .removed: return "removed"
                case .succeeded: return "succeeded"
                case .timedOut: return "timedOut"
                case .unknown: return "unknown"
                }
            }

            public static func toEnum(_ value: String?) -> Status {
                return Status.allCases.first { $0.key == value } ?? .unknown
            }

            /// 表示画像
            var imageName: UIImage {
                switch self {
                case .canceled: return UIImage(systemName: "xmark.circle.fill")!
                case .failed: return UIImage(systemName: "exclamationmark.circle.fill")!
                case .inProgress: return UIImage(systemName: "play.circle.fill")!
                case .queued: return UIImage(systemName: "pause.circle.fill")!
                case .rejected: return UIImage(systemName: "xmark.circle.fill")!
                case .removed: return UIImage(systemName: "trash.circle.fill")!
                case .succeeded: return UIImage(systemName: "checkmark.circle.fill")!
                case .timedOut: return UIImage(systemName: "exclamationmark.triangle.fill")!
                case .unknown: return UIImage(systemName: "questionmark.circle.fill")!
                }
            }

            /// 表示画像カラー
            var imageColor: UIColor {
                switch self {
                case .canceled: return .systemYellow
                case .failed: return .systemRed
                case .inProgress: return .systemBlue
                case .queued: return .secondaryLabel
                case .rejected: return .systemOrange
                case .removed: return .systemYellow
                case .succeeded: return .systemGreen
                case .timedOut: return .systemOrange
                case .unknown: return .secondaryLabel
                }
            }
        }
    }
}
