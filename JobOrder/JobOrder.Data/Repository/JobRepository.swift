//
//  JobRepository.swift
//  JobOrder.Data
//
//  Created by Yu Suzuki on 2020/04/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

/// DBのJob情報を操作する
/// @mockable
public protocol JobRepository {
    /// タイムスタンプ
    var timestamp: Int { get set }
    /// DBへエンティティを追加
    /// - Parameter entities: エンティティ
    func add(entities: [JobEntity])
    /// DBからエンティティを読み出し
    func read() -> [JobEntity]?
    /// DBに保存してあるエンティティを削除
    /// - Parameter entity: エンティティ
    func delete(entity: JobEntity)
    /// DBに保存してあるエンティティを全て削除
    func deleteAll()
    /// DBに保存してあるエンティティの変更を監視
    func observe() -> AnyPublisher<[JobEntity]?, Never>
}
