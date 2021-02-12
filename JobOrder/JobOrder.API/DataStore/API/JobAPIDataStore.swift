//
//  JobAPIDataStore.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Utility

/// Job情報を操作するAPI
public class JobAPIDataStore: JobAPIRepository {

    /// APIRequestProtocol
    private let api: APIRequestProtocol
    /// エンドポイントURL
    // public let url: URL = URL(string: AWSConstants.APIGateway.endPoint)!.appendingPathComponent("jobs")
    public let url: URL = URL(string: AWSConstants.APIGateway.endPoint)!.appendingPathComponent("v1").appendingPathComponent("jobs")

    /// イニシャライザ
    /// - Parameter api: APIRequestProtocol
    public init(api: APIRequestProtocol) {
        self.api = api
    }

    /// Job情報を取得する
    /// - Parameter token: トークン情報
    /// - Returns: Job情報
    public func fetch(_ token: String) -> AnyPublisher<APIResult<[JobAPIEntity.Data]>, Error> {
        Logger.info(target: self)
        return api.get(url: url, token: token, query: nil)
    }

    /// 指定したJob情報を取得する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - jobId: Job ID
    /// - Returns: Job情報
    public func get(_ token: String, jobId: String) -> AnyPublisher<APIResult<JobAPIEntity.Data>, Error> {
        Logger.info(target: self)
        return api.get(resUrl: url, token: token, dataId: jobId, query: nil)
    }

    /// Job情報を作成する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - data: Job情報
    /// - Returns: Job情報
    public func post(_ token: String, data: JobAPIEntity.Input.Data) -> AnyPublisher<APIResult<JobAPIEntity.Data>, Error> {
        Logger.info(target: self)
        return api.post(resUrl: url, token: token, data: data)
    }

    /// 指定したJob情報を更新する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - jobId: Job ID
    ///   - data: Job情報
    /// - Returns: Job情報
    public func put(_ token: String, jobId: String, data: JobAPIEntity.Data) -> AnyPublisher<APIResult<JobAPIEntity.Data>, Error> {
        Logger.info(target: self)
        return api.put(resUrl: url, token: token, dataId: jobId, data: data)
    }

    /// 指定したJob情報を削除する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - jobId: Job ID
    /// - Returns: Job情報
    public func delete(_ token: String, jobId: String) -> AnyPublisher<APIResult<JobAPIEntity.Data>, Error> {
        Logger.info(target: self)
        return api.delete(resUrl: url, token: token, dataId: jobId)
    }

    /// Taskを取得する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - id: Job ID
    public func getTasks(_ token: String, id: String, paging: APIPaging.Input?) -> AnyPublisher<APIResult<[TaskAPIEntity.Data]>, Error> {
        Logger.info(target: self)
        let query = QueryBuilder()
            .add(paging: paging)
            .build()
        return api.get(resUrl: url, token: token, dataId: "\(id)/tasks", query: query)
    }
}
