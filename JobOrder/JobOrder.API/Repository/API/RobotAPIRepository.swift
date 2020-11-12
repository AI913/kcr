//
//  RobotAPIRepository.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

/// Robot情報を操作するAPI
/// @mockable
public protocol RobotAPIRepository {
    /// Robot情報を取得する
    /// - Parameter token: トークン情報
    func fetch(_ token: String) -> AnyPublisher<APIResult<[RobotAPIEntity.Data]>, Error>
    /// Robot情報を取得する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - id: Robot ID
    func getRobot(_ token: String, id: String) -> AnyPublisher<APIResult<RobotAPIEntity.Data>, Error>
    /// Robot画像を取得する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - id: Robot ID
    func getImage(_ token: String, id: String) -> AnyPublisher<Data, Error>
    /// Robot Commandsを取得する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - id: Robot ID
    func getCommandFromRobot(_ token: String, id: String) -> AnyPublisher<APIResult<[CommandAPIEntity.Data]>, Error>
}
