//
//  PublicAPIDataStore.swift
//  JobOrder.API
//
//  Created by Yu Suzuki on 2021/01/26.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Utility

/// サインイン不要なAPI
public class PublicAPIDataStore: PublicAPIRepository {

    /// APIRequestProtocol
    private let api: APIRequestProtocol
    /// エンドポイントURL
    public let url: URL = URL(string: "test")!

    /// イニシャライザ
    /// - Parameter api: APIRequestProtocol
    public init(api: APIRequestProtocol) {
        self.api = api
    }

    /// サーバーの Configuration を取得する
    /// - Parameter name: テナント名
    /// - Returns: Configuratoin データ
    public func getServerConfiguration(name: String) -> AnyPublisher<Data, Error> {
        Logger.info(target: self)
        // TODO: API が決まったら差し替える
        if name == "test" {
            return api.get(url: url, token: nil, query: nil)
        } else if name == "error" {
            return Fail(error: APIError.invalidStatus(code: nil, reason: nil)).eraseToAnyPublisher()
        } else {
            return Future<Data, Error> { promise in
                let bundle = Bundle(for: type(of: self))
                guard let path = bundle.path(forResource: "configuration_\(name)", ofType: "json") else {
                    return promise(.failure(APIError.invalidStatus(code: nil, reason: nil)))
                }

                let url = URL(fileURLWithPath: path)

                guard let data = try? Data(contentsOf: url) else {
                    return promise(.failure(APIError.invalidStatus(code: nil, reason: nil)))
                }
                promise(.success(data))
            }.eraseToAnyPublisher()
        }
    }
}
