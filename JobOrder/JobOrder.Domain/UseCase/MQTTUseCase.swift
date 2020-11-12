//
//  MQTTUseCase.swift
//  JobOrder.Domain
//
//  Created by Yu Suzuki on 2020/03/30.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_API
import JobOrder_Data
import JobOrder_Utility

// MARK: - Interface
/// MQTTUseCaseProtocol
/// @mockable
public protocol MQTTUseCaseProtocol: class {
    /// 接続状態通知イベントの登録
    func registerConnectionStatusChange() -> AnyPublisher<MQTTModel.Output.ConnectionStatus, Never>
    /// MQTT接続
    func connect() -> AnyPublisher<MQTTModel.Output.Connect, Error>
    /// MQTT切断
    func disconnect() -> AnyPublisher<MQTTModel.Output.Disconnect, Error>
    /// 見つかったRobotを購読する
    func subscribeRobots()
    /// Job作成
    /// - Parameters:
    ///   - targets: 指示するRobot
    ///   - jobId: Job ID
    ///   - form: 入力Jobデータ
    func createJob(targets: [String], jobId: String, form: MQTTModel.Input.CreateJob) -> AnyPublisher<MQTTModel.Output.CreateJobState, Error>

    /// 処理中
    // var _processing: Published<Bool> { get set }
    var processing: Bool { get }
    var processingPublished: Published<Bool> { get }
    var processingPublisher: Published<Bool>.Publisher { get }
}

// MARK: - Implementation
/// MQTTUseCase
public class MQTTUseCase: MQTTUseCaseProtocol {

    /// 処理中
    @Published public var processing: Bool = false
    public var processingPublished: Published<Bool> { _processing }
    public var processingPublisher: Published<Bool>.Publisher { $processing }

    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// Authenticationレポジトリ
    private let auth: JobOrder_API.AuthenticationRepository
    /// MQTTレポジトリ
    private let mqtt: JobOrder_API.MQTTRepository
    /// CloudStorageレポジトリ
    private let storage: JobOrder_API.CloudStorageRepository
    /// Keychainレポジトリ
    private let keychain: JobOrder_Data.KeychainRepository
    /// Robotレポジトリ
    private var robotData: JobOrder_Data.RobotRepository

    /// イニシャライザ
    /// - Parameters:
    ///   - authRepository: Authenticationレポジトリ
    ///   - mqttRepository: MQTTレポジトリ
    ///   - storageRepository: CloudStorageレポジトリ
    ///   - robotDataRepository: Robotレポジトリ
    public required init(authRepository: JobOrder_API.AuthenticationRepository,
                         mqttRepository: JobOrder_API.MQTTRepository,
                         storageRepository: JobOrder_API.CloudStorageRepository,
                         keychainRepository: JobOrder_Data.KeychainRepository,
                         robotDataRepository: JobOrder_Data.RobotRepository) {
        self.auth = authRepository
        self.mqtt = mqttRepository
        self.storage = storageRepository
        self.keychain = keychainRepository
        self.robotData = robotDataRepository
    }

    /// 接続状態通知イベントの登録
    /// - Returns: 状態
    public func registerConnectionStatusChange() -> AnyPublisher<MQTTModel.Output.ConnectionStatus, Never> {
        Logger.info(target: self)

        let publisher = PassthroughSubject<MQTTModel.Output.ConnectionStatus, Never>()
        mqtt.registerConnectionStatusChange()
            .map { value -> MQTTModel.Output.ConnectionStatus in
                return MQTTModel.Output.ConnectionStatus(value)
            }.sink { response in
                // Logger.debug(target: self, "\(response)")
                if response == .connected {
                    self.subscribeRobots()
                }
                publisher.send(response)
            }.store(in: &self.cancellables)
        return publisher.eraseToAnyPublisher()
    }

    /// MQTT接続
    /// - Returns: 接続結果
    public func connect() -> AnyPublisher<MQTTModel.Output.Connect, Error> {
        Logger.info(target: self)

        self.processing = true
        return Future<MQTTModel.Output.Connect, Error> { promise in
            self.mqtt.connectWithSetup()
                .map { value -> MQTTModel.Output.Connect in
                    return MQTTModel.Output.Connect(result: value.result)
                }.sink(receiveCompletion: { completion in
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    // Logger.debug(target: self, "\(response)")
                    promise(.success(response))
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }

    /// MQTT切断
    /// - Returns: 切断結果
    public func disconnect() -> AnyPublisher<MQTTModel.Output.Disconnect, Error> {
        Logger.info(target: self)

        self.processing = true
        return Future<MQTTModel.Output.Disconnect, Error> { promise in
            self.mqtt.disconnectWithCleanUp()
                .map { value -> MQTTModel.Output.Disconnect in
                    return MQTTModel.Output.Disconnect(result: value.result)
                }.sink(receiveCompletion: { completion in
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    // Logger.debug(target: self, "\(response)")
                    promise(.success(response))
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }

    /// 見つかったロボットを購読する
    public func subscribeRobots() {
        Logger.info(target: self)

        robotData.read()?.forEach {
            if let thingName = $0.thingName {
                self.subscribe(thingName: thingName)
            }
        }
    }

    /// Job作成
    /// - Parameters:
    ///   - targets: 指示するRobot
    ///   - jobId: JobID
    ///   - form: 入力Jobデータ
    /// - Returns: 結果
    public func createJob(targets: [String], jobId: String, form: MQTTModel.Input.CreateJob) -> AnyPublisher<MQTTModel.Output.CreateJobState, Error> {
        Logger.info(target: self)

        self.processing = true
        return Future<MQTTModel.Output.CreateJobState, Error> { promise in

            let document = MQTTTranslator().toData(model: form)
            self.storage.uploadJsonText(bucketType: .jobDocument, key: jobId, document: document!)
                .flatMap { _ in
                    return self.mqtt.createJob(bucketType: .jobDocument, targets: targets, jobId: jobId, detail: form.remarks)
                        .map { value in
                            MQTTModel.Output.CreateJobState(value.state)
                        }
                }.sink(receiveCompletion: { completion in
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    // FIXME: responseの形式
                    promise(.success(response))
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
}

// MARK: - Private function
extension MQTTUseCase {

    /// MQTT購読&メッセージ受信イベントの登録
    /// - Parameter thingName: Thing名
    /// - Returns: 登録結果
    func subscribe(thingName: String) {
        // ThingName以下の全てのメッセージをSubscribeする
        // 成功したらShadow/getをPublishする
        let subscribeTopic = mqtt.topicThingAll(thingName) ?? ""

        if mqtt.subscribe(topic: subscribeTopic) {
            let publishTopic = mqtt.topicGetThisThingShadow(thingName) ?? ""
            // 購読後すぐにPublishをすると応答がない場合があるので少しDelayを入れる
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                _ = self.mqtt.publish(topic: publishTopic, message: "")
            }
        } else {
            // TODO: エラーケース
            mqtt.unSubscribe(topic: subscribeTopic)
        }

        // 受信したメッセージを解析しPresenterへ返す
        mqtt.registerSubscribedMessage()
            .map { value -> MQTTModel.Output.SubscribedMessage in
                return MQTTModel.Output.SubscribedMessage(topic: value.topic, payload: value.payload)
            }.sink { response in
                self.updateData(message: response)
            }.store(in: &self.cancellables)
    }

    /// メッセージ受信イベントの解除
    /// - Parameter thingName: Thing名
    func unSubscribe(thingName: String) {
        let topic = mqtt.topicThingAll(thingName) ?? ""
        mqtt.unSubscribe(topic: topic)
    }

    /// 受信したメッセージをパースしてデータを更新する
    /// - Parameter message: 受信メッセージ
    func updateData(message: MQTTModel.Output.SubscribedMessage) {
        if message.payload == "" { return }
        guard let robot = robotData.read()?.first(where: { $0.thingName == mqtt.thingName(topic: message.topic) }),
              let state = mqtt.shadowState(topic: message.topic, payload: message.payload) else { return }
        robotData.update(state: state, entity: robot)
    }
}
