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

    /// AWSPinpointNotificationManagerProtocol
    var awsPinpointNotificationManager: AWSPinpointNotificationManagerProtocol
    /// AWSPinpointTargetingClientProtocol
    var awsPinpointTargetClient: AWSPinpointTargetingClientProtocol
    /// AWSAnalyticsClientProtocol
    var awsAnalyticsClient: AWSAnalyticsClientProtocol

    /// AWSPinpoint クラスを初期化する
    /// - Parameter launchOptions: AppDelegate から渡される起動オプション
    public init(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) {
        let config = AWSPinpointConfiguration.defaultPinpointConfiguration(launchOptions: launchOptions)
        config.debug = true
        let pinpoint = AWSPinpoint(configuration: config)
        awsPinpointNotificationManager = pinpoint.notificationManager
        awsAnalyticsClient = pinpoint.analyticsClient
        awsPinpointTargetClient = pinpoint.targetingClient
    }

    /// エンドポイントID
    public var endpointId: String? {
        awsPinpointTargetClient.currentEndpointProfile().endpointId
    }

    /// デバイス登録
    /// - Parameter deviceToken: トークン
    public func registerDevice(_ deviceToken: Data) {
        awsPinpointNotificationManager.interceptDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
        let token = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        print("deviceToken: \(token)")
    }

    /// 通知イベント送信
    /// - Parameter userInfo: ユーザー情報
    public func passRemoteNotificationEvent(_ userInfo: [AnyHashable: Any]) {
        awsPinpointNotificationManager.interceptDidReceiveRemoteNotification(userInfo)
    }

    /// エンドポイント情報更新
    /// - Parameters:
    ///   - key: キー
    ///   - value: 値
    public func updateEndpointProfile(_ key: String, value: String) {
        Logger.info(target: self, "key: \(key), value: \(value)")
        awsPinpointTargetClient.addAttribute([value], forKey: key)
        _ = awsPinpointTargetClient.updateEndpointProfile()
    }

    /// イベント記録
    /// - Parameters:
    ///   - eventName: イベント名
    ///   - parameters: イベントのパラメータ
    ///   - metrics: イベントのメトリクス
    public func recordEvent(_ eventName: String, parameters: [String: String]?, metrics: [String: Double]?) {
        Logger.info(target: self, "Event: \(eventName), parameters: \(String(describing: parameters)), metrics: \(String(describing: metrics))")

        let event = awsAnalyticsClient.createEvent(withEventType: eventName)
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
        _ = awsAnalyticsClient.record(event)
        _ = awsAnalyticsClient.submitEvents()
    }
}

/// @mockable
protocol AWSPinpointNotificationManagerProtocol {
    func interceptDidRegisterForRemoteNotifications(withDeviceToken deviceToken: Data)
    func interceptDidReceiveRemoteNotification(_ userInfo: [AnyHashable: Any])
}

extension AWSPinpointNotificationManager: AWSPinpointNotificationManagerProtocol {}

/// @mockable
protocol AWSPinpointTargetingClientProtocol {
    func currentEndpointProfile() -> AWSPinpointEndpointProfile
    func addAttribute(_ theValue: [Any], forKey theKey: String)
    func updateEndpointProfile() -> AWSTask<AnyObject>
}

extension AWSPinpointTargetingClient: AWSPinpointTargetingClientProtocol {}

/// @mockable
protocol AWSAnalyticsClientProtocol {
    func createEvent(withEventType theEventType: String) -> AWSPinpointEvent
    func record(_ theEvent: AWSPinpointEvent) -> AWSTask<AnyObject>
    func submitEvents() -> AWSTask<AnyObject>
}

extension AWSPinpointAnalyticsClient: AWSAnalyticsClientProtocol {}
