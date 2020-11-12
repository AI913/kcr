//
//  RobotAPIEntity.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/08.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

/// RobotAPIのエンティティ
public struct RobotAPIEntity: Codable {

    /// Robotデータ
    public struct Data: Codable {
        /// ID
        public let id: String
        /// 名前
        public let name: String?
        /// タイプ
        public let type: String
        /// 言語
        public let locale: String
        /// シミュレータかどうか
        public let isSimulator: Bool
        /// メーカー
        public let maker: String?
        /// モデル
        public let model: String?
        /// モデルクラス
        public let modelClass: String?
        /// シリアル番号
        public let serial: String?
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
        /// キー
        public let awsKey: Key?

        enum CodingKeys: String, CodingKey {
            case id = "robotId"
            case name = "displayName"
            case type, locale
            case isSimulator = "simulator"
            case maker = "displayMaker"
            case model = "displayModel"
            case modelClass = "displayModelClass"
            case serial = "displaySerial"
            case overview, remarks
            case version = "dataVersion"
            case createTime
            case creator = "createdBy"
            case updateTime
            case updator = "updatedBy"
            case awsKey
        }

        /// クラウドへアクセスするためのキー
        public struct Key: Codable, Equatable {
            /// Thing名
            public let thingName: String
            /// Thing ARN
            public let thingArn: String

            public static func == (lhs: Key, rhs: Key) -> Bool {
                return lhs.thingName == rhs.thingName &&
                    lhs.thingArn == rhs.thingArn
            }
        }

        static func == (lhs: Data, rhs: Data) -> Bool {
            return lhs.id == rhs.id &&
                lhs.name == rhs.name &&
                lhs.type == rhs.type &&
                lhs.locale == rhs.locale &&
                lhs.isSimulator == rhs.isSimulator &&
                lhs.maker == rhs.maker &&
                lhs.model == rhs.model &&
                lhs.modelClass == rhs.modelClass &&
                lhs.serial == rhs.serial &&
                lhs.overview == rhs.overview &&
                lhs.remarks == rhs.remarks &&
                lhs.version == rhs.version &&
                lhs.createTime == rhs.createTime &&
                lhs.creator == rhs.creator &&
                lhs.updateTime == rhs.updateTime &&
                lhs.updator == rhs.updator &&
                lhs.awsKey == rhs.awsKey
        }
    }
}
