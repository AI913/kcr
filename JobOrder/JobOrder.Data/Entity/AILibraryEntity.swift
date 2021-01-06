//
//  AILibraryEntity.swift
//  JobOrder.Data
//
//  Created by Kento Tatsumi on 2020/03/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import RealmSwift

/// AILibraryのエンティティ
public class AILibraryEntity: Object, Codable {

    /// ID
    @objc public dynamic var id: String = ""
    /// 名前
    @objc public dynamic var name: String = ""
    /// タイプ
    @objc public dynamic var type: String = ""
    /// 要求事項
    public var requirements = List<Requirement>()
    /// 画像パス
    @objc public dynamic var imagePath: String?
    /// 概要
    @objc public dynamic var overview: String?
    /// 備考
    @objc public dynamic var remarks: String?
    /// バージョン
    @objc public dynamic var version: Int = 0
    /// 作成日時
    @objc public dynamic var createTime: Int = 0
    /// 作成者
    @objc public dynamic var creator: String = ""
    /// 更新日時
    @objc public dynamic var updateTime: Int = 0
    /// 更新者
    @objc public dynamic var updator: String = ""

    public init(requirements: [Requirement]) {
        self.requirements.append(objectsIn: requirements)
    }

    required override init() {}

    override public static func primaryKey() -> String? {
        return "id"
    }

    static func == (lhs: AILibraryEntity, rhs: AILibraryEntity) -> Bool {
        return lhs.id == rhs.id
    }

    static func === (lhs: AILibraryEntity, rhs: AILibraryEntity) -> Bool {
        
        let isEqualRequirements = lhs.requirements.enumerated().filter { $0.element == rhs.requirements[$0.offset] }.count == rhs.requirements.count

        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.type == rhs.type &&
            isEqualRequirements &&
            lhs.imagePath == rhs.imagePath &&
            lhs.overview == rhs.overview &&
            lhs.remarks == rhs.remarks &&
            lhs.version == rhs.version &&
            lhs.createTime == rhs.createTime &&
            lhs.creator == rhs.creator &&
            lhs.updateTime == rhs.updateTime &&
            lhs.updator == rhs.updator
    }
}
