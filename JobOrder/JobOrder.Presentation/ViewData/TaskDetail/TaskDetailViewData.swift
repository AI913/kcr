//
//  TaskDetailViewData.swift
//  JobOrder.Presentation
//
//  Created by frontarc on 2020/11/30.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//
import Foundation
import UIKit
import JobOrder_Domain

/// TaskDetailViewData
public struct TaskDetailViewData {
    var taskId: String?
    var robotId: String?

    /// 入力フォーム
    public struct Command {
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
    }
}
