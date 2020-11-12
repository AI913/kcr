//
//  TaskAPIEntity.swift
//  JobOrder.API
//
//  Created by admin on 2020/11/06.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
public struct TaskAPIEntity: Codable {
    public struct Data: Codable {
        public let command: CommandAPIEntity.Data
    }

    public struct Tasks: Codable {
        public let jobId: String
        public let exit: Exit

        public static func == (lhs: Tasks, rhs: Tasks) -> Bool {
            return lhs.jobId == rhs.jobId &&
                lhs.exit == rhs.exit
        }

        public struct Exit: Codable {
            public let option: Option

            public static func == (lhs: Exit, rhs: Exit) -> Bool {
                return lhs.option == rhs.option
            }

            public struct Option: Codable {
                public let numberOfRuns: Int

                public static func == (lhs: Option, rhs: Option) -> Bool {
                    return lhs.numberOfRuns == rhs.numberOfRuns
                }
            }
        }
    }
}
