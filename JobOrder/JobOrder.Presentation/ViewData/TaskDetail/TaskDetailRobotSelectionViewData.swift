//
//  TaskDetailRobotSelectionViewData.swift
//  JobOrder.Presentation
//
//  Created by frontarc on 2020/11/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//
import Foundation
import UIKit
import JobOrder_Domain

/// TaskDetailRobotSelectionViewData
public struct TaskDetailRobotSelectionViewData {

    var command: Command
    /// イニシャライザ
    /// - Parameters:
    ///   - taskId: 選択したTask ID
    init(_ taskId: String?) {
        self.command = Command(taskId)
    }

    /// 入力フォーム
    public struct Command {
        var taskId: String?
        var robotId: String?
        var startedAt: Int?
        var exitedAt: Int?
        var execDuration: Int?
        var receivedStartReportAt: Int?
        var receivedExitReportAt: Int?
        var status: Status
        var resultInfo: String?
        var success: Int?
        var fail: Int?
        var error: Int?

        /// イニシャライザ
        /// - Parameters:
        ///   - taskId: 選択したTask ID
        init(_ taskId: String?) {
            self.taskId = taskId
            self.robotId = "3fa85f64-5717-4562-b3fc-2c963f66afa6"
            self.startedAt = 0
            self.exitedAt = 0
            self.execDuration = 0
            self.receivedStartReportAt = 0
            self.receivedExitReportAt = 0
            self.status = Status.unknown
            self.resultInfo = "string"
            self.success = 0
            self.fail = 0
            self.error = 0
        }

        /// 接続状態
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

        /// モデル -> ViewData変換
        /// - Parameters:
        ///   - model: モデル
        //        init(_ model: JobOrder_Domain.MQTTModel.Input.CreateJob?) {
        //            guard let model = model else { return }
        //            self.taskId = model.taskId
        //            self.robotIds = model.robotIds
        //            self.startCondition = StartCondition(rawValue: model.startCondition?.rawValue ?? "Unknown")
        //            self.exitCondition = ExitCondition(rawValue: model.exitCondition?.rawValue ?? "Unknown")
        //            self.numberOfRuns = model.numberOfRuns ?? 1
        //            self.remarks = model.remarks
        //        }

        /// 稼働開始条件
        //        enum StartCondition: String, CaseIterable {
        //            /// すぐに
        //            case immediately
        //            /// 不明
        //            case unknown
        //
        //            init(key: String?) {
        //                self = StartCondition.toEnum(key)
        //            }
        //
        //            /// 表示名
        //            var displayName: String {
        //                switch self {
        //                case .immediately: return "Immediately"
        //                case .unknown: return "Unknown"
        //                }
        //            }
        //
        //            static func toEnum(_ value: String?) -> StartCondition {
        //                return StartCondition.allCases.first { $0.displayName == value } ?? .unknown
        //            }
        //        }
        //
        //        /// 稼働完了条件
        //        enum ExitCondition: String, CaseIterable {
        //            /// 指定した回数を実行
        //            case specifiedNumberOfTimes
        //            /// 不明
        //            case unknown
        //
        //            init(key: String?) {
        //                self = ExitCondition.toEnum(key)
        //            }
        //
        //            /// 表示名
        //            var displayName: String {
        //                switch self {
        //                case .specifiedNumberOfTimes: return "Specified number of times"
        //                case .unknown: return "Unknown"
        //                }
        //            }
        //
        //            static func toEnum(_ value: String?) -> ExitCondition {
        //                return ExitCondition.allCases.first { $0.displayName == value } ?? .unknown
        //            }
        //        }
    }
}
