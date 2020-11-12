//
//  RobotEntity.swift
//  JobOrder.Data
//
//  Created by Kento Tatsumi on 2020/03/07.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import RealmSwift

/// RobotAPIのエンティティ
public class RobotEntity: Object, Codable {

    /// ID
    @objc public dynamic var id: String = ""
    /// 名前
    @objc public dynamic var name: String?
    /// タイプ
    @objc public dynamic var type: String = ""
    /// 言語
    @objc public dynamic var locale: String = "en-US"
    /// シミュレータかどうか
    @objc public dynamic var isSimulator: Bool = false
    /// メーカー
    @objc public dynamic var maker: String?
    /// モデル
    @objc public dynamic var model: String?
    /// モデルクラス
    @objc public dynamic var modelClass: String?
    /// シリアル番号
    @objc public dynamic var serial: String?
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
    /// Thing名
    @objc public dynamic var thingName: String?
    /// ARN
    @objc public dynamic var thingArn: String?
    /// 稼働状態
    @objc public dynamic var state: String?

    override public static func primaryKey() -> String? {
        return "id"
    }

    static func == (lhs: RobotEntity, rhs: RobotEntity) -> Bool {
        return lhs.id == rhs.id
    }

    static func === (lhs: RobotEntity, rhs: RobotEntity) -> Bool {
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
            lhs.thingName == rhs.thingName &&
            lhs.thingArn == rhs.thingArn &&
            lhs.state == rhs.state
    }
}
