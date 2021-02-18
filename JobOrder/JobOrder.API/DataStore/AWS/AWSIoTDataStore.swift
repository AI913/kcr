//
//  AWSIoTDataStore.swift
//  JobOrder.API
//
//  Created by Yu Suzuki on 2020/03/30.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import AWSIoT
import JobOrder_Utility

/// AWS IoTを操作する
public class AWSIoTDataStore: MQTTRepository {

    /// Factory
    let factory = AWSSDKFactory.shared
    /// 接続状態配信
    private let connectionStatusPublisher = PassthroughSubject<MQTTEntity.Output.ConnectionStatus, Never>()
    /// メッセージ配信
    private let subscribedMessagePublisher = PassthroughSubject<MQTTEntity.Output.SubscribedMessage, Never>()

    /// イニシャライザ
    public init() {}

    /// 初期化
    public func initialize() {
        factory.generateIoT()
    }

    /// 接続状態通知イベントの登録
    /// - Returns: 接続状態
    public func registerConnectionStatusChange() -> AnyPublisher<MQTTEntity.Output.ConnectionStatus, Never> {
        return connectionStatusPublisher.eraseToAnyPublisher()
    }

    /// MQTTメッセージ受信イベントの登録
    /// - Returns: 受信メッセージ
    public func registerSubscribedMessage() -> AnyPublisher<MQTTEntity.Output.SubscribedMessage, Never> {
        return subscribedMessagePublisher.eraseToAnyPublisher()
    }

    /// MQTT接続
    /// 証明書の作成、Thingの作成、接続を行う
    /// - Returns: 接続結果
    public func connectWithSetup() -> AnyPublisher<MQTTEntity.Output.ConnectWithSetup, Error> {
        Logger.info(target: self)

        return Future<MQTTEntity.Output.ConnectWithSetup, Error> { promise in

            self.attachPolicy { id, state, error in
                Logger.debug(target: self, "\(state)")
                guard state == .completed else {
                    if let error = error {
                        promise(.failure(AWSError.ioTControlFailed(reason: .awsIoTClientFailed(error: error))))
                    }
                    return
                }

                self.connect(clientId: id) { (state, error) -> Void in
                    Logger.debug(target: self, "\(state)")
                    if let error = error {
                        promise(.failure(AWSError.ioTControlFailed(reason: .awsIoTClientFailed(error: error))))
                    } else {
                        // Logger.debug(target: self, "\(entity)")
                        promise(.success(.init(result: state == .completed)))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }

    /// MQTT切断
    /// 切断、Thingの削除、証明書の削除を行う
    /// - Returns: 結果
    public func disconnectWithCleanUp() -> AnyPublisher<MQTTEntity.Output.DisconnectWithCleanup, Error> {
        Logger.info(target: self)

        return Future<MQTTEntity.Output.DisconnectWithCleanup, Error> { promise in

            self.disconnect { (state, error) -> Void in
                Logger.debug(target: self, "\(state)")

                self.detachPolicy { state, error in
                    Logger.debug(target: self, "\(state)")
                    if let error = error {
                        promise(.failure(AWSError.ioTControlFailed(reason: .awsIoTClientFailed(error: error))))
                    } else {
                        // Logger.debug(target: self, "\(entity)")
                        promise(.success(.init(result: state == .completed)))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }

    /// MQTT購読開始
    /// - Parameter topic: トピック
    /// - Returns: 購読結果
    public func subscribe(topic: String) -> Bool {
        Logger.info(target: self, thingName(topic: topic))
        guard factory.iotDataManager?.getConnectionStatus() == .connected else { return false }

        return factory.iotDataManager?.subscribe(toTopic: topic, qoS: .messageDeliveryAttemptedAtMostOnce, extendedCallback: { mqttClient, topic, data in
            let entity = MQTTEntity.Output.SubscribedMessage(topic: topic, data: data)
            Logger.debug(target: self, "Topic: \(entity.topic), Payload: \(entity.payload)")
            self.subscribedMessagePublisher.send(entity)
        }) ?? false
    }

    /// MQTT購読解除
    /// - Parameter topic: トピック
    public func unSubscribe(topic: String) {
        Logger.info(target: self, thingName(topic: topic))
        guard factory.iotDataManager?.getConnectionStatus() == .connected else { return }

        factory.iotDataManager?.unsubscribeTopic(topic)
    }

    /// MQTT配信
    /// - Parameters:
    ///   - topic: トピック
    ///   - message: メッセージ
    /// - Returns: 配信結果
    public func publish(topic: String, message: String) -> Bool {
        Logger.info(target: self, "Topic: \(topic), Message: \(message)")
        guard factory.iotDataManager?.getConnectionStatus() == .connected else { return false }

        return factory.iotDataManager?.publishString(message, onTopic: topic, qoS: .messageDeliveryAttemptedAtMostOnce) ?? false
    }

    /// Job作成
    /// - Parameters:
    ///   - bucketType: Bucketタイプ
    ///   - targets: ターゲット
    ///   - jobId: Job ID
    ///   - detail: 詳細
    /// - Returns: Job作成結果
    public func createJob(bucketType: CloudStorageEntity.BucketType, targets: [String], jobId: String, detail: String?) -> AnyPublisher<MQTTEntity.Output.CreateJob, Error> {
        Logger.info(target: self)

        return Future<MQTTEntity.Output.CreateJob, Error> { promise in
            let bucket = CloudStorageEntity.Bucket(bucketType)
            let s3Url = URL(string: "https://s3.amazonaws.com/")!.appendingPathComponent(bucket.name).appendingPathComponent(jobId)
            let document = MQTTEntity.Output.JobDocument(distFileUrl: "${aws:iot:s3-presigned-url:\(s3Url.absoluteString)}")
            let documentJson: String

            do {
                let data = try JSONEncoder().encode(document)
                documentJson = String(data: data, encoding: .utf8)!
            } catch let error {
                promise(.failure(AWSError.ioTControlFailed(reason: .awsIoTClientFailed(error: error))))
                return
            }

            let createJobRequest = AWSIoTCreateJobRequest()!
            createJobRequest.jobId = jobId
            createJobRequest.targets = targets
            createJobRequest.document = documentJson
            createJobRequest.detail = detail

            let presignedUrlConfig = AWSIoTPresignedUrlConfig()!
            presignedUrlConfig.roleArn = AWSConstants.IAM.Role.s3DownloadArn
            presignedUrlConfig.expiresInSec = 300
            createJobRequest.presignedUrlConfig = presignedUrlConfig

            self.factory.iot?.createJob(createJobRequest).continueWith { (task) -> AnyObject? in
                if let error = task.error {
                    promise(.failure(AWSError.ioTControlFailed(reason: .awsIoTClientFailed(error: error))))
                } else {
                    let entity = MQTTEntity.Output.CreateJob(state: APITaskEntity.State(task), id: task.result?.jobId, arn: task.result?.jobArn)
                    // Logger.debug(target: self, "\(entity)")
                    promise(.success(entity))
                }
                return nil
            }
        }.eraseToAnyPublisher()
    }

    /// Shadow stateを取得
    /// - Parameters:
    ///   - topic: トピック
    ///   - payload: ペイロード
    /// - Returns: Shadow state
    public func shadowState(topic: String, payload: String) -> String? {
        return APIThingShadow().shadowState(topic: topic, payload: payload)
    }

    /// トピックからThing名を取得
    /// - Parameter topic: トピック
    /// - Returns: Thing名
    public func thingName(topic: String) -> String? {
        return APIThingShadow.Interact().getThingName(topic: topic)
    }

    /// Thing名で指定した全てのGet Thing Shadowをするトピックを取得
    /// - Parameter thingName: Thing名
    /// - Returns: トピック
    public func topicThingAll(_ thingName: String) -> String? {
        return APIThingShadow.Interact().topicThingAll(thingName)
    }

    /// Get Thing Shadow のトピックを取得
    /// - Parameter thingName: Thing名
    /// - Returns: トピック
    public func topicGetThisThingShadow(_ thingName: String) -> String? {
        return APIThingShadow.Interact().topicGetThisThingShadow(thingName)
    }
}

// MARK: - Private functions
extension AWSIoTDataStore {

    func getIdentityId(callback: @escaping (_ id: String?, _ state: APITaskEntity.State, _ error: Error?) -> Void) {

        self.factory.mobileClient?.getIdentityId().continueWith { (task) -> AnyObject? in

            let state = APITaskEntity.State(task)

            guard state == .completed else {
                callback(nil, state, task.error)
                return nil
            }

            callback(task.result as String?, state, nil)
            return nil
        }
    }

    func attachPolicy(callback: @escaping (_ id: String?, _ state: APITaskEntity.State, _ error: Error?) -> Void) {

        getIdentityId { id, state, error in

            guard state == .completed else {
                callback(nil, state, error)
                return
            }

            let request = AWSIoTAttachPolicyRequest()!
            request.policyName = "App-JobOrder"
            request.target = id
            self.factory.iot?.attachPolicy(request).continueWith { task in
                let state = APITaskEntity.State(task)
                callback(id, state, task.error)
                return nil
            }
        }
    }

    func detachPolicy(callback: @escaping (_ state: APITaskEntity.State, _ error: Error?) -> Void) {

        getIdentityId { id, state, error in

            guard state == .completed else {
                callback(state, error)
                return
            }

            let request = AWSIoTDetachPolicyRequest()!
            request.policyName = "App-JobOrder"
            request.target = id
            self.factory.iot?.detachPolicy(request).continueWith { task in
                let state = APITaskEntity.State(task)
                callback(state, task.error)
                return nil
            }
        }
    }

    func connect(clientId: String?, callback: @escaping ((_ state: APITaskEntity.State, _ error: Error?) -> Void)) {
        Logger.info(target: self)

        guard let clientId = clientId else {
            callback(.faulted, AWSError.ioTControlFailed(reason: .connectionFailed(reason: .clientIDisNotAvailable)))
            return
        }

        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            let result = self.factory.iotDataManager?.connectUsingWebSocket(withClientId: clientId,
                                                                            cleanSession: true,
                                                                            statusCallback: { status in
                                                                                let entity = MQTTEntity.Output.ConnectionStatus(status)
                                                                                self.connectionStatusPublisher.send(entity)
                                                                            })

            if result ?? false {
                callback(.completed, nil)
            } else {
                callback(.faulted, AWSError.ioTControlFailed(reason: .connectionFailed(reason: .connectFailed)))
            }
        }
    }

    func disconnect(callback: ((_ state: APITaskEntity.State, _ error: Error?) -> Void)? = nil) {
        Logger.info(target: self)

        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            self.factory.iotDataManager?.disconnect()
            callback?(.completed, nil)
        }
    }
}
