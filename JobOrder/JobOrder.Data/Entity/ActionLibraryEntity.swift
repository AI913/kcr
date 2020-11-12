//
//  ActionLibraryEntity.swift
//  JobOrder.Data
//
//  Created by Kento Tatsumi on 2020/03/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import RealmSwift

/// ActionLibraryのエンティティ
public class ActionLibraryEntity: Object, Codable {

    /// ID
    @objc public dynamic var id: String = ""
    /// 名前
    @objc public dynamic var name: String = ""
    /// 要求事項
    @objc public dynamic var requirements: String?
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

    override public static func primaryKey() -> String? {
        return "id"
    }

    static func == (lhs: ActionLibraryEntity, rhs: ActionLibraryEntity) -> Bool {
        return lhs.id == rhs.id
    }

    static func === (lhs: ActionLibraryEntity, rhs: ActionLibraryEntity) -> Bool {
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
}
