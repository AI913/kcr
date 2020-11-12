//
//  RobotDataStore.swift
//  JobOrder.Data
//
//  Created by Yu Suzuki on 2020/04/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

/// DBのRobot情報を操作する
public class RobotDataStore: RobotRepository {

    /// UserDefaultsRepository
    private let ud: UserDefaultsRepository
    /// RealmDataStoreProtocol
    private let realm: RealmDataStoreProtocol
    /// Publisher
    let publisher = PassthroughSubject<[RobotEntity]?, Never>()

    public init(ud: UserDefaultsRepository, realm: RealmDataStoreProtocol) {
        self.ud = ud
        self.realm = realm
    }

    /// タイムスタンプ
    public var timestamp: Int {
        get { return ud.integer(forKey: .robotTimestamp) }
        set { ud.set(newValue, forKey: .robotTimestamp) }
    }

    /// DBへエンティティを追加
    /// - Parameter entities: エンティティ
    public func add(entities: [RobotEntity]) {
        realm.add(entities: entities)
    }

    /// DBからエンティティを読み出し
    /// - Returns: エンティティ
    public func read() -> [RobotEntity]? {
        realm.read(type: RobotEntity.self)
    }

    /// Robotの状態を更新
    /// - Parameters:
    ///   - state: 状態
    ///   - entity: エンティティ
    public func update(state: String?, entity: RobotEntity) {
        realm.update(type: RobotEntity.self, key: entity.id) {
            $0.state = state
        }
    }

    /// DBに保存してあるエンティティを削除
    /// - Parameter entity: エンティティ
    public func delete(entity: RobotEntity) {
        realm.delete(type: RobotEntity.self, key: entity.id)
    }

    /// DBに保存してあるエンティティを全て削除
    public func deleteAll() {
        timestamp = 0
        realm.deleteAll(type: RobotEntity.self)
    }

    /// DBに保存してあるエンティティの変更を監視
    /// - Returns: エンティティ
    public func observe() -> AnyPublisher<[RobotEntity]?, Never> {
        realm.observe(type: RobotEntity.self) {
            self.publisher.send($0)
        }
        return publisher.eraseToAnyPublisher()
    }
}
