//
//  JobAPIEntity.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

/// JobAPIのエンティティ
public struct JobAPIEntity: Codable {
    
    /// Jobデータ
    public struct Data: Codable {
        /// ID
        public let id: String
        /// 名前
        public let name: String
        /// アクション
        public let actions: [Action]
        /// エントリーポイント
        public let entryPoint: Int
        /// 概要
        public let overview: String?
        /// 備考
        public let remarks: String?
        /// 要求事項
        public let requirements: [Requirement]?
        /// バージョン
        public let version: Int
        /// 作成日時
        public let createTime: Int
        /// 作成者
        public let creator: String
        /// 更新日時
        public let updateTime: Int
        /// 更新者
        public let updator: String
        
        enum CodingKeys: String, CodingKey {
            case id = "jobId"
            case name = "displayName"
            case actions, entryPoint, overview, remarks, requirements
            case version = "dataVersion"
            case createTime
            case creator = "createdBy"
            case updateTime
            case updator = "updatedBy"
        }
        
        static func == (lhs: Data, rhs: Data) -> Bool {
            return lhs.id == rhs.id &&
                lhs.name == rhs.name &&
                lhs.actions == rhs.actions &&
                lhs.entryPoint == rhs.entryPoint &&
                lhs.overview == rhs.overview &&
                lhs.remarks == rhs.remarks &&
                lhs.requirements == rhs.requirements &&
                lhs.version == rhs.version &&
                lhs.createTime == rhs.createTime &&
                lhs.creator == rhs.creator &&
                lhs.updateTime == rhs.updateTime &&
                lhs.updator == rhs.updator
        }
        
        public struct Requirement: Codable, Equatable {}
        
        /// Jobで実行できるActionLibrary情報
        public struct Action: Codable, Equatable {
            /// インデックス
            public let index: Int
            /// ID
            public let id: String
            /// パラメータ
            public let parameter: Parameter?
            /// catch
            public let _catch: String?
            /// then
            public let then: String?
            
            enum CodingKeys: String, CodingKey {
                case index
                case id = "actionLibraryId"
                case parameter
                case _catch = "catch"
                case then
            }
            
            public static func == (lhs: Action, rhs: Action) -> Bool {
                return lhs.index == rhs.index &&
                    lhs.id == rhs.id &&
                    lhs.parameter == rhs.parameter &&
                    lhs._catch == rhs._catch &&
                    lhs.then == rhs.then
            }
            
            public struct Parameter: Codable, Equatable {
                
                public static func == (lhs: Parameter, rhs: Parameter) -> Bool {
                    return true
                }
                
//                public let aiLibraryId: Int
//                public let aiLibraryObjectId: Int
            }
        }
    }
}
