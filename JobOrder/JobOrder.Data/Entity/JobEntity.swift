//
//  JobEntity.swift
//  JobOrder.Data
//
//  Created by Kento Tatsumi on 2020/03/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import RealmSwift
/// Jobのエンティティ
public class JobEntity: Object, Codable {

    /// ID
    @objc public dynamic var id: String = ""
    /// 名前
    @objc public dynamic var name: String = ""
    /// アクション
    public var actions = List<JobAction>()
    /// エントリーポイント
    @objc public dynamic var entryPoint: Int = 0
    /// 概要
    @objc public dynamic var overview: String?
    /// 備考
    @objc public dynamic var remarks: String?
    /// 要求事項
    public var requirements = List<JobRequirement>()
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

    public init(actions: [JobAction]) {
        self.actions.append(objectsIn: actions)
    }

    public init(requirements: [JobRequirement]) {
        self.requirements.append(objectsIn: requirements)
    }

    required override init() {}

    override public static func primaryKey() -> String? {
        return "id"
    }

    static func == (lhs: JobEntity, rhs: JobEntity) -> Bool {
        return lhs.id == rhs.id
    }

    static func === (lhs: JobEntity, rhs: JobEntity) -> Bool {
        let isEqualActions = lhs.actions.enumerated().filter { $0.element == rhs.actions[$0.offset] }.count == rhs.actions.count

        let isEqualRequirements = lhs.requirements.enumerated().filter { $0.element == rhs.requirements[$0.offset] }.count == rhs.requirements.count

        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.entryPoint == rhs.entryPoint &&
            isEqualActions &&
            lhs.overview == rhs.overview &&
            lhs.remarks == rhs.remarks &&
            isEqualRequirements &&
            lhs.version == rhs.version &&
            lhs.createTime == rhs.createTime &&
            lhs.creator == rhs.creator &&
            lhs.updateTime == rhs.updateTime &&
            lhs.updator == rhs.updator
    }
}

public class JobAction: Object, Codable {
    /// インデックス
    @objc public dynamic var index: Int = 0
    /// ID
    @objc public dynamic var id: String = ""
    /// パラメータ
    // @objc public dynamic var parameter: JobParameter?
    /// catch
    @objc public dynamic var _catch: String?
    /// then
    @objc public dynamic var then: String?

    public static func == (lhs: JobAction, rhs: JobAction) -> Bool {
        return lhs.index == rhs.index &&
            lhs.id == rhs.id &&
            // lhs.parameter == rhs.parameter &&
            lhs._catch == rhs._catch &&
            lhs.then == rhs.then
    }
}

public class JobRequirement: Object, Codable {
    /// ID
    @objc public dynamic var id: String = ""

    public static func == (lhs: JobRequirement, rhs: JobRequirement) -> Bool {
        return lhs.id == rhs.id
    }
}

// TODO: Realmでエラーが出るので中身が決まるまでコメントアウト
//public class JobParameter: Object, Codable {
//
//    public static func == (lhs: JobParameter, rhs: JobParameter) -> Bool {
//        return true
//    }
//}
