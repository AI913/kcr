//
//  TaskAPIRepository.swift
//  JobOrder.API
//
//  Created by frontarc on 2020/10/29.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

/// ActionLibrary情報を操作するAPI
/// @mockable
public protocol TaskAPIRepository {
    /// TaskのCommand情報を取得する
    /// - Parameter token: トークン情報
    /// - Parameter taskId: TaskID
    /// - Parameter robotId: RobotID
    func getCommand(_ token: String, taskId: String, robotId: String) -> AnyPublisher<APIResult<CommandEntity.Data>, Error>
    /// Taskのcommand情報を取得する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - taskId: TaskID
    func getCommands(_ token: String, taskId: String) -> AnyPublisher<APIResult<[CommandEntity.Data]>, Error>

    /// Taskの情報を取得する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - taskId: RobotID
    func getTask(_ token: String, taskId: String) -> AnyPublisher<APIResult<TaskAPIEntity.Data>, Error>

    /// Taskの情報を送信する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - data: Task情報
    func postTask(_ token: String, data: JobOrder_API.TaskAPIEntity.Input.Data) -> AnyPublisher<APIResult<TaskAPIEntity.Data>, Error>
}
