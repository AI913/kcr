//
//  AILibraryAPIDataStore.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Utility

/// AILibrary情報を操作するAPI
public class AILibraryAPIDataStore: AILibraryAPIRepository {

    /// APIRequestProtocol
    private let api: APIRequestProtocol
    /// エンドポイントURL
    // public let url: URL = URL(string: AWSConstants.APIGateway.endPoint)!.appendingPathComponent("ai-libs")
    public let url: URL = URL(string: AWSConstants.APIGateway.endPoint)!.appendingPathComponent("v1").appendingPathComponent("ai-libs")

    /// イニシャライザ
    /// - Parameter api: APIRequestProtocol
    public init(api: APIRequestProtocol) {
        self.api = api
    }

    /// AILibrary情報を取得する
    /// - Parameter token: トークン情報
    /// - Returns: AILibrary情報
    public func fetch(_ token: String) -> AnyPublisher<APIResult<[AILibraryAPIEntity.Data]>, Error> {
        Logger.info(target: self)
        return api.get(url: url, token: token)
    }
}
