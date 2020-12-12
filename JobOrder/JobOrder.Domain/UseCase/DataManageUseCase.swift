//
//  DataManageUseCase.swift
//  JobOrder.Domain
//
//  Created by Kento Tatsumi on 2020/04/03.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_API
import JobOrder_Data
import JobOrder_Utility

// MARK: - Interface
/// DataManageUseCaseProtocol
/// @mockable
public protocol DataManageUseCaseProtocol {
    /// 保存してあるJobデータ
    var jobs: [DataManageModel.Output.Job]? { get }
    /// 保存してあるRobotデータ
    var robots: [DataManageModel.Output.Robot]? { get }
    /// 保存してあるActionLibraryデータ
    var actionLibraries: [DataManageModel.Output.ActionLibrary]? { get }
    /// 保存してあるAILibraryデータ
    var aiLibraries: [DataManageModel.Output.AILibrary]? { get }
    /// 保存してあるJobデータの変化を監視
    func observeJobData() -> AnyPublisher<[DataManageModel.Output.Job]?, Never>
    /// 保存してあるRobotデータの変化を監視
    func observeRobotData() -> AnyPublisher<[DataManageModel.Output.Robot]?, Never>
    /// クラウドからデータを取得する
    func syncData() -> AnyPublisher<DataManageModel.Output.SyncData, Error>
    /// クラウドから取得したデータを削除する
    func removeData() -> AnyPublisher<DataManageModel.Output.RemoveData, Error>
    /// ロボット画像を取得する
    /// - Parameter id: Robot ID
    func robotImage(id: String) -> AnyPublisher<DataManageModel.Output.RobotImage, Error>
    /// Robot情報を取得する
    /// - Parameter id: Robot ID
    func robot(id: String) -> AnyPublisher<DataManageModel.Output.Robot, Error>
    /// RobotCommandの情報を取得する
    /// - Parameter id: Robot ID
    func commandFromRobot(id: String, status: [CommandModel.Status.Value]?, cursor: PagingModel.Cursor?) -> AnyPublisher<PagingModel.PaginatedResult<[DataManageModel.Output.Command]>, Error>
    /// Task情報の詳細を取得する
    /// - Parameters:
    ///   - taskId: Task ID
    ///   - robotId: Robot ID
    func commandFromTask(taskId: String, robotId: String) -> AnyPublisher<DataManageModel.Output.Command, Error>
    /// Task情報の詳細を取得する
    /// - Parameters:
    ///   - taskId: Task ID
    func commandsFromTask(taskId: String) -> AnyPublisher<[DataManageModel.Output.Command], Error>
    /// Task情報を取得する
    /// - Parameter taskId: TaskID
    func task(taskId: String) -> AnyPublisher<DataManageModel.Output.Task, Error>
    /// RobotSystemの情報を取得する
    /// - Parameter id: Robot ID
    func robotSystem(id: String) -> AnyPublisher<DataManageModel.Output.System, Error>
    /// Task情報を取得する
    /// - Parameter id: Job ID
    func tasksFromJob(id: String, cursor: PagingModel.Cursor?) -> AnyPublisher<PagingModel.PaginatedResult<[DataManageModel.Output.Task]>, Error>

    //var _processing: Published<Bool> { get set }
    var processing: Bool { get }
    var processingPublished: Published<Bool> { get }
    var processingPublisher: Published<Bool>.Publisher { get }
}

// MARK: - Implementation
/// DataManageUseCase
public class DataManageUseCase: DataManageUseCaseProtocol {

    typealias APIResults = (APIResult<[JobOrder_API.JobAPIEntity.Data]>,
                            APIResult<[JobOrder_API.RobotAPIEntity.Data]>,
                            APIResult<[JobOrder_API.ActionLibraryAPIEntity.Data]>,
                            APIResult<[JobOrder_API.AILibraryAPIEntity.Data]>)

    @Published public var processing: Bool = false
    public var processingPublished: Published<Bool> { _processing }
    public var processingPublisher: Published<Bool>.Publisher { $processing }

    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// APIエンティティ -> Dataエンティティ変換
    private let translator = DataTranslator()
    /// AuthenticationRepository
    private let auth: JobOrder_API.AuthenticationRepository
    /// MQTTRepository
    private let mqtt: JobOrder_API.MQTTRepository
    /// MQTTRepository
    private let robotAPI: JobOrder_API.RobotAPIRepository
    /// JobAPIRepository
    private let jobAPI: JobOrder_API.JobAPIRepository
    /// ActionLibraryAPIRepository
    private let actionLibraryAPI: JobOrder_API.ActionLibraryAPIRepository
    /// AILibraryAPIRepository
    private let aILibraryAPI: JobOrder_API.AILibraryAPIRepository
    /// UserDefaultsRepository
    private var ud: JobOrder_Data.UserDefaultsRepository
    /// RobotRepository
    private var robotData: JobOrder_Data.RobotRepository
    /// JobRepository
    private var jobData: JobOrder_Data.JobRepository
    /// TaskRepository
    private let taskAPI: JobOrder_API.TaskAPIRepository
    /// ActionLibraryRepository
    private var actionLibraryData: JobOrder_Data.ActionLibraryRepository
    /// AILibraryRepository
    private var aiLibraryData: JobOrder_Data.AILibraryRepository

    /// イニシャライザ
    /// - Parameters:
    ///   - authRepository: AuthenticationRepository
    ///   - mqttRepository: MQTTRepository
    ///   - robotAPIRepository: RobotAPIRepository
    ///   - jobAPIRepository: JobAPIRepository
    ///   - actionLibraryAPIRepository: ActionLibraryAPIRepository
    ///   - aILibraryAPIRepository: AILibraryAPIRepository
    ///   - taskAPIRepository: TaskAPIRepository
    ///   - userDefaultsRepository: UserDefaultsRepository
    ///   - robotDataRepository: RobotRepository
    ///   - jobDataRepository: JobRepository
    ///   - actionLibraryDataRepository: ActionLibraryRepository
    ///   - aiLibraryDataRepository: AILibraryRepository
    public required init(authRepository: JobOrder_API.AuthenticationRepository,
                         mqttRepository: JobOrder_API.MQTTRepository,
                         robotAPIRepository: JobOrder_API.RobotAPIRepository,
                         jobAPIRepository: JobOrder_API.JobAPIRepository,
                         actionLibraryAPIRepository: JobOrder_API.ActionLibraryAPIRepository,
                         aILibraryAPIRepository: JobOrder_API.AILibraryAPIRepository,
                         taskAPIRepository: JobOrder_API.TaskAPIRepository,
                         userDefaultsRepository: JobOrder_Data.UserDefaultsRepository,
                         robotDataRepository: JobOrder_Data.RobotRepository,
                         jobDataRepository: JobOrder_Data.JobRepository,
                         actionLibraryDataRepository: JobOrder_Data.ActionLibraryRepository,
                         aiLibraryDataRepository: JobOrder_Data.AILibraryRepository
    ) {
        self.auth = authRepository
        self.mqtt = mqttRepository
        self.robotAPI = robotAPIRepository
        self.jobAPI = jobAPIRepository
        self.actionLibraryAPI = actionLibraryAPIRepository
        self.aILibraryAPI = aILibraryAPIRepository
        self.taskAPI = taskAPIRepository
        self.ud = userDefaultsRepository
        self.robotData = robotDataRepository
        self.jobData = jobDataRepository
        self.actionLibraryData = actionLibraryDataRepository
        self.aiLibraryData = aiLibraryDataRepository
    }

    /// 保存してあるJobデータ
    public var jobs: [DataManageModel.Output.Job]? {
        return jobData.read()?.compactMap { DataManageModel.Output.Job($0) }
    }

    /// 保存してあるRobotデータ
    public var robots: [DataManageModel.Output.Robot]? {
        return robotData.read()?.compactMap { DataManageModel.Output.Robot($0) }
    }

    /// 保存してあるActionLibraryデータ
    public var actionLibraries: [DataManageModel.Output.ActionLibrary]? {
        return actionLibraryData.read()?.compactMap { DataManageModel.Output.ActionLibrary($0) }
    }

    /// 保存してあるAILibraryデータ
    public var aiLibraries: [DataManageModel.Output.AILibrary]? {
        return aiLibraryData.read()?.compactMap { DataManageModel.Output.AILibrary($0) }
    }

    /// 保存してあるJobデータの変化を監視
    /// - Returns: Jobデータ
    public func observeJobData() -> AnyPublisher<[DataManageModel.Output.Job]?, Never> {
        Logger.info(target: self)

        let publisher = PassthroughSubject<[DataManageModel.Output.Job]?, Never>()
        self.jobData.observe()
            .map { value -> [DataManageModel.Output.Job]? in
                return value?.compactMap { DataManageModel.Output.Job($0) }
            }.sink { response in
                // Logger.debug(target: self, "\(String(describing: response))")
                publisher.send(response)
            }.store(in: &self.cancellables)
        return publisher.eraseToAnyPublisher()
    }

    /// 保存してあるRobotデータの変化を監視
    /// - Returns: Robotデータ
    public func observeRobotData() -> AnyPublisher<[DataManageModel.Output.Robot]?, Never> {
        Logger.info(target: self)

        let publisher = PassthroughSubject<[DataManageModel.Output.Robot]?, Never>()
        self.robotData.observe()
            .map { value -> [DataManageModel.Output.Robot]? in
                return value?.compactMap { DataManageModel.Output.Robot($0) }
            }.sink { response in
                // Logger.debug(target: self, "\(String(describing: response))")
                publisher.send(response)
            }.store(in: &self.cancellables)
        return publisher.eraseToAnyPublisher()
    }

    /// クラウドからデータを取得する
    /// - Returns: 取得したデータ群
    public func syncData() -> AnyPublisher<DataManageModel.Output.SyncData, Error> {
        Logger.info(target: self)

        self.processing = true
        return Future<DataManageModel.Output.SyncData, Error> { promise in
            self.auth.getTokens()
                .flatMap { value -> AnyPublisher<APIResults, Error> in
                    guard let token = value.idToken else {
                        return Future<APIResults, Error> { promise in
                            let userInfo = ["__type": "getTokens", "message": "idToken is null."]
                            promise(.failure(NSError(domain: "Error", code: -1, userInfo: userInfo)))
                        }.eraseToAnyPublisher()
                    }
                    return self.jobAPI.fetch(token)
                        .zip(self.robotAPI.fetch(token))
                        .zip(self.actionLibraryAPI.fetch(token))
                        .zip(self.aILibraryAPI.fetch(token))
                        .map { value in
                            return (value.0.0.0, value.0.0.1, value.0.1, value.1)
                        }.eraseToAnyPublisher()
                }.sink(receiveCompletion: { completion in
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        Logger.error(target: self, error.localizedDescription)
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    // データベースへ保存
                    self.saveData(results: response)
                    let time = max(response.0.time, response.1.time, response.2.time, response.3.time)
                    self.ud.set(time, forKey: .lastSynced)
                    let output = DataManageModel.Output.SyncData(jobEntities: self.jobData.read(),
                                                                 robotEntities: self.robotData.read(),
                                                                 actionLibraryEntities: self.actionLibraryData.read(),
                                                                 aiLibraryEntities: self.aiLibraryData.read())
                    promise(.success(output))
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }

    /// クラウドから取得したデータを削除する
    /// - Returns: 削除したデータ群
    public func removeData() -> AnyPublisher<DataManageModel.Output.RemoveData, Error> {
        Logger.info(target: self)

        return Future<DataManageModel.Output.RemoveData, Error> { promise in
            // TODO: 要検討
        }.eraseToAnyPublisher()
    }

    /// Robot情報を取得する
    /// - Parameter id: Robot ID
    /// - Returns: Robot情報
    public func robot(id: String) -> AnyPublisher<DataManageModel.Output.Robot, Error> {
        Logger.info(target: self)

        self.processing = true
        return Future<DataManageModel.Output.Robot, Error> { promise in
            self.auth.getTokens()
                .flatMap { value -> AnyPublisher<APIResult<JobOrder_API.RobotAPIEntity.Data>, Error> in
                    guard let token = value.idToken else {
                        return Future<APIResult<JobOrder_API.RobotAPIEntity.Data>, Error> { promise in
                            let userInfo = ["__type": "getTokens", "message": "idToken is null."]
                            promise(.failure(NSError(domain: "Error", code: -1, userInfo: userInfo)))
                        }.eraseToAnyPublisher()
                    }
                    return self.robotAPI.getRobot(token, id: id).eraseToAnyPublisher()
                }.sink(receiveCompletion: { completion in
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        Logger.error(target: self, error.localizedDescription)
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    self.saveRobot(result: response)
                    if let output = self.robotData.read()?.first(where: { $0.id == response.data?.id }) {
                        promise(.success(.init(output)))
                    } else {
                        // TODO: エラーケース
                    }
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }

    /// ロボット画像を取得する
    /// - Parameter id: Robot ID
    /// - Returns: 画像
    public func robotImage(id: String) -> AnyPublisher<DataManageModel.Output.RobotImage, Error> {
        Logger.info(target: self)

        self.processing = true
        return Future<DataManageModel.Output.RobotImage, Error> { promise in
            self.auth.getTokens()
                .flatMap { value -> AnyPublisher<Data, Error> in
                    guard let token = value.idToken else {
                        return Future<Data, Error> { promise in
                            let userInfo = ["__type": "getTokens", "message": "idToken is null."]
                            promise(.failure(NSError(domain: "Error", code: -1, userInfo: userInfo)))
                        }.eraseToAnyPublisher()
                    }
                    return self.robotAPI.getImage(token, id: id).eraseToAnyPublisher()
                }.sink(receiveCompletion: { completion in
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        Logger.error(target: self, error.localizedDescription)
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    promise(.success(.init(data: response)))
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
    /// ロボットCommandを取得する
    /// - Parameter id: Robot ID
    /// - Returns: Command
    public func commandFromRobot(id: String, status: [CommandModel.Status.Value]?, cursor: PagingModel.Cursor?) -> AnyPublisher<PagingModel.PaginatedResult<[DataManageModel.Output.Command]>, Error> {
        Logger.info(target: self)

        self.processing = true
        return Future<PagingModel.PaginatedResult<[DataManageModel.Output.Command]>, Error> { promise in
            self.auth.getTokens()
                .flatMap { value -> AnyPublisher<APIResult<[JobOrder_API.CommandEntity.Data]>, Error> in
                    guard let token = value.idToken else {
                        return Future<APIResult<[JobOrder_API.CommandEntity.Data]>, Error> { promise in
                            let userInfo = ["__type": "getTokens", "message": "idToken is null."]
                            promise(.failure(NSError(domain: "Error", code: -1, userInfo: userInfo)))
                        }.eraseToAnyPublisher()
                    }
                    return self.robotAPI.getCommands(token, id: id, status: status?.map({ $0.queryString }), paging: cursor?.toPaging()).eraseToAnyPublisher()
                }.sink(receiveCompletion: { completion in
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        Logger.error(target: self, error.localizedDescription)
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    if let output = response.data?.compactMap({ DataManageModel.Output.Command($0) }) {
                        promise(.success(.init(data: output, paging: response.paging)))
                    } else {
                        let userInfo = ["__type": "commandFromRobot", "message": "API Resuponse is null"]
                        promise(.failure(NSError(domain: "Error", code: -1, userInfo: userInfo)))
                    }
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }

    /// TaskCommandを取得する
    /// - Parameter id: Task  ID & Robot ID
    /// - Returns: TaskCommand
    public func commandFromTask(taskId: String, robotId: String) -> AnyPublisher<DataManageModel.Output.Command, Error> {
        Logger.info(target: self)

        self.processing = true
        return Future<DataManageModel.Output.Command, Error> { promise in
            self.auth.getTokens()
                .flatMap { value -> AnyPublisher<APIResult<JobOrder_API.CommandEntity.Data>, Error> in
                    guard let token = value.idToken else {
                        return Future<APIResult<JobOrder_API.CommandEntity.Data>, Error> { promise in
                            let userInfo = ["__type": "getTokens", "message": "idToken is null."]
                            promise(.failure(NSError(domain: "Error", code: -1, userInfo: userInfo)))
                        }.eraseToAnyPublisher()
                    }
                    return self.taskAPI.getCommand(token, taskId: taskId, robotId: robotId).eraseToAnyPublisher()
                }.sink(receiveCompletion: { completion in
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        Logger.error(target: self, error.localizedDescription)
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    if let output = response.data {
                        promise(.success(.init(output)))
                    } else {
                        let userInfo = ["__type": "commandFromTask", "message": "API Resuponse is null"]
                        promise(.failure(NSError(domain: "Error", code: -1, userInfo: userInfo)))
                    }
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }

    /// Task情報の詳細を取得する
    /// - Parameters:
    ///   - taskId: Task ID
    public func commandsFromTask(taskId: String) -> AnyPublisher<[DataManageModel.Output.Command], Error> {
        Logger.info(target: self)

        self.processing = true
        return Future<[DataManageModel.Output.Command], Error> { promise in
            self.auth.getTokens()
                .flatMap { value -> AnyPublisher<APIResult<[JobOrder_API.CommandEntity.Data]>, Error> in
                    guard let token = value.idToken else {
                        return Future<APIResult<[JobOrder_API.CommandEntity.Data]>, Error> { promise in
                            let userInfo = ["__type": "getTokens", "message": "idToken is null."]
                            promise(.failure(NSError(domain: "Error", code: -1, userInfo: userInfo)))
                        }.eraseToAnyPublisher()
                    }
                    return self.taskAPI.getCommands(token, taskId: taskId).eraseToAnyPublisher()
                }.sink(receiveCompletion: { completion in
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        Logger.error(target: self, error.localizedDescription)
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    if let output = response.data?.compactMap({ DataManageModel.Output.Command($0) }) {
                        promise(.success(.init(output)))
                    } else {
                        let userInfo = ["__type": "commandsFromTask", "message": "API Response is null"]
                        promise(.failure(NSError(domain: "Error", code: -1, userInfo: userInfo)))
                    }
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }

    public func task(taskId: String) -> AnyPublisher<DataManageModel.Output.Task, Error> {
        Logger.info(target: self)

        self.processing = true
        return Future<DataManageModel.Output.Task, Error> { promise in
            self.auth.getTokens()
                .flatMap { value -> AnyPublisher<APIResult<JobOrder_API.TaskAPIEntity.Data>, Error> in
                    guard let token = value.idToken else {
                        return Future<APIResult<JobOrder_API.TaskAPIEntity.Data>, Error> { promise in
                            let userInfo = ["__type": "getTokens", "message": "idToken is null."]
                            promise(.failure(NSError(domain: "Error", code: -1, userInfo: userInfo)))
                        }.eraseToAnyPublisher()
                    }
                    return self.taskAPI.getTask(token, taskId: taskId).eraseToAnyPublisher()
                }.sink(receiveCompletion: { completion in
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        Logger.error(target: self, error.localizedDescription)
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    if let output = response.data {
                        promise(.success(.init(output)))
                    } else {
                        let userInfo = ["__type": "task", "message": "API Resuponse is null"]
                        promise(.failure(NSError(domain: "Error", code: -1, userInfo: userInfo)))
                    }
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
    /// RobotSystemの情報を取得する
    /// - Parameter id: Robot ID
    /// - Returns: System
    public func robotSystem(id: String) -> AnyPublisher<DataManageModel.Output.System, Error> {
        Logger.info(target: self)

        typealias SystemAPIResults = (APIResult<JobOrder_API.RobotAPIEntity.Swconf>,
                                      APIResult<[JobOrder_API.RobotAPIEntity.Asset]>)

        self.processing = true
        return Future<DataManageModel.Output.System, Error> { promise in
            self.auth.getTokens()
                .flatMap { value -> AnyPublisher<SystemAPIResults, Error> in
                    guard let token = value.idToken else {
                        return Future<SystemAPIResults, Error> { promise in
                            let userInfo = ["__type": "getTokens", "message": "idToken is null."]
                            promise(.failure(NSError(domain: "Error", code: -1, userInfo: userInfo)))
                        }.eraseToAnyPublisher()
                    }
                    return self.robotAPI.getRobotSwconf(token, id: id)
                        .zip(self.robotAPI.getRobotAssets(token, id: id))
                        .map { value in
                            return (value.0, value.1)
                        }.eraseToAnyPublisher()
                }.sink(receiveCompletion: { completion in
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        Logger.error(target: self, error.localizedDescription)
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    if let robotSwconf = response.0.data, let robotAssets = response.1.data {
                        promise(.success(.init(robotSwconf: robotSwconf, robotAssets: robotAssets)))
                    } else {
                        let userInfo = ["__type": "RobotCommand", "message": "API Resuponse is null"]
                        promise(.failure(NSError(domain: "Error", code: -1, userInfo: userInfo)))
                    }
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }

    /// Task情報を取得する
    /// - Parameter id: Job ID
    public func tasksFromJob(id: String, cursor: PagingModel.Cursor?) -> AnyPublisher<PagingModel.PaginatedResult<[DataManageModel.Output.Task]>, Error> {
        Logger.info(target: self)

        self.processing = true
        return Future<PagingModel.PaginatedResult<[DataManageModel.Output.Task]>, Error> { promise in
            self.auth.getTokens()
                .flatMap { value -> AnyPublisher<APIResult<[JobOrder_API.TaskAPIEntity.Data]>, Error> in
                    guard let token = value.idToken else {
                        return Future<APIResult<[JobOrder_API.TaskAPIEntity.Data]>, Error> { promise in
                            let userInfo = ["__type": "getTokens", "message": "idToken is null."]
                            promise(.failure(NSError(domain: "Error", code: -1, userInfo: userInfo)))
                        }.eraseToAnyPublisher()
                    }
                    return self.jobAPI.getTasks(token, id: id, paging: cursor?.toPaging()).eraseToAnyPublisher()
                }.sink(receiveCompletion: { completion in
                    self.processing = false
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        Logger.error(target: self, error.localizedDescription)
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    if let output = response.data?.compactMap({ DataManageModel.Output.Task($0) }) {
                        promise(.success(.init(data: output, paging: response.paging)))
                    } else {
                        let userInfo = ["__type": "task", "message": "API Resuponse is null"]
                        promise(.failure(NSError(domain: "Error", code: -1, userInfo: userInfo)))
                    }
                }).store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }

}

// MARK: - Private function
extension DataManageUseCase {

    /// APIで取得したデータをデータベースに保存する
    /// - Parameter results: Jobデータ、Robotデータ、ActionLibraryデータ、AILibraryデータ
    func saveData(results: APIResults) {

        if let data = results.0.data, results.0.time > jobData.timestamp {
            jobData.timestamp = results.0.time
            let entities = data.compactMap {
                return translator.toData(jobEntity: $0)
            }
            jobData.add(entities: entities)
        }

        if let data = results.1.data, results.1.time > robotData.timestamp {
            robotData.timestamp = results.1.time
            let entities: [JobOrder_Data.RobotEntity] = data.compactMap { entity in
                let state = robotData.read()?.first(where: { $0.id == entity.id })?.state
                return translator.toData(robotEntity: entity, state: state)
            }
            robotData.add(entities: entities)
        }

        if let data = results.2.data, results.2.time > actionLibraryData.timestamp {
            actionLibraryData.timestamp = results.2.time
            let entities = data.compactMap {
                return translator.toData(actionLibraryEntity: $0)
            }
            actionLibraryData.add(entities: entities)
        }

        if let data = results.3.data, results.3.time > aiLibraryData.timestamp {
            aiLibraryData.timestamp = results.3.time
            let entities = data.compactMap {
                return translator.toData(aiLibraryEntity: $0)
            }
            aiLibraryData.add(entities: entities)
        }
    }

    func saveRobot(result: APIResult<JobOrder_API.RobotAPIEntity.Data>) {

        if let data = result.data/*, result.time > robotData.timestamp*/ {
            robotData.timestamp = result.time
            let state = robotData.read()?.first(where: { $0.id == data.id })?.state
            if let entity = translator.toData(robotEntity: data, state: state) {
                robotData.add(entities: [entity])
            }
        }
    }
}
