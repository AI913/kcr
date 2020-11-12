//
//  ActionLibraryDataStore.swift
//  JobOrder.Data
//
//  Created by Yu Suzuki on 2020/04/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

/// DBのActionLibrary情報を操作する
public class ActionLibraryDataStore: ActionLibraryRepository {

    /// UserDefaultsRepository
    private let ud: UserDefaultsRepository
    /// RealmDataStoreProtocol
    private let realm: RealmDataStoreProtocol
    /// Publisher
    let publisher = PassthroughSubject<[ActionLibraryEntity]?, Never>()

    public init(ud: UserDefaultsRepository, realm: RealmDataStoreProtocol) {
        self.ud = ud
        self.realm = realm
    }

    /// タイムスタンプ
    public var timestamp: Int {
        get { return ud.integer(forKey: .actionLibraryTimestamp) }
        set { ud.set(newValue, forKey: .actionLibraryTimestamp) }
    }

    /// DBへエンティティを追加
    /// - Parameter entities: エンティティ
    public func add(entities: [ActionLibraryEntity]) {
        realm.add(entities: entities)
    }

    /// DBからエンティティを読み出し
    /// - Returns: エンティティ
    public func read() -> [ActionLibraryEntity]? {
        realm.read(type: ActionLibraryEntity.self)
    }

    /// DBに保存してあるエンティティを削除
    /// - Parameter entity: エンティティ
    public func delete(entity: ActionLibraryEntity) {
        realm.delete(type: ActionLibraryEntity.self, key: entity.id)
    }

    /// DBに保存してあるエンティティを全て削除
    public func deleteAll() {
        timestamp = 0
        realm.deleteAll(type: ActionLibraryEntity.self)
    }

    /// DBに保存してあるエンティティの変更を監視
    /// - Returns: エンティティ
    public func observe() -> AnyPublisher<[ActionLibraryEntity]?, Never> {
        realm.observe(type: ActionLibraryEntity.self) {
            self.publisher.send($0)
        }
        return publisher.eraseToAnyPublisher()
    }
}
