//
//  ActionLibraryAPIEntity.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

/// ActionLibraryAPIのエンティティ
public struct ActionLibraryAPIEntity: Codable {

    /// ActionLibraryのデータ
    public struct Data: Codable {
        /// ID
        public let id: String
        /// 名前
        public let name: String
        /// 要求事項
        public let requirements: [Requirement]
        /// 画像パス
        public let imagePath: String?
        /// 概要
        public let overview: String?
        /// 備考
        public let remarks: String?
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
            case id = "actionLibraryId"
            case name = "displayName"
            case requirements, imagePath, overview, remarks
            case version = "dataVersion"
            case createTime
            case creator = "createdBy"
            case updateTime
            case updator = "updatedBy"
        }

        static func == (lhs: Data, rhs: Data) -> Bool {
            return lhs.id == rhs.id &&
                lhs.name == rhs.name &&
                lhs.requirements == rhs.requirements &&
                lhs.imagePath == rhs.imagePath &&
                lhs.overview == rhs.overview &&
                lhs.remarks == rhs.remarks &&
                lhs.version == rhs.version &&
                lhs.createTime == rhs.createTime &&
                lhs.creator == rhs.creator &&
                lhs.updateTime == rhs.updateTime &&
                lhs.updator == rhs.updator
        }
        
        public struct Requirement: Codable, Equatable {}
        public struct Parameter: Codable, Equatable {
            
            public static func == (lhs: Parameter, rhs: Parameter) -> Bool {
                return true
            }
            
//                public let aiLibraryId: Int
//                public let aiLibraryObjectId: Int
        }

    }
}
