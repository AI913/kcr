//
//  OrderEntryViewData.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import UIKit
import JobOrder_Domain

/// OrderEntryViewData
struct OrderEntryViewData {

    /// 入力フォーム
    var form: Form

    /// イニシャライザ
    /// - Parameters:
    ///   - jobId: 選択したJob ID
    ///   - robotId: 選択したRobot ID
    init(_ jobId: String?, _ robotId: String?) {
        self.form = Form(jobId, robotId)
    }

    /// モデル -> ViewData変換
    /// - Parameter model: モデル
    init(_ model: JobOrder_Domain.MQTTModel.Input.CreateJob?) {
        self.form = Form(model)
    }

    /// 入力フォーム
    struct Form {
        /// Job ID
        var jobId: String?
        /// Robot IDの配列
        var robotIds: [String]?
        /// 稼働開始条件
        var startCondition: StartCondition?
        /// 稼働完了条件
        var exitCondition: ExitCondition?
        /// 稼働回数
        var numberOfRuns: Int = 0
        /// 備考
        var remarks: String?

        /// イニシャライザ
        /// - Parameters:
        ///   - jobId: 選択したJob ID
        ///   - robotId: 選択したRobot ID
        init(_ jobId: String?, _ robotId: String?) {
            self.jobId = jobId
            self.robotIds = []
            if let robotId = robotId {
                self.robotIds?.append(robotId)
            }
            self.startCondition = .immediately
            self.exitCondition = .specifiedNumberOfTimes
        }

        /// モデル -> ViewData変換
        /// - Parameters:
        ///   - model: モデル
        init(_ model: JobOrder_Domain.MQTTModel.Input.CreateJob?) {
            guard let model = model else { return }
            self.jobId = model.jobId
            self.robotIds = model.robotIds
            self.startCondition = StartCondition(rawValue: model.startCondition?.rawValue ?? "Unknown")
            self.exitCondition = ExitCondition(rawValue: model.exitCondition?.rawValue ?? "Unknown")
            self.numberOfRuns = model.numberOfRuns ?? 1
            self.remarks = model.remarks
        }

        /// 稼働開始条件
        enum StartCondition: String, CaseIterable {
            /// すぐに
            case immediately
            /// 不明
            case unknown

            init(key: String?) {
                self = StartCondition.toEnum(key)
            }

            /// 表示名
            var displayName: String {
                switch self {
                case .immediately: return "immediately"
                case .unknown: return "Unknown"
                }
            }

            static func toEnum(_ value: String?) -> StartCondition {
                return StartCondition.allCases.first { $0.displayName == value } ?? .unknown
            }
        }

        /// 稼働完了条件
        enum ExitCondition: String, CaseIterable {
            /// 指定した回数を実行
            case specifiedNumberOfTimes
            /// 不明
            case unknown

            init(key: String?) {
                self = ExitCondition.toEnum(key)
            }

            /// 表示名
            var displayName: String {
                switch self {
                case .specifiedNumberOfTimes: return "specifiedNumberOfTimes"
                case .unknown: return "Unknown"
                }
            }

            static func toEnum(_ value: String?) -> ExitCondition {
                return ExitCondition.allCases.first { $0.displayName == value } ?? .unknown
            }
        }
    }
}
