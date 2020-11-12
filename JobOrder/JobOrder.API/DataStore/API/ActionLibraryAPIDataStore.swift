//
//  ActionLibraryAPIDataStore.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Utility

/// ActionLibrary情報を操作するAPI
public class ActionLibraryAPIDataStore: ActionLibraryAPIRepository {

    /// APIRequestProtocol
    private let api: APIRequestProtocol
    /// エンドポイントURL
    // public let url: URL = URL(string: AWSConstants.APIGateway.endPoint)!.appendingPathComponent("action-libs")
    public let url: URL = URL(string: AWSConstants.APIGateway.endPoint)!.appendingPathComponent("v1").appendingPathComponent("action-libs")

    /// イニシャライザ
    /// - Parameter api: APIRequestProtocol
    public init(api: APIRequestProtocol) {
        self.api = api
    }

    /// ActionLibrary情報を取得する
    /// - Parameter token: トークン情報
    /// - Returns: ActionLibrary情報
    public func fetch(_ token: String) -> AnyPublisher<APIResult<[ActionLibraryAPIEntity.Data]>, Error> {
        Logger.info(target: self)
        return api.get(url: url, token: token)
    }
}
