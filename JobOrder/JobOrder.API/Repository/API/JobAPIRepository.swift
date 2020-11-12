//
//  JobAPIRepository.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

/// Job情報を操作するAPI
/// @mockable
public protocol JobAPIRepository {
    /// Job情報を取得する
    /// - Parameter token: トークン情報
    func fetch(_ token: String) -> AnyPublisher<APIResult<[JobAPIEntity.Data]>, Error>
    /// 指定したJob情報を取得する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - jobId: Job ID
    func get(_ token: String, jobId: String) -> AnyPublisher<APIResult<JobAPIEntity.Data>, Error>
    /// Job情報を作成する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - data: Job情報
    func post(_ token: String, data: JobAPIEntity.Data) -> AnyPublisher<APIResult<JobAPIEntity.Data>, Error>
    /// 指定したJob情報を更新する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - jobId: Job ID
    ///   - data: Job情報
    func put(_ token: String, jobId: String, data: JobAPIEntity.Data) -> AnyPublisher<APIResult<JobAPIEntity.Data>, Error>
    /// 指定したJob情報を削除する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - jobId: Job ID
    func delete(_ token: String, jobId: String) -> AnyPublisher<APIResult<JobAPIEntity.Data>, Error>
}
