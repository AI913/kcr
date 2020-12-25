//
//  AnalyticsServiceRepository.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

/// クラウドに対して行動分析の送信を行うためのプロトコル
/// @mockable
public protocol AnalyticsServiceRepository {
    /// エンドポイントID
    var endpointId: String? { get }
    /// デバイス登録
    /// - Parameter deviceToken: トークン
    func registerDevice(_ deviceToken: Data)
    /// 通知イベント送信
    /// - Parameter userInfo: ユーザー情報
    func passRemoteNotificationEvent(_ userInfo: [AnyHashable: Any])
    /// エンドポイント情報更新
    /// - Parameters:
    ///   - key: キー
    ///   - value: 値
    func updateEndpointProfile(_ key: String, value: String)
    /// イベント記録
    /// - Parameters:
    ///   - eventName: イベント名
    ///   - parameters: イベントのパラメータ
    ///   - metrics: イベントのメトリクス
    func recordEvent(_ eventName: String, parameters: [String: String]?, metrics: [String: Double]?)
}
