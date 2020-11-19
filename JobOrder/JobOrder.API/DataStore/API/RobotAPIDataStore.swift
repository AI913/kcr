//
//  RobotAPIDataStore.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/08.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Utility

/// Robot情報を操作するAPI
public class RobotAPIDataStore: RobotAPIRepository {
    /// APIRequestProtocol
    private let api: APIRequestProtocol
    /// エンドポイントURL
    // public let url: URL = URL(string: AWSConstants.APIGateway.endPoint)!.appendingPathComponent("robots")
    public let url: URL = URL(string: AWSConstants.APIGateway.endPoint)!.appendingPathComponent("v1").appendingPathComponent("robots")

    /// イニシャライザ
    /// - Parameter api: APIRequestProtocol
    public init(api: APIRequestProtocol) {
        self.api = api
    }

    /// Robot情報リストを取得する
    /// - Parameter token: トークン情報
    /// - Returns: Robot情報リスト
    public func fetch(_ token: String) -> AnyPublisher<APIResult<[RobotAPIEntity.Data]>, Error> {
        Logger.info(target: self)
        return api.get(url: url, token: token)
    }

    /// Robot情報を取得する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - id: Robot ID
    /// - Returns: Robot情報
    public func getRobot(_ token: String, id: String) -> AnyPublisher<APIResult<RobotAPIEntity.Data>, Error> {
        Logger.info(target: self)
        return api.get(resUrl: url, token: token, dataId: id)
    }

    /// Robot画像を取得する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - id: Robot ID
    /// - Returns: Robot画像
    public func getImage(_ token: String, id: String) -> AnyPublisher<Data, Error> {
        Logger.info(target: self)
        return api.getImage(resUrl: url, token: token, dataId: "\(id)/image")
    }

    /// Robot Command情報を取得する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - id: Robot ID
    /// - Returns: Robot Command情報
    public func getCommands(_ token: String, id: String) -> AnyPublisher<APIResult<[CommandEntity.Data]>, Error> {
        Logger.info(target: self)
        return api.get(resUrl: url, token: token, dataId: "\(id)/commands")
    }

    /// Robot SW構成情報を取得する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - id: Robot ID
    /// - Returns: Robot SW構成情報
    public func getRobotSwconf(_ token: String, id: String) -> AnyPublisher<APIResult<RobotAPIEntity.Swconf>, Error> {
        Logger.info(target: self)
        return api.get(resUrl: url, token: token, dataId: "\(id)/swconf")
    }

    /// Robot アセット情報を取得する
    /// - Parameters:
    ///   - token: トークン情報
    ///   - id: Robot ID
    /// - Returns: Robot アセット情報
    public func getRobotAssets(_ token: String, id: String) -> AnyPublisher<APIResult<[RobotAPIEntity.Asset]>, Error> {
        Logger.info(target: self)
        return api.get(resUrl: url, token: token, dataId: "\(id)/assets")
    }
}
