//
//  AILibraryRepository.swift
//  JobOrder.Data
//
//  Created by Yu Suzuki on 2020/04/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

/// DBのAILibrary情報を操作する
/// @mockable
public protocol AILibraryRepository {
    /// タイムスタンプ
    var timestamp: Int { get set }
    /// DBへエンティティを追加
    /// - Parameter entities: エンティティ
    func add(entities: [AILibraryEntity])
    /// DBからエンティティを読み出し
    func read() -> [AILibraryEntity]?
    /// DBに保存してあるエンティティを削除
    /// - Parameter entity: エンティティ
    func delete(entity: AILibraryEntity)
    /// DBに保存してあるエンティティを全て削除
    func deleteAll()
    /// DBに保存してあるエンティティの変更を監視
    func observe() -> AnyPublisher<[AILibraryEntity]?, Never>
}
