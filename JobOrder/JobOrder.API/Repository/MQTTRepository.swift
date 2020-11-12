//
//  MQTTRepository.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

/// クラウドに対してMQTT通信を行うためのプロトコル
/// @mockable
public protocol MQTTRepository {
    /// 接続状態通知イベントの登録
    func registerConnectionStatusChange() -> AnyPublisher<MQTTEntity.Output.ConnectionStatus, Never>
    /// MQTTメッセージ受信イベントの登録
    func registerSubscribedMessage() -> AnyPublisher<MQTTEntity.Output.SubscribedMessage, Never>
    /// MQTT接続
    func connectWithSetup() -> AnyPublisher<MQTTEntity.Output.ConnectWithSetup, Error>
    /// MQTT切断
    func disconnectWithCleanUp() -> AnyPublisher<MQTTEntity.Output.DisconnectWithCleanup, Error>
    /// MQTT購読開始
    /// - Parameter topic: トピック
    func subscribe(topic: String) -> Bool
    /// MQTT購読解除
    /// - Parameter topic: トピック
    func unSubscribe(topic: String)
    /// MQTT配信
    /// - Parameters:
    ///   - topic: トピック
    ///   - message: メッセージ
    func publish(topic: String, message: String) -> Bool
    /// Job作成
    /// - Parameters:
    ///   - bucketType: Bucketタイプ
    ///   - targets: 指示するRobot
    ///   - jobId: Job ID
    ///   - detail: 詳細
    func createJob(bucketType: CloudStorageEntity.BucketType, targets: [String], jobId: String, detail: String?) -> AnyPublisher<MQTTEntity.Output.CreateJob, Error>

    /// Shadow stateを取得
    /// - Parameters:
    ///   - topic: トピック
    ///   - payload: ペイロード
    func shadowState(topic: String, payload: String) -> String?
    /// トピックからThing名を取得
    /// - Parameter topic: トピック
    func thingName(topic: String) -> String?
    /// Thing名で指定した全てのGet Thing Shadowをするトピックを取得
    /// - Parameter thingName: Thing名
    func topicThingAll(_ thingName: String) -> String?
    /// Get Thing Shadow のトピックを取得
    /// - Parameter thingName: Thing名
    func topicGetThisThingShadow(_ thingName: String) -> String?
}
