//
//  JobDataStore.swift
//  JobOrder.Data
//
//  Created by Yu Suzuki on 2020/04/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

/// DBのJob情報を操作する
public class JobDataStore: JobRepository {

    /// UserDefaultsRepository
    private let ud: UserDefaultsRepository
    /// RealmDataStoreProtocol
    private let realm: RealmDataStoreProtocol
    /// Publisher
    let publisher = PassthroughSubject<[JobEntity]?, Never>()

    public init(ud: UserDefaultsRepository, realm: RealmDataStoreProtocol) {
        self.ud = ud
        self.realm = realm
    }

    /// タイムスタンプ
    public var timestamp: Int {
        get { return ud.integer(forKey: .jobTimestamp) }
        set { ud.set(newValue, forKey: .jobTimestamp) }
    }

    /// DBへエンティティを追加
    /// - Parameter entities: エンティティ
    public func add(entities: [JobEntity]) {
        realm.add(entities: entities)
    }

    /// DBからエンティティを読み出し
    /// - Returns: エンティティ
    public func read() -> [JobEntity]? {
        realm.read(type: JobEntity.self)
    }

    /// DBに保存してあるエンティティを削除
    /// - Parameter entity: エンティティ
    public func delete(entity: JobEntity) {
        realm.delete(type: JobEntity.self, key: entity.id)
    }

    /// DBに保存してあるエンティティを全て削除
    public func deleteAll() {
        timestamp = 0
        realm.deleteAll(type: JobEntity.self)
    }

    /// DBに保存してあるエンティティの変更を監視
    /// - Returns: エンティティ
    public func observe() -> AnyPublisher<[JobEntity]?, Never> {
        realm.observe(type: JobEntity.self) {
            self.publisher.send($0)
        }
        return publisher.eraseToAnyPublisher()
    }
}
