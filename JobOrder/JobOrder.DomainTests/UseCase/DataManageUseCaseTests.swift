//
//  DataManageUseCaseTests.swift
//  JobOrder.DomainTests
//
//  Created by Yu Suzuki on 2020/08/08.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Domain
@testable import JobOrder_API
@testable import JobOrder_Data

class DataManageUseCaseTests: XCTestCase {

    private let ms1000 = 1.0
    private let auth = JobOrder_API.AuthenticationRepositoryMock()
    private let mqtt = JobOrder_API.MQTTRepositoryMock()
    private let robotAPI = JobOrder_API.RobotAPIRepositoryMock()
    private let jobAPI = JobOrder_API.JobAPIRepositoryMock()
    private let actionLibraryAPI = JobOrder_API.ActionLibraryAPIRepositoryMock()
    private let aiLibraryAPI = JobOrder_API.AILibraryAPIRepositoryMock()
    private let taskAPI = JobOrder_API.TaskAPIRepositoryMock()
    private let ud = JobOrder_Data.UserDefaultsRepositoryMock()
    private let robot = JobOrder_Data.RobotRepositoryMock()
    private let job = JobOrder_Data.JobRepositoryMock()
    private let actionLibrary = JobOrder_Data.ActionLibraryRepositoryMock()
    private let aiLibrary = JobOrder_Data.AILibraryRepositoryMock()
    private lazy var useCase = DataManageUseCase(authRepository: auth,
                                                 mqttRepository: mqtt,
                                                 robotAPIRepository: robotAPI,
                                                 jobAPIRepository: jobAPI,
                                                 actionLibraryAPIRepository: actionLibraryAPI,
                                                 aILibraryAPIRepository: aiLibraryAPI,
                                                 userDefaultsRepository: ud,
                                                 robotDataRepository: robot,
                                                 jobDataRepository: job,
                                                 actionLibraryDataRepository: actionLibrary,
                                                 aiLibraryDataRepository: aiLibrary,
                                                 taskDataRepository: taskAPI)
    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {

        jobAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.JobAPIEntity.Data]>, Error> { promise in }.eraseToAnyPublisher()
        }

        robotAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.RobotAPIEntity.Data]>, Error> { promise in }.eraseToAnyPublisher()
        }

        actionLibraryAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.ActionLibraryAPIEntity.Data]>, Error> { promise in }.eraseToAnyPublisher()
        }

        aiLibraryAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.AILibraryAPIEntity.Data]>, Error> { promise in }.eraseToAnyPublisher()
        }
    }

    override func tearDownWithError() throws {}

    func test_jobs() {

        job.readHandler = {
            return []
        }
        XCTAssertNotNil(useCase.jobs, "値が取得できていない")
    }

    func test_jobsNil() {

        job.readHandler = {
            return nil
        }
        XCTAssertNil(useCase.jobs, "値を取得できてはいけない")
    }

    func test_robots() {

        robot.readHandler = {
            return []
        }
        XCTAssertNotNil(useCase.robots, "値が取得できていない")
    }

    func test_robotsNil() {

        robot.readHandler = {
            return nil
        }
        XCTAssertNil(useCase.robots, "値を取得できてはいけない")
    }

    func test_actionLibraries() {

        actionLibrary.readHandler = {
            return []
        }
        XCTAssertNotNil(useCase.actionLibraries, "値が取得できていない")
    }

    func test_actionLibrariesNil() {

        actionLibrary.readHandler = {
            return nil
        }
        XCTAssertNil(useCase.actionLibraries, "値を取得できてはいけない")
    }

    func test_aiLibraries() {

        aiLibrary.readHandler = {
            return []
        }
        XCTAssertNotNil(useCase.aiLibraries, "値が取得できていない")
    }

    func test_aiLibrariesNil() {

        aiLibrary.readHandler = {
            return nil
        }
        XCTAssertNil(useCase.aiLibraries, "値を取得できてはいけない")
    }

    func test_observeJobData() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let entity = [JobOrder_Data.JobEntity()]

        job.observeHandler = {
            return Future<[JobOrder_Data.JobEntity]?, Never> { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // PublisherのReturnより前にsendされて失敗するのでDelayを入れる
                    handlerExpectation.fulfill()
                    promise(.success(entity))
                }
            }.eraseToAnyPublisher()
        }

        useCase.observeJobData()
            .sink { response in
                XCTAssertNotNil(response, "値が取得できていない")
                completionExpectation.fulfill()
            }.store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_observeJobDataNil() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        job.observeHandler = {
            return Future<[JobOrder_Data.JobEntity]?, Never> { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // PublisherのReturnより前にsendされて失敗するのでDelayを入れる
                    handlerExpectation.fulfill()
                    promise(.success(nil))
                }
            }.eraseToAnyPublisher()
        }

        useCase.observeJobData()
            .sink { response in
                XCTAssertNil(response, "値を取得できてはいけない")
                completionExpectation.fulfill()
            }.store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_observeJobDataNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        job.observeHandler = {
            return Future<[JobOrder_Data.JobEntity]?, Never> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.observeJobData()
            .sink { response in
                completionExpectation.fulfill()
            }.store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_observeRobotData() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let entity = [JobOrder_Data.RobotEntity()]

        robot.observeHandler = {
            return Future<[JobOrder_Data.RobotEntity]?, Never> { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // PublisherのReturnより前にsendされて失敗するのでDelayを入れる
                    handlerExpectation.fulfill()
                    promise(.success(entity))
                }
            }.eraseToAnyPublisher()
        }

        useCase.observeRobotData()
            .sink { response in
                XCTAssertNotNil(response, "値が取得できていない")
                completionExpectation.fulfill()
            }.store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_observeRobotDataNil() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        robot.observeHandler = {
            return Future<[JobOrder_Data.RobotEntity]?, Never> { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // PublisherのReturnより前にsendされて失敗するのでDelayを入れる
                    handlerExpectation.fulfill()
                    promise(.success(nil))
                }
            }.eraseToAnyPublisher()
        }

        useCase.observeRobotData()
            .sink { response in
                XCTAssertNil(response, "値を取得できてはいけない")
                completionExpectation.fulfill()
            }.store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_observeRobotDataNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        robot.observeHandler = {
            return Future<[JobOrder_Data.RobotEntity]?, Never> { promise in
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.observeRobotData()
            .sink { response in
                completionExpectation.fulfill()
            }.store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_syncData() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let jobFetchHandlerExpectation = expectation(description: "Job fetch handler")
        let robotFetchHandlerExpectation = expectation(description: "Robot fetch handler")
        let actionLibraryFetchHandlerExpectation = expectation(description: "ActionLibrary fetch handler")
        let aiLibraryFetchHandlerExpectation = expectation(description: "AILibrary fetch handler")
        let completionExpectation = expectation(description: "completion")

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        jobAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.JobAPIEntity.Data]>, Error> { promise in
                jobFetchHandlerExpectation.fulfill()
                let entity = APIResult<[JobAPIEntity.Data]>(time: 1, data: DomainTestsStub().jobs, count: 1)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.RobotAPIEntity.Data]>, Error> { promise in
                robotFetchHandlerExpectation.fulfill()
                let entity = APIResult<[RobotAPIEntity.Data]>(time: 1, data: DomainTestsStub().robots, count: 1)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        actionLibraryAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.ActionLibraryAPIEntity.Data]>, Error> { promise in
                actionLibraryFetchHandlerExpectation.fulfill()
                let entity = APIResult<[ActionLibraryAPIEntity.Data]>(time: 1, data: DomainTestsStub().actionLibraries, count: 1)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        aiLibraryAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.AILibraryAPIEntity.Data]>, Error> { promise in
                aiLibraryFetchHandlerExpectation.fulfill()
                let entity = APIResult<[AILibraryAPIEntity.Data]>(time: 1, data: DomainTestsStub().aiLibraries, count: 1)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        job.readHandler = {
            return []
        }

        robot.readHandler = {
            return []
        }

        actionLibrary.readHandler = {
            return []
        }

        aiLibrary.readHandler = {
            return []
        }

        useCase.syncData()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertNotNil(response.jobs, "値が取得できていない")
                XCTAssertNotNil(response.robots, "値が取得できていない")
                XCTAssertNotNil(response.actionLibraries, "値が取得できていない")
                XCTAssertNotNil(response.aiLibraries, "値が取得できていない")
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, jobFetchHandlerExpectation, robotFetchHandlerExpectation, actionLibraryFetchHandlerExpectation, aiLibraryFetchHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_syncDataTokenError() {
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let jobFetchHandlerExpectation = expectation(description: "Job fetch handler")
        let robotFetchHandlerExpectation = expectation(description: "Robot fetch handler")
        let actionLibraryFetchHandlerExpectation = expectation(description: "ActionLibrary fetch handler")
        let aiLibraryFetchHandlerExpectation = expectation(description: "AILibrary fetch handler")
        let completionExpectation = expectation(description: "completion")
        jobFetchHandlerExpectation.isInverted = true
        robotFetchHandlerExpectation.isInverted = true
        actionLibraryFetchHandlerExpectation.isInverted = true
        aiLibraryFetchHandlerExpectation.isInverted = true
        let error = NSError(domain: "Error", code: -1, userInfo: nil)

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.syncData()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(error, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, jobFetchHandlerExpectation, robotFetchHandlerExpectation, actionLibraryFetchHandlerExpectation, aiLibraryFetchHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_syncDataJobFetchError() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let jobFetchHandlerExpectation = expectation(description: "Job fetch handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        jobAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.JobAPIEntity.Data]>, Error> { promise in
                jobFetchHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.syncData()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(error, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, jobFetchHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_syncDataRobotFetchError() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let jobFetchHandlerExpectation = expectation(description: "Job fetch handler")
        let robotFetchHandlerExpectation = expectation(description: "Robot fetch handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        jobAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.JobAPIEntity.Data]>, Error> { promise in
                jobFetchHandlerExpectation.fulfill()
                let entity = APIResult<[JobAPIEntity.Data]>(time: 1, data: DomainTestsStub().jobs, count: 1)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.RobotAPIEntity.Data]>, Error> { promise in
                robotFetchHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.syncData()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(error, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, jobFetchHandlerExpectation, robotFetchHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_syncDataActionLibraryFetchError() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let jobFetchHandlerExpectation = expectation(description: "Job fetch handler")
        let robotFetchHandlerExpectation = expectation(description: "Robot fetch handler")
        let actionLibraryFetchHandlerExpectation = expectation(description: "ActionLibrary fetch handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        jobAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.JobAPIEntity.Data]>, Error> { promise in
                jobFetchHandlerExpectation.fulfill()
                let entity = APIResult<[JobAPIEntity.Data]>(time: 1, data: DomainTestsStub().jobs, count: 1)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.RobotAPIEntity.Data]>, Error> { promise in
                robotFetchHandlerExpectation.fulfill()
                let entity = APIResult<[RobotAPIEntity.Data]>(time: 1, data: DomainTestsStub().robots, count: 1)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        actionLibraryAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.ActionLibraryAPIEntity.Data]>, Error> { promise in
                actionLibraryFetchHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.syncData()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(error, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, jobFetchHandlerExpectation, robotFetchHandlerExpectation, actionLibraryFetchHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_syncDataAILibraryFetchError() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let jobFetchHandlerExpectation = expectation(description: "Job fetch handler")
        let robotFetchHandlerExpectation = expectation(description: "Robot fetch handler")
        let actionLibraryFetchHandlerExpectation = expectation(description: "ActionLibrary fetch handler")
        let aiLibraryFetchHandlerExpectation = expectation(description: "AILibrary fetch handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        jobAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.JobAPIEntity.Data]>, Error> { promise in
                jobFetchHandlerExpectation.fulfill()
                let entity = APIResult<[JobAPIEntity.Data]>(time: 1, data: DomainTestsStub().jobs, count: 1)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.RobotAPIEntity.Data]>, Error> { promise in
                robotFetchHandlerExpectation.fulfill()
                let entity = APIResult<[RobotAPIEntity.Data]>(time: 1, data: DomainTestsStub().robots, count: 1)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        actionLibraryAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.ActionLibraryAPIEntity.Data]>, Error> { promise in
                actionLibraryFetchHandlerExpectation.fulfill()
                let entity = APIResult<[ActionLibraryAPIEntity.Data]>(time: 1, data: DomainTestsStub().actionLibraries, count: 1)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        aiLibraryAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.AILibraryAPIEntity.Data]>, Error> { promise in
                aiLibraryFetchHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.syncData()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(error, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, jobFetchHandlerExpectation, robotFetchHandlerExpectation, actionLibraryFetchHandlerExpectation, aiLibraryFetchHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_syncDataNotReceived() {
        let param = "test"

        XCTContext.runActivity(named: "Token通知が来ない場合") { _ in
            let tokenHandlerExpectation = expectation(description: "Token handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            auth.getTokensHandler = {
                return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                    tokenHandlerExpectation.fulfill()
                }.eraseToAnyPublisher()
            }

            useCase.syncData()
                .sink(receiveCompletion: { _ in
                    XCTFail("値を取得できてはいけない")
                    completionExpectation.fulfill()
                }, receiveValue: { _ in
                }).store(in: &cancellables)

            wait(for: [tokenHandlerExpectation, completionExpectation], timeout: ms1000)
        }

        XCTContext.runActivity(named: "fetch通知が来ない場合") { _ in
            let tokenHandlerExpectation = expectation(description: "Token handler")
            let completionExpectation = expectation(description: "completion")
            completionExpectation.isInverted = true

            auth.getTokensHandler = {
                return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                    tokenHandlerExpectation.fulfill()
                    let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                                 refreshToken: param,
                                                                                 idToken: param,
                                                                                 expiration: Date())
                    promise(.success(entity))
                }.eraseToAnyPublisher()
            }

            useCase.syncData()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("値を取得できてはいけない")
                    case .failure(let e):
                        XCTAssertNotNil(e, "値が取得できていない: \(e)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { _ in
                }).store(in: &cancellables)

            wait(for: [tokenHandlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_removeData() {}

    func test_robot() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getRobotHandlerExpectation = expectation(description: "Get robot handler")
        let completionExpectation = expectation(description: "completion")

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getRobotHandler = { token, id in
            return Future<APIResult<JobOrder_API.RobotAPIEntity.Data>, Error> { promise in
                getRobotHandlerExpectation.fulfill()
                let entity = APIResult<RobotAPIEntity.Data>(time: 1, data: DomainTestsStub().robot, count: 1)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robot.readHandler = {
            let entity = JobOrder_Data.RobotEntity()
            entity.id = "id"
            return [entity]
        }

        useCase.robot(id: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertNotNil(response, "値が取得できていない")
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getRobotHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_robotNotReceive() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getRobotHandlerExpectation = expectation(description: "Get robot handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getRobotHandler = { token, id in
            return Future<APIResult<JobOrder_API.RobotAPIEntity.Data>, Error> { promise in
                getRobotHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.robot(id: param)
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getRobotHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_robotError() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getRobotHandlerExpectation = expectation(description: "Get robot handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getRobotHandler = { token, id in
            return Future<APIResult<JobOrder_API.RobotAPIEntity.Data>, Error> { promise in
                getRobotHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.robot(id: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(error, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getRobotHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_robotCommand() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getRobotCommandsHandlerExpectation = expectation(description: "Get command handler")
        let completionExpectation = expectation(description: "completion")

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getCommandFromRobotHandler = { token, id in
            return Future<APIResult<[JobOrder_API.CommandAPIEntity.Data]>, Error> { promise in
                getRobotCommandsHandlerExpectation.fulfill()
                let entity = APIResult<[CommandAPIEntity.Data]>(time: 1, data: DomainTestsStub().commands, count: 1)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        useCase.commandFromRobot(id: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertNotNil(response, "値が取得できていない")
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getRobotCommandsHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_robotCommandNotReceive() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getRobotCommandsHandlerExpectation = expectation(description: "Get command handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getCommandFromRobotHandler = { token, id in
            return Future<APIResult<[JobOrder_API.CommandAPIEntity.Data]>, Error> { promise in
                getRobotCommandsHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.commandFromRobot(id: param)
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getRobotCommandsHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_robotCommandError() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getRobotCommandsHandlerExpectation = expectation(description: "Get image handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getCommandFromRobotHandler = { token, id in
            return Future<APIResult<[JobOrder_API.CommandAPIEntity.Data]>, Error> { promise in
                getRobotCommandsHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.commandFromRobot(id: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(error, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getRobotCommandsHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    /// - MARK Tests For CommandFromTask
    func test_taskCommand() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getTaskCommandsHandlerExpectation = expectation(description: "Get Task command handler")
        let completionExpectation = expectation(description: "completion")

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        taskAPI.getCommandsFromTaskHandler = { token, taskId, robotId in
            return Future<APIResult<TaskAPIEntity.Data>, Error> { promise in
                getTaskCommandsHandlerExpectation.fulfill()
                let entity = APIResult<TaskAPIEntity.Data>(time: 1, data: DomainTestsStub().task, count: 1)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        useCase.commandFromTask(taskId: param, robotId: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertNotNil(response, "値が取得できていない")
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getTaskCommandsHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_taskCommandNotReceive() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getTaskCommandsHandlerExpectation = expectation(description: "Get Task command handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        taskAPI.getCommandsFromTaskHandler = { token, taskId, robotId in
            return Future<APIResult<JobOrder_API.TaskAPIEntity.Data>, Error> { promise in
                getTaskCommandsHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.commandFromTask(taskId: param, robotId: param)
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getTaskCommandsHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_taskCommandError() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getTaskCommandsHandlerExpectation = expectation(description: "Get Task image handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        taskAPI.getCommandsFromTaskHandler = { token, taskId, robotId in
            return Future<APIResult<JobOrder_API.TaskAPIEntity.Data>, Error> { promise in
                getTaskCommandsHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.commandFromTask(taskId: param, robotId: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(error, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getTaskCommandsHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_robotImage() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getImageHandlerExpectation = expectation(description: "Get image handler")
        let completionExpectation = expectation(description: "completion")

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getImageHandler = { token, id in
            return Future<Data, Error> { promise in
                getImageHandlerExpectation.fulfill()
                let entity = Data()
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        useCase.robotImage(id: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertNotNil(response, "値が取得できていない")
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getImageHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_robotImageNotReceive() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getImageHandlerExpectation = expectation(description: "Get image handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getImageHandler = { token, id in
            return Future<Data, Error> { promise in
                getImageHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.robotImage(id: param)
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getImageHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_robotImageError() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getImageHandlerExpectation = expectation(description: "Get image handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getImageHandler = { token, id in
            return Future<Data, Error> { promise in
                getImageHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.robotImage(id: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(error, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getImageHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_robotSystem() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getRobotSwconfHandlerExpectation = expectation(description: "Get swconf handler")
        let getRobotAssetsHandlerExpectation = expectation(description: "Get assets handler")
        let completionExpectation = expectation(description: "completion")

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getRobotSwconfHandler = { token, id in
            return Future<APIResult<JobOrder_API.RobotAPIEntity.Swconf>, Error> { promise in
                getRobotSwconfHandlerExpectation.fulfill()
                let entity = APIResult<RobotAPIEntity.Swconf>(time: 1, data: DomainTestsStub().swconf, count: nil)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getRobotAssetsHandler = { token, id in
            return Future<APIResult<[JobOrder_API.RobotAPIEntity.Asset]>, Error> { promise in
                getRobotAssetsHandlerExpectation.fulfill()
                let entity = APIResult<[RobotAPIEntity.Asset]>(time: 1, data: DomainTestsStub().assets, count: 1)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        useCase.robotSystem(id: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertNotNil(response, "値が取得できていない")
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getRobotSwconfHandlerExpectation, getRobotAssetsHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_robotSystemNotReceiveBoth() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getRobotSwconfHandlerExpectation = expectation(description: "Get swconf handler")
        let getRobotAssetsHandlerExpectation = expectation(description: "Get assets handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getRobotSwconfHandler = { token, id in
            return Future<APIResult<JobOrder_API.RobotAPIEntity.Swconf>, Error> { promise in
                getRobotSwconfHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        robotAPI.getRobotAssetsHandler = { token, id in
            return Future<APIResult<[JobOrder_API.RobotAPIEntity.Asset]>, Error> { promise in
                getRobotAssetsHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.robotSystem(id: param)
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getRobotSwconfHandlerExpectation, getRobotAssetsHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_robotSystemNotReceiveSwconf() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getRobotSwconfHandlerExpectation = expectation(description: "Get swconf handler")
        let getRobotAssetsHandlerExpectation = expectation(description: "Get assets handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getRobotSwconfHandler = { token, id in
            return Future<APIResult<JobOrder_API.RobotAPIEntity.Swconf>, Error> { promise in
                getRobotSwconfHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        robotAPI.getRobotAssetsHandler = { token, id in
            return Future<APIResult<[JobOrder_API.RobotAPIEntity.Asset]>, Error> { promise in
                getRobotAssetsHandlerExpectation.fulfill()
                let entity = APIResult<[RobotAPIEntity.Asset]>(time: 1, data: DomainTestsStub().assets, count: 1)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        useCase.robotSystem(id: param)
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getRobotSwconfHandlerExpectation, getRobotAssetsHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_robotSystemNotReceiveAssets() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getRobotSwconfHandlerExpectation = expectation(description: "Get swconf handler")
        let getRobotAssetsHandlerExpectation = expectation(description: "Get assets handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getRobotSwconfHandler = { token, id in
            return Future<APIResult<JobOrder_API.RobotAPIEntity.Swconf>, Error> { promise in
                getRobotSwconfHandlerExpectation.fulfill()
                let entity = APIResult<RobotAPIEntity.Swconf>(time: 1, data: DomainTestsStub().swconf, count: nil)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getRobotAssetsHandler = { token, id in
            return Future<APIResult<[JobOrder_API.RobotAPIEntity.Asset]>, Error> { promise in
                getRobotAssetsHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.robotSystem(id: param)
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getRobotSwconfHandlerExpectation, getRobotAssetsHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_robotSystemErrorBoth() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getRobotSwconfHandlerExpectation = expectation(description: "Get swconf handler")
        let getRobotAssetsHandlerExpectation = expectation(description: "Get assets handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getRobotSwconfHandler = { token, id in
            return Future<APIResult<JobOrder_API.RobotAPIEntity.Swconf>, Error> { promise in
                getRobotSwconfHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        robotAPI.getRobotAssetsHandler = { token, id in
            return Future<APIResult<[JobOrder_API.RobotAPIEntity.Asset]>, Error> { promise in
                getRobotAssetsHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.robotSystem(id: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(error, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getRobotSwconfHandlerExpectation, getRobotAssetsHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_robotSystemErrorSwconf() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getRobotSwconfHandlerExpectation = expectation(description: "Get swconf handler")
        let getRobotAssetsHandlerExpectation = expectation(description: "Get assets handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getRobotSwconfHandler = { token, id in
            return Future<APIResult<JobOrder_API.RobotAPIEntity.Swconf>, Error> { promise in
                getRobotSwconfHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        robotAPI.getRobotAssetsHandler = { token, id in
            return Future<APIResult<[JobOrder_API.RobotAPIEntity.Asset]>, Error> { promise in
                getRobotAssetsHandlerExpectation.fulfill()
                let entity = APIResult<[RobotAPIEntity.Asset]>(time: 1, data: DomainTestsStub().assets, count: 1)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        useCase.robotSystem(id: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(error, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getRobotSwconfHandlerExpectation, getRobotAssetsHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_robotSystemErrorAssets() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getRobotSwconfHandlerExpectation = expectation(description: "Get swconf handler")
        let getRobotAssetsHandlerExpectation = expectation(description: "Get assets handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)

        auth.getTokensHandler = {
            return Future<JobOrder_API.AuthenticationEntity.Output.Tokens, Error> { promise in
                tokenHandlerExpectation.fulfill()
                let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(accessToken: param,
                                                                             refreshToken: param,
                                                                             idToken: param,
                                                                             expiration: Date())
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getRobotSwconfHandler = { token, id in
            return Future<APIResult<JobOrder_API.RobotAPIEntity.Swconf>, Error> { promise in
                getRobotSwconfHandlerExpectation.fulfill()
                let entity = APIResult<RobotAPIEntity.Swconf>(time: 1, data: DomainTestsStub().swconf, count: nil)
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getRobotAssetsHandler = { token, id in
            return Future<APIResult<[JobOrder_API.RobotAPIEntity.Asset]>, Error> { promise in
                getRobotAssetsHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.robotSystem(id: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(error, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getRobotSwconfHandlerExpectation, getRobotAssetsHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_saveData() {
        let jobsResult = APIResult<[JobAPIEntity.Data]>(time: 1, data: DomainTestsStub().jobs, count: 1)
        let robotsResult = APIResult<[RobotAPIEntity.Data]>(time: 1, data: DomainTestsStub().robots, count: 1)
        let actionLibrariesResult = APIResult<[ActionLibraryAPIEntity.Data]>(time: 1, data: DomainTestsStub().actionLibraries, count: 1)
        let aiLibrariesResult = APIResult<[AILibraryAPIEntity.Data]>(time: 1, data: DomainTestsStub().aiLibraries, count: 1)
        job.timestamp = 0
        robot.timestamp = 0
        actionLibrary.timestamp = 0
        aiLibrary.timestamp = 0

        useCase.saveData(results: (jobsResult,
                                   robotsResult,
                                   actionLibrariesResult,
                                   aiLibrariesResult))

        XCTAssertEqual(job.timestampSetCallCount, 2, "JobRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(job.addCallCount, 1, "JobRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(robot.timestampSetCallCount, 2, "RobotRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(robot.readCallCount, 1, "RobotRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(robot.addCallCount, 1, "RobotRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(actionLibrary.timestampSetCallCount, 2, "ActionLibraryRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(actionLibrary.addCallCount, 1, "ActionLibraryRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(aiLibrary.timestampSetCallCount, 2, "AILibraryRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(aiLibrary.addCallCount, 1, "AILibraryRepositoryのメソッドが呼ばれない")
    }

    func test_saveDataOldJobTimestamp() {
        let jobsResult = APIResult<[JobAPIEntity.Data]>(time: 1, data: DomainTestsStub().jobs, count: 1)
        let robotsResult = APIResult<[RobotAPIEntity.Data]>(time: 1, data: DomainTestsStub().robots, count: 1)
        let actionLibrariesResult = APIResult<[ActionLibraryAPIEntity.Data]>(time: 1, data: DomainTestsStub().actionLibraries, count: 1)
        let aiLibrariesResult = APIResult<[AILibraryAPIEntity.Data]>(time: 1, data: DomainTestsStub().aiLibraries, count: 1)
        job.timestamp = 1
        robot.timestamp = 1
        actionLibrary.timestamp = 1
        aiLibrary.timestamp = 1

        useCase.saveData(results: (jobsResult,
                                   robotsResult,
                                   actionLibrariesResult,
                                   aiLibrariesResult))

        XCTAssertEqual(job.timestampSetCallCount, 1, "JobRepositoryのメソッドが呼ばれてしまう")
        XCTAssertEqual(job.addCallCount, 0, "JobRepositoryのメソッドが呼ばれてしまう")
        XCTAssertEqual(robot.timestampSetCallCount, 1, "RobotRepositoryのメソッドが呼ばれてしまう")
        XCTAssertEqual(robot.readCallCount, 0, "RobotRepositoryのメソッドが呼ばれてしまう")
        XCTAssertEqual(robot.addCallCount, 0, "RobotRepositoryのメソッドが呼ばれてしまう")
        XCTAssertEqual(actionLibrary.timestampSetCallCount, 1, "ActionLibraryRepositoryのメソッドが呼ばれてしまう")
        XCTAssertEqual(actionLibrary.addCallCount, 0, "ActionLibraryRepositoryのメソッドが呼ばれてしまう")
        XCTAssertEqual(aiLibrary.timestampSetCallCount, 1, "AILibraryRepositoryのメソッドが呼ばれてしまう")
        XCTAssertEqual(aiLibrary.addCallCount, 0, "AILibraryRepositoryのメソッドが呼ばれてしまう")
    }

    func test_saveDataNil() {
        let jobsResult = APIResult<[JobAPIEntity.Data]>(time: 1, data: nil, count: 1)
        let robotsResult = APIResult<[RobotAPIEntity.Data]>(time: 1, data: nil, count: 1)
        let actionLibrariesResult = APIResult<[ActionLibraryAPIEntity.Data]>(time: 1, data: nil, count: 1)
        let aiLibrariesResult = APIResult<[AILibraryAPIEntity.Data]>(time: 1, data: nil, count: 1)

        useCase.saveData(results: (jobsResult,
                                   robotsResult,
                                   actionLibrariesResult,
                                   aiLibrariesResult))

        XCTAssertEqual(job.timestampSetCallCount, 0, "JobRepositoryのメソッドが呼ばれてしまう")
        XCTAssertEqual(job.addCallCount, 0, "JobRepositoryのメソッドが呼ばれてしまう")
        XCTAssertEqual(robot.timestampSetCallCount, 0, "RobotRepositoryのメソッドが呼ばれてしまう")
        XCTAssertEqual(robot.readCallCount, 0, "RobotRepositoryのメソッドが呼ばれてしまう")
        XCTAssertEqual(robot.addCallCount, 0, "RobotRepositoryのメソッドが呼ばれてしまう")
        XCTAssertEqual(actionLibrary.timestampSetCallCount, 0, "ActionLibraryRepositoryのメソッドが呼ばれてしまう")
        XCTAssertEqual(actionLibrary.addCallCount, 0, "ActionLibraryRepositoryのメソッドが呼ばれてしまう")
        XCTAssertEqual(aiLibrary.timestampSetCallCount, 0, "AILibraryRepositoryのメソッドが呼ばれてしまう")
        XCTAssertEqual(aiLibrary.addCallCount, 0, "AILibraryRepositoryのメソッドが呼ばれてしまう")
    }
}
