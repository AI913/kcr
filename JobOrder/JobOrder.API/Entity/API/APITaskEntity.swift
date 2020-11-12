//
//  APITaskEntity.swift
//  JobOrder.API
//
//  Created by Yu Suzuki on 2020/05/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

/// APITaskエンティティ
public struct APITaskEntity {

    /// Task状態
    public enum State {
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
    }

    public struct Document: Codable {

        var jobDataId: String?
        var startCondition: String?
        var exitCondition: String?
        var numberOfRuns: Int?

        public init(jobId: String?, startCondition: String?, exitCondition: String?, numberOfRuns: Int?) {
            self.jobDataId = jobId
            self.startCondition = startCondition
            self.exitCondition = exitCondition
            self.numberOfRuns = numberOfRuns
        }

        public enum StartCondition: String, CaseIterable, Codable {
            case immediately
        }

        public enum ExitCondition: String, CaseIterable, Codable {
            case specifiedNumberOfTimes
        }
    }
}
