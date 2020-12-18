//
//  TaskAPIEntity.swift
//  JobOrder.API
//
//  Created by admin on 2020/11/06.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

public struct TaskAPIEntity: Codable {

    public struct Data: Codable, Equatable {
        public let id: String
        public let jobId: String
        public let robotIds: [String]
        public let start: Start
        public let exit: Exit
        public let job: JobAPIEntity.Data
        public let version: Int?
        /// 作成日時
        public let createTime: Int
        /// 作成者
        public let creator: String
        /// 更新日時
        public let updateTime: Int
        /// 更新者
        public let updator: String

        enum CodingKeys: String, CodingKey {
            case id = "taskId"
            case jobId
            case robotIds
            case start
            case exit
            case job
            case version = "dataVersion"
            case createTime, creator = "createdBy"
            case updateTime, updator = "updatedBy"
        }

        public static func == (lhs: Data, rhs: Data) -> Bool {
            return lhs.id == rhs.id &&
                lhs.jobId == rhs.jobId &&
                lhs.robotIds == rhs.robotIds &&
                lhs.start == rhs.start &&
                lhs.exit == rhs.exit &&
                lhs.job == rhs.job &&
                lhs.version == rhs.version &&
                lhs.createTime == rhs.createTime &&
                lhs.creator == rhs.creator &&
                lhs.updateTime == rhs.updateTime &&
                lhs.updator == rhs.updator
        }

        public struct Start: Codable, Equatable {
            public let condition: String
            // FIXME: option仕様待ち

            enum CodingKeys: String, CodingKey {
                case condition
            }

            public static func == (lhs: Start, rhs: Start) -> Bool {
                return lhs.condition == rhs.condition
            }
        }

        public struct Exit: Codable, Equatable {
            public let condition: String
            public let option: Option

            enum CodingKeys: String, CodingKey {
                case condition
                case option
            }

            public static func == (lhs: Exit, rhs: Exit) -> Bool {
                return lhs.condition == rhs.condition &&
                    lhs.option == rhs.option
            }

            public struct Option: Codable, Equatable {
                public let numberOfRuns: Int

                enum CodingKeys: String, CodingKey {
                    case numberOfRuns
                }

                public static func == (lhs: Option, rhs: Option) -> Bool {
                    return lhs.numberOfRuns == rhs.numberOfRuns
                }
            }
        }
    }

    public struct Input: Codable {
        public struct Data: Codable {
            public let jobId: String
            public let robotIds: [String]
            public let start: Start
            public let exit: Exit

            public init(jobId: String, robotIds: [String], start: String, exit: String, numberOfRuns: String) {
                self.jobId = jobId
                self.robotIds = robotIds
                self.start = Start(condition: start, option: Start.Option())
                self.exit = Exit(condition: exit, option: Exit.Option(numberOfRuns: Int(numberOfRuns)!))
            }

            enum CodingKeys: String, CodingKey {
                case jobId
                case robotIds
                case start
                case exit
            }

            public struct Start: Codable, Equatable {
                public let condition: String
                public let option: Option
                // FIXME: option仕様待ち

                enum CodingKeys: String, CodingKey {
                    case condition
                    case option
                }

                public static func == (lhs: Start, rhs: Start) -> Bool {
                    return lhs.condition == rhs.condition
                }

                public struct Option: Codable, Equatable {
                    //                    public let numberOfRuns: Int
                    //
                    //                    enum CodingKeys: String, CodingKey {
                    //                        case numberOfRuns
                    //                    }
                    //
                    //                    public static func == (lhs: Option, rhs: Option) -> Bool {
                    //                        return lhs.numberOfRuns == rhs.numberOfRuns
                    //                    }
                }
            }

            public struct Exit: Codable, Equatable {
                public let condition: String
                public let option: Option

                enum CodingKeys: String, CodingKey {
                    case condition
                    case option
                }

                public static func == (lhs: Exit, rhs: Exit) -> Bool {
                    return lhs.condition == rhs.condition &&
                        lhs.option == rhs.option
                }

                public struct Option: Codable, Equatable {
                    public let numberOfRuns: Int

                    enum CodingKeys: String, CodingKey {
                        case numberOfRuns
                    }

                    public static func == (lhs: Option, rhs: Option) -> Bool {
                        return lhs.numberOfRuns == rhs.numberOfRuns
                    }
                }
            }
        }
    }
}
