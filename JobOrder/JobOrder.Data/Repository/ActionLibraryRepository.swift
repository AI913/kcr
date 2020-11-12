//
//  ActionLibraryRepository.swift
//  JobOrder.Data
//
//  Created by Yu Suzuki on 2020/04/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

/// DBのActionLibrary情報を操作する
/// @mockable
public protocol ActionLibraryRepository {
    /// タイムスタンプ
    var timestamp: Int { get set }
    /// DBへエンティティを追加
    /// - Parameter entities: エンティティ
    func add(entities: [ActionLibraryEntity])
    /// DBからエンティティを読み出し
    func read() -> [ActionLibraryEntity]?
    /// DBに保存してあるエンティティを削除
    /// - Parameter entity: エンティティ
    func delete(entity: ActionLibraryEntity)
    /// DBに保存してあるエンティティを全て削除
    func deleteAll()
    /// DBに保存してあるエンティティの変更を監視
    func observe() -> AnyPublisher<[ActionLibraryEntity]?, Never>
}
