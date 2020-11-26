//
//  CommandAPIEntity.swift
//  JobOrder.API
//
//  Created by admin on 2020/11/06.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
public struct CommandEntity: Codable {
    public struct Data: Codable, Equatable {
        public let taskId: String
        public let robotId: String
        public let started: Int?
        public let exited: Int?
        public let execDuration: Int?
        public let receivedStartReort: Int?
        public let receivedExitReort: Int?
        public let status: String
        public let resultInfo: String?
        public let success: Int
        public let fail: Int
        public let error: Int
        public let robot: Robot?
        public let dataVersion: Int
        public let createTime: Int
        public let creator: String
        public let updateTime: Int
        public let updator: String

        public struct Robot: Codable, Equatable {
            public let robotInfo: RobotAPIEntity.Data

            public static func == (lhs: Robot, rhs: Robot) -> Bool {
                return lhs.robotInfo == rhs.robotInfo
            }
        }

        enum CodingKeys: String, CodingKey {
            case taskId, robotId
            case started = "startedAt"
            case exited = "exitedAt"
            case execDuration
            case receivedStartReort = "receivedStartReortAt"
            case receivedExitReort = "receivedExitReortAt"
            case status, resultInfo, success, fail, error, robot, dataVersion, createTime
            case creator = "createdBy"
            case updateTime
            case updator = "updatedBy"
        }

        public static func == (lhs: Data, rhs: Data) -> Bool {
            return lhs.taskId == rhs.taskId &&
                lhs.robotId == rhs.robotId &&
                lhs.started == rhs.started &&
                lhs.exited == rhs.exited &&
                lhs.execDuration == rhs.execDuration &&
                lhs.receivedStartReort == rhs.receivedStartReort &&
                lhs.receivedExitReort == rhs.receivedExitReort &&
                lhs.status == rhs.status &&
                lhs.resultInfo == rhs.resultInfo &&
                lhs.success == rhs.success &&
                lhs.fail == rhs.fail &&
                lhs.error == rhs.error &&
                lhs.robot == rhs.robot &&
                lhs.dataVersion == rhs.dataVersion &&
                lhs.createTime == rhs.createTime &&
                lhs.creator == rhs.creator &&
                lhs.updateTime == rhs.updateTime &&
                lhs.updator == rhs.updator
        }
    }
}
