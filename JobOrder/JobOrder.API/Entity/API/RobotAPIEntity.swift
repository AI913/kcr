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

    public struct Swconf: Codable {
        public let robotId: String
        public let operatingSystem: OperatingSystem?
        public let softwares: [Software]?
        public let dataVersion: Int
        public let createTime: Int
        public let creator: String
        public let updateTime: Int
        public let updator: String

        enum CodingKeys: String, CodingKey {
            case robotId
            case operatingSystem
            case softwares
            case dataVersion, createTime
            case creator = "createdBy"
            case updateTime
            case updator = "updatedBy"
        }

        static func == (lhs: Swconf, rhs: Swconf) -> Bool {
            let operatingSystem: Bool = { () -> Bool in
                if let lhsOperatingSystem = lhs.operatingSystem, let rhsOperatingSystem = rhs.operatingSystem, lhsOperatingSystem == rhsOperatingSystem {
                    return true
                } else {
                    return false
                }
            }()

            let softwares: Bool = { () -> Bool in
                if let lhsSoftwares = lhs.softwares, let rhsSoftwares = rhs.softwares {
                    return lhsSoftwares.elementsEqual(rhsSoftwares, by: { $0 == $1 })
                } else {
                    return false
                }
            }()

            return lhs.robotId == rhs.robotId &&
                operatingSystem &&
                softwares &&
                lhs.dataVersion == rhs.dataVersion &&
                lhs.createTime == rhs.createTime &&
                lhs.creator == rhs.creator &&
                lhs.updateTime == rhs.updateTime &&
                lhs.updator == rhs.updator
        }

        public struct OperatingSystem: Codable {
            public let system: String
            public let systemVersion: String
            public let distribution: String
            public let distributionVersion: String

            enum CodingKeys: String, CodingKey {
                case system, systemVersion
                case distribution, distributionVersion
            }

            static func == (lhs: OperatingSystem, rhs: OperatingSystem) -> Bool {
                return lhs.system == rhs.system &&
                    lhs.systemVersion == rhs.systemVersion &&
                    lhs.distribution == rhs.distribution &&
                    lhs.distributionVersion == rhs.distributionVersion
            }
        }

        public struct Software: Codable {
            public let swArtifactId: String
            public let softwareId: String
            public let versionId: String
            public let displayName: String?
            public let displayVersion: String?

            enum CodingKeys: String, CodingKey {
                case swArtifactId, softwareId
                case versionId
                case displayName, displayVersion
            }

            static func == (lhs: Software, rhs: Software) -> Bool {
                return lhs.swArtifactId == rhs.swArtifactId &&
                    lhs.softwareId == rhs.softwareId &&
                    lhs.versionId == rhs.versionId &&
                    lhs.displayName == rhs.displayName &&
                    lhs.displayVersion == rhs.displayVersion
            }
        }
    }

    public struct Asset: Codable {
        public let robotId: String
        public let assetId: String
        public let type: String
        public let displayMaker: String?
        public let displayModel: String?
        public let displayModelClass: String?
        public let displaySerial: String?
        public let dataVersion: Int
        public let createTime: Int
        public let creator: String
        public let updateTime: Int
        public let updator: String

        enum CodingKeys: String, CodingKey {
            case robotId, assetId
            case type
            case displayMaker, displayModel, displayModelClass, displaySerial
            case dataVersion, createTime
            case creator = "createdBy"
            case updateTime
            case updator = "updatedBy"
        }

        static func == (lhs: Asset, rhs: Asset) -> Bool {
            return lhs.robotId == rhs.robotId &&
                lhs.assetId == rhs.assetId &&
                lhs.type == rhs.type &&
                lhs.displayMaker == rhs.displayMaker &&
                lhs.displayModel == rhs.displayModel &&
                lhs.displayModelClass == rhs.displayModelClass &&
                lhs.displaySerial == rhs.displaySerial &&
                lhs.dataVersion == rhs.dataVersion &&
                lhs.createTime == rhs.createTime &&
                lhs.creator == rhs.creator &&
                lhs.updateTime == rhs.updateTime &&
                lhs.updator == rhs.updator
        }
    }
}
