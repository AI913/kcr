//
//  RealmDataStore.swift
//  JobOrder.Data
//
//  Created by Yu Suzuki on 2020/05/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import RealmSwift

/// Realmを操作するプロトコル
/// @mockable
public protocol RealmDataStoreProtocol {
    /// DBへエンティティを追加
    /// - Parameter entities: エンティティ
    func add<T: Object>(entities: [T])
    /// DBからエンティティを読み出し
    /// - Parameter type: エンティティの型
    func read<T: Object>(type: T.Type) -> [T]?
    /// DBに保存してあるデータを更新
    /// - Parameters:
    ///   - type: エンティティの型
    ///   - key: エンティティのキー
    ///   - completion: コールバック
    func update<T: Object>(type: T.Type, key: String, completion: @escaping ((T) -> Void))
    /// DBに保存してあるエンティティを削除
    /// - Parameters:
    ///   - type: エンティティの型
    ///   - key: エンティティのキー
    func delete<T: Object>(type: T.Type, key: String)
    /// DBに保存してあるエンティティを全て削除
    /// - Parameter type: エンティティの型
    func deleteAll<T: Object>(type: T.Type)
    /// DBに保存してあるエンティティの変更を監視
    /// - Parameters:
    ///   - type: エンティティの型
    ///   - completion: コールバック
    func observe<T: Object>(type: T.Type, completion: @escaping (([T]?) -> Void))
}

/// Realmの操作
public class RealmDataStore: RealmDataStoreProtocol {
    /// トークン
    private var token: NotificationToken?

    public init() {}
    deinit { token?.invalidate() }

    /// DBへエンティティを追加
    /// - Parameter entities: エンティティ
    public func add<T: Object>(entities: [T]) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(entities, update: .modified)
        }
    }

    /// DBからエンティティを読み出し
    /// - Parameter type: エンティティの型
    /// - Returns: エンティティ
    public func read<T: Object>(type: T.Type) -> [T]? {
        let realm = try! Realm()
        return realm.objects(T.self).map { $0 }
    }

    /// DBに保存してあるデータを更新
    /// - Parameters:
    ///   - type: エンティティの型
    ///   -  key: エンティティのキー
    ///   - completion: コールバック
    public func update<T: Object>(type: T.Type, key: String, completion: @escaping ((T) -> Void)) {
        guard let results = find(type: type, key: key) else { return }

        let ref = ThreadSafeReference(to: results)
        DispatchQueue(label: "background").async {
            let realm = try! Realm()
            guard let results = realm.resolve(ref),
                  let entity = results.first else {
                return // deleted
            }
            try! realm.write {
                completion(entity)
            }
        }
    }

    /// DBに保存してあるエンティティを削除
    /// - Parameters:
    ///   - type: エンティティの型
    ///   -  key: エンティティのキー
    public func delete<T: Object>(type: T.Type, key: String) {
        guard let results = find(type: type, key: key) else { return }

        let realm = try! Realm()
        try! realm.write {
            realm.delete(results)
        }
    }

    /// DBに保存してあるエンティティを全て削除
    /// - Parameter type: エンティティの型
    public func deleteAll<T: Object>(type: T.Type) {
        guard let object = read(type: T.self) else { return }

        let realm = try! Realm()
        try! realm.write {
            realm.delete(object)
        }
    }

    /// DBに保存してあるエンティティの変更を監視
    /// - Parameter type: エンティティの型
    /// - Returns: エンティティ
    public func observe<T: Object>(type: T.Type, completion: @escaping (([T]?) -> Void)) {
        let realm = try! Realm()
        token = realm.observe { _, realm in
            completion(self.read(type: T.self))
        }
    }

    /// DBに保存してあるエンティティを検索
    /// - Parameters:
    ///   - type: エンティティの型
    ///   -  key: エンティティのキー
    /// - Returns: 検索結果
    private func find<T: Object>(type: T.Type, key: String) -> Results<T>? {
        let realm = try! Realm()
        return realm.objects(T.self).filter("id == %@", key)
    }
}
