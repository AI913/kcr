//
//  TaskAPIDataStore.swift
//  JobOrder.API
//
//  Created by frontarc on 2020/10/29.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Utility

/// AILibrary情報を操作するAPI
public class TaskAPIDataStore: TaskAPIRepository {
    /// APIRequestProtocol
    private let api: APIRequestProtocol
    /// エンドポイントURL
    public let url: URL = URL(string: AWSConstants.APIGateway.endPoint)!.appendingPathComponent("v1").appendingPathComponent("tasks")
    /// イニシャライザ
    /// - Parameter api: APIRequestProtocol
    public init(api: APIRequestProtocol) {
        self.api = api
    }

    /// Taskのコマンドを取得する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - taskId: Task ID
    ///   - robotId: RobotID
    /// - Returns: Command情報
    public func getCommand(_ token: String, taskId: String, robotId: String) -> AnyPublisher<APIResult<CommandEntity.Data>, Error> {
        Logger.info(target: self)
        return api.get(resUrl: url, token: token, dataId: "/\(taskId)/commands/\(robotId)", query: nil)
    }

    /// Taskのコマンドを取得する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - taskId: Task ID
    /// - Returns: Command情報
    public func getCommands(_ token: String, taskId: String) -> AnyPublisher<APIResult<[CommandEntity.Data]>, Error> {
        Logger.info(target: self)
        return api.get(resUrl: url, token: token, dataId: "/\(taskId)/commands", query: nil)
    }

    /// Taskの情報を取得する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - taskId: TaskID
    /// - Returns: Task情報
    public func getTask(_ token: String, taskId: String) -> AnyPublisher<APIResult<TaskAPIEntity.Data>, Error> {
        Logger.info(target: self)
        return api.get(resUrl: url, token: token, dataId: "/\(taskId)", query: nil)
    }

    /// Taskの情報を送信する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - data: Task情報
    public func postTask(_ token: String, data: JobOrder_API.TaskAPIEntity.Input.Data) -> AnyPublisher<APIResult<TaskAPIEntity.Data>, Error> {
        Logger.info(target: self)
        return api.post(resUrl: url, token: token, data: data)
    }
}
