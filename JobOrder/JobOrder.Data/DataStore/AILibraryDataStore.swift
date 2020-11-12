//
//  AILibraryDataStore.swift
//  JobOrder.Data
//
//  Created by Yu Suzuki on 2020/04/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

/// DBのAILibrary情報を操作する
public class AILibraryDataStore: AILibraryRepository {

    /// UserDefaultsRepository
    private let ud: UserDefaultsRepository
    /// RealmDataStoreProtocol
    private let realm: RealmDataStoreProtocol
    /// Publisher
    let publisher = PassthroughSubject<[AILibraryEntity]?, Never>()

    public init(ud: UserDefaultsRepository, realm: RealmDataStoreProtocol) {
        self.ud = ud
        self.realm = realm
    }

    /// タイムスタンプ
    public var timestamp: Int {
        get { return ud.integer(forKey: .aiLibraryTimestamp) }
        set { ud.set(newValue, forKey: .aiLibraryTimestamp) }
    }

    /// DBへエンティティを追加
    /// - Parameter entities: エンティティ
    public func add(entities: [AILibraryEntity]) {
        realm.add(entities: entities)
    }

    /// DBからエンティティを読み出し
    /// - Returns: エンティティ
    public func read() -> [AILibraryEntity]? {
        realm.read(type: AILibraryEntity.self)
    }

    /// DBに保存してあるエンティティを削除
    /// - Parameter entity: エンティティ
    public func delete(entity: AILibraryEntity) {
        realm.delete(type: AILibraryEntity.self, key: entity.id)
    }

    /// DBに保存してあるエンティティを全て削除
    public func deleteAll() {
        timestamp = 0
        realm.deleteAll(type: AILibraryEntity.self)
    }

    /// DBに保存してあるエンティティの変更を監視
    /// - Returns: エンティティ
    public func observe() -> AnyPublisher<[AILibraryEntity]?, Never> {
        realm.observe(type: AILibraryEntity.self) {
            self.publisher.send($0)
        }
        return publisher.eraseToAnyPublisher()
    }
}
