//
//  AWSAnalyticsDataStore.swift
//  JobOrder
//
//  Created by Yu Suzuki on 2020/12/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import AWSPinpoint
import JobOrder_Utility

/// AWS Analytics API を利用して Amazon Pinpoint を操作する
public class AWSAnalyticsDataStore: AnalyticsServiceRepository {

    /// Factory
    let factory = AWSSDKFactory.shared

    /// AWSPinpoint クラスを初期化する
    /// - Parameter launchOptions: AppDelegate から渡される起動オプション
    public init(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) {
        factory.set(launchOptions: launchOptions)
    }

    /// 初期化
    /// - Parameter configuration: Configuration データ
    public func initialize(_ configuration: [String: Any]) {
        guard let id = configuration
                .filter { $0.key == "PinpointAnalytics" }.compactMapValues { $0 as? [String: Any] }.first?.value
                .filter { $0.key == "Default" }.compactMapValues { $0 as? [String: Any] }.first?.value
                .filter({ $0.key == "AppId" }).compactMapValues({ $0 as? String }).first?.value else { return }

        factory.generatePinpoint(appId: id)
    }

    /// エンドポイントID
    public var endpointId: String? {
        factory.pinpointTargetClient?.currentEndpointProfile().endpointId
    }

    /// デバイス登録
    /// - Parameter deviceToken: トークン
    public func registerDevice(_ deviceToken: Data) {
        factory.pinpointNotificationManager?.interceptDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
        let token = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        print("deviceToken: \(token)")
    }

    /// 通知イベント送信
    /// - Parameter userInfo: ユーザー情報
    public func passRemoteNotificationEvent(_ userInfo: [AnyHashable: Any]) {
        factory.pinpointNotificationManager?.interceptDidReceiveRemoteNotification(userInfo)
    }

    /// エンドポイント情報更新
    /// - Parameters:
    ///   - key: キー
    ///   - value: 値
    public func updateEndpointProfile(_ key: String, value: String) {
        Logger.info(target: self, "key: \(key), value: \(value)")
        factory.pinpointTargetClient?.addAttribute([value], forKey: key)
        _ = factory.pinpointTargetClient?.updateEndpointProfile()
    }

    /// イベント記録
    /// - Parameters:
    ///   - eventName: イベント名
    ///   - parameters: イベントのパラメータ
    ///   - metrics: イベントのメトリクス
    public func recordEvent(_ eventName: String, parameters: [String: String]?, metrics: [String: Double]?) {
        Logger.info(target: self, "Event: \(eventName), parameters: \(String(describing: parameters)), metrics: \(String(describing: metrics))")

        guard let event = factory.analyticsClient?.createEvent(withEventType: eventName) else { return }
        if parameters != nil {
            for (key, value) in parameters! {
                event.addAttribute(value, forKey: key)
            }
        }
        if metrics != nil {
            for (key, value) in metrics! {
                event.addMetric(NSNumber(value: value), forKey: key)
            }
        }
        _ = factory.analyticsClient?.record(event)
        _ = factory.analyticsClient?.submitEvents()
    }
}
