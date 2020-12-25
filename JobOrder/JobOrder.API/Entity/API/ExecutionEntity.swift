//
//  ExecutionEntity.swift
//  JobOrder.API
//
//  Created by 藤井一暢 on 2020/12/11.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

public struct ExecutionEntity: Codable {

    public struct LogData: Codable, Equatable {
        public let taskId: String
        public let robotId: String
        public let id: String
        public let executedAt: Int
        public let result: String
        public let sequenceNumber: Int
        // public let context	// TODO: 仕様待ち
        public let receivedExecutionReportAt: Int

        enum CodingKeys: String, CodingKey {
            case taskId
            case robotId
            case id = "executionId"
            case executedAt
            case result
            case sequenceNumber
            case receivedExecutionReportAt
        }

        public static func == (lhs: LogData, rhs: LogData) -> Bool {
            return lhs.taskId == rhs.taskId &&
                lhs.robotId == rhs.robotId &&
                lhs.id == rhs.id &&
                lhs.executedAt == rhs.executedAt &&
                lhs.result == rhs.result &&
                lhs.sequenceNumber == rhs.sequenceNumber &&
                lhs.receivedExecutionReportAt == rhs.receivedExecutionReportAt
        }

    }

}
