//
//  RobotRepository.swift
//  JobOrder.Data
//
//  Created by Yu Suzuki on 2020/04/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

/// DBのRobot情報を操作する
/// @mockable
public protocol RobotRepository {
    /// タイムスタンプ
    var timestamp: Int { get set }
    /// DBへエンティティを追加
    /// - Parameter entities: エンティティ
    func add(entities: [RobotEntity])
    /// DBからエンティティを読み出し
    func read() -> [RobotEntity]?
    /// Robotの状態を更新
    /// - Parameters:
    ///   - state: 状態
    ///   - entity: エンティティ
    func update(state: String?, entity: RobotEntity)
    /// DBに保存してあるエンティティを削除
    /// - Parameter entity: エンティティ
    func delete(entity: RobotEntity)
    /// DBに保存してあるエンティティを全て削除
    func deleteAll()
    /// DBに保存してあるエンティティの変更を監視
    func observe() -> AnyPublisher<[RobotEntity]?, Never>
}
