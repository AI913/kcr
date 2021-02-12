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

    /// Job登録
    public struct Input: Codable {
        /// アプリからサーバへジョブの登録リクエストをする際に用いられる、登録するジョブ情報のモデル。
        public struct Data: Codable {
            public init(name: String, actions: [JobAPIEntity.Input.Data.Action], entryPoint: Int, overview: String?, remarks: String?, requirements: [JobAPIEntity.Input.Data.Requirement]?) {
                self.name = name
                self.actions = actions
                self.entryPoint = entryPoint
                self.overview = overview
                self.remarks = remarks
                self.requirements = requirements
            }

            /// 表示名称
            public let name: String
            /// アクション情報
            public let actions: [Action]
            /// エントリポイント
            public let entryPoint: Int
            /// 概要
            public let overview: String?
            /// 備考
            public let remarks: String?
            /// 実行要件
            public let requirements: [Requirement]?

            enum CodingKeys: String, CodingKey {
                case name = "displayName"
                case actions, entryPoint, overview, remarks, requirements
            }

            /// 該当ジョブのアクション情報
            public struct Action: Codable {
                public init(index: Int, actionLibraryId: String, parameter: JobAPIEntity.Input.Data.Action.Parameter?, catch: String?, then: String?) {
                    self.index = index
                    self.actionLibraryId = actionLibraryId
                    self.parameter = parameter
                    self.catch = `catch`
                    self.then = then
                }

                /// インデックス
                public let index: Int
                /// アクションライブラリ識別子(UUID)
                public let actionLibraryId: String
                /// 該当アクションで用いるアクションライブラリの識別子
                public let parameter: Parameter?
                /// 後続処理情報群（失敗）
                public let `catch`: String?
                /// 後続処理情報群（成功）
                public let `then`: String?

                /// アクションで実行時引数となるパラメータオブジェクト情報
                public struct Parameter: Codable {
                    public init(aiLibraryId: String?, aiLibraryObjectId: String?) {
                        self.aiLibraryId = aiLibraryId
                        self.aiLibraryObjectId = aiLibraryObjectId
                    }

                    /// AIライブラリ識別子(UUID)
                    public let aiLibraryId: String?
                    /// AIライブラリ分類識別子
                    public let aiLibraryObjectId: String?

                    enum CodingKeys: String, CodingKey {
                        case aiLibraryId, aiLibraryObjectId
                    }
                }

                enum CodingKeys: String, CodingKey {
                    case index, actionLibraryId, parameter, `catch`, `then`
                }
            }

            /// 実行要件
            public struct Requirement: Codable {
                public init(type: String, subtype: String, id: String?, versionId: String?) {
                    self.type = type
                    self.subtype = subtype
                    self.id = id
                    self.versionId = versionId
                }

                public let type: String
                public let subtype: String
                public let id: String?
                public let versionId: String?

                enum CodingKeys: String, CodingKey {
                    case type, subtype, id, versionId
                }
            }
        }
    }

    /// Jobデータ
    public struct Data: Codable, Equatable {
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

        public static func == (lhs: Data, rhs: Data) -> Bool {
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
            }
        }
    }
}
