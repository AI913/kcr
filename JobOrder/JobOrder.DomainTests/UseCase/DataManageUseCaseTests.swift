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
                                                 taskAPIRepository: taskAPI,
                                                 userDefaultsRepository: ud,
                                                 robotDataRepository: robot,
                                                 jobDataRepository: job,
                                                 actionLibraryDataRepository: actionLibrary,
                                                 aiLibraryDataRepository: aiLibrary)
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
                let entity: APIResult<[JobAPIEntity.Data]> = APIResult.arbitrary.generate
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.RobotAPIEntity.Data]>, Error> { promise in
                robotFetchHandlerExpectation.fulfill()
                let entity: APIResult<[RobotAPIEntity.Data]> = APIResult.arbitrary.generate
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        actionLibraryAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.ActionLibraryAPIEntity.Data]>, Error> { promise in
                actionLibraryFetchHandlerExpectation.fulfill()
                let entity: APIResult<[ActionLibraryAPIEntity.Data]> = APIResult.arbitrary.generate
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        aiLibraryAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.AILibraryAPIEntity.Data]>, Error> { promise in
                aiLibraryFetchHandlerExpectation.fulfill()
                let entity: APIResult<[AILibraryAPIEntity.Data]> = APIResult.arbitrary.generate
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
        let expected = JobOrderError.internalError(error: error) as NSError

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
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
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
        let expected = JobOrderError.internalError(error: error) as NSError

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
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
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
        let expected = JobOrderError.internalError(error: error) as NSError

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
                let entity: APIResult<[JobAPIEntity.Data]> = APIResult.arbitrary.generate
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
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
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
        let expected = JobOrderError.internalError(error: error) as NSError

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
                let entity: APIResult<[JobAPIEntity.Data]> = APIResult.arbitrary.generate
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.RobotAPIEntity.Data]>, Error> { promise in
                robotFetchHandlerExpectation.fulfill()
                let entity: APIResult<[RobotAPIEntity.Data]> = APIResult.arbitrary.generate
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
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
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
        let expected = JobOrderError.internalError(error: error) as NSError

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
                let entity: APIResult<[JobAPIEntity.Data]> = APIResult.arbitrary.generate
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.RobotAPIEntity.Data]>, Error> { promise in
                robotFetchHandlerExpectation.fulfill()
                let entity: APIResult<[RobotAPIEntity.Data]> = APIResult.arbitrary.generate
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        actionLibraryAPI.fetchHandler = { token in
            return Future<APIResult<[JobOrder_API.ActionLibraryAPIEntity.Data]>, Error> { promise in
                actionLibraryFetchHandlerExpectation.fulfill()
                let entity: APIResult<[ActionLibraryAPIEntity.Data]> = APIResult.arbitrary.generate
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
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
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
        let robotEntity: APIResult<RobotAPIEntity.Data> = APIResult.arbitrary.generate

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
                promise(.success(robotEntity))
            }.eraseToAnyPublisher()
        }

        robot.readHandler = {
            let entity = JobOrder_Data.RobotEntity()
            entity.id = robotEntity.data!.id
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
        let expected = JobOrderError.internalError(error: error) as NSError

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
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getRobotHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_robotCommand() {
        let param = "test"
        let size = 5

        let (expectedPage, expectedSize) = (3, size)
        let (expectedOffset, expectedLimit) = (15, size)
        let expectedTotal = size * 10

        let offset = 10	// (expectedPage - 1) * size
        let page = 4	// expectedOffset / size + 1
        let totalPages = 10

        let cursor = PagingModel.Cursor(offset: offset, limit: size)
        let status: [CommandModel.Status.Value] = [.Open, .Close]

        let pagingOutput = APIPaging.Output(page: page, size: size, totalPages: totalPages, totalCount: expectedTotal)

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
        robotAPI.getCommandsHandler = { token, id, status, paging in
            return Future<APIResult<[JobOrder_API.CommandEntity.Data]>, Error> { promise in
                getRobotCommandsHandlerExpectation.fulfill()
                let data = CommandEntity.Data.arbitrary.sample
                let entity = APIResult<[CommandEntity.Data]>(time: 1, data: data, count: data.count, paging: pagingOutput)
                promise(.success(entity))
                XCTAssertEqual(status?.sorted(), ["open", "close"].sorted(), "正しい値が設定されていない")
                XCTAssertEqual(paging, APIPaging.Input(page: expectedPage, size: expectedSize), "正しい値が設定されていない")
            }.eraseToAnyPublisher()
        }

        useCase.commandFromRobot(id: param, status: status, cursor: cursor)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertNotNil(response, "値が取得できていない")
                XCTAssertEqual(response.cursor, PagingModel.Cursor(offset: expectedOffset, limit: expectedLimit), "正しい値が設定されていない")
                XCTAssertEqual(response.total, expectedTotal, "正しい値が設定されていない")
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

        robotAPI.getCommandsHandler = { token, id, _, _ in
            return Future<APIResult<[JobOrder_API.CommandEntity.Data]>, Error> { promise in
                getRobotCommandsHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.commandFromRobot(id: param, status: nil, cursor: nil)
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
        let expected = JobOrderError.internalError(error: error) as NSError

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

        robotAPI.getCommandsHandler = { token, id, _, _ in
            return Future<APIResult<[JobOrder_API.CommandEntity.Data]>, Error> { promise in
                getRobotCommandsHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.commandFromRobot(id: param, status: nil, cursor: nil)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
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

        taskAPI.getCommandHandler = { token, taskId, robotId in
            return Future<APIResult<CommandEntity.Data>, Error> { promise in
                getTaskCommandsHandlerExpectation.fulfill()
                let entity: APIResult<CommandEntity.Data> = APIResult.arbitrary.generate
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

        taskAPI.getCommandHandler = { token, taskId, robotId in
            return Future<APIResult<JobOrder_API.CommandEntity.Data>, Error> { promise in
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
        let expected = JobOrderError.internalError(error: error) as NSError

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

        taskAPI.getCommandHandler = { token, taskId, robotId in
            return Future<APIResult<JobOrder_API.CommandEntity.Data>, Error> { promise in
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
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getTaskCommandsHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    /// - MARK Tests For CommandsFromTask
    func test_taskCommands() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getTaskCommandsHandlerExpectation = expectation(description: "Get Task commands handler")
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

        taskAPI.getCommandsHandler = { token, taskId in
            return Future<APIResult<[CommandEntity.Data]>, Error> { promise in
                getTaskCommandsHandlerExpectation.fulfill()
                let entity: APIResult<[CommandEntity.Data]> = APIResult.arbitrary.generate
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        useCase.commandsFromTask(taskId: param)
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

    func test_taskCommandsNotReceive() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getTaskCommandsHandlerExpectation = expectation(description: "Get Task commands handler")
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

        taskAPI.getCommandsHandler = { token, taskId in
            return Future<APIResult<[CommandEntity.Data]>, Error> { promise in
                getTaskCommandsHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.commandsFromTask(taskId: param)
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getTaskCommandsHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_taskCommandsError() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getTaskCommandsHandlerExpectation = expectation(description: "Get Task commands handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)
        let expected = JobOrderError.internalError(error: error) as NSError

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

        taskAPI.getCommandsHandler = { token, taskId in
            return Future<APIResult<[CommandEntity.Data]>, Error> { promise in
                getTaskCommandsHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.commandsFromTask(taskId: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
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
        let expected = JobOrderError.internalError(error: error) as NSError

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
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
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
                let entity: APIResult<RobotAPIEntity.Swconf> = APIResult.arbitrary.generate
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        robotAPI.getRobotAssetsHandler = { token, id in
            return Future<APIResult<[JobOrder_API.RobotAPIEntity.Asset]>, Error> { promise in
                getRobotAssetsHandlerExpectation.fulfill()
                let entity: APIResult<[RobotAPIEntity.Asset]> = APIResult.arbitrary.generate
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
                let entity: APIResult<[RobotAPIEntity.Asset]> = APIResult.arbitrary.generate
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
                let entity: APIResult<RobotAPIEntity.Swconf> = APIResult.arbitrary.generate
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
        let expected = JobOrderError.internalError(error: error) as NSError

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
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
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
        let expected = JobOrderError.internalError(error: error) as NSError

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
                let entity: APIResult<[RobotAPIEntity.Asset]> = APIResult.arbitrary.generate
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        useCase.robotSystem(id: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
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
        let expected = JobOrderError.internalError(error: error) as NSError

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
                let entity: APIResult<RobotAPIEntity.Swconf> = APIResult.arbitrary.generate
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
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getRobotSwconfHandlerExpectation, getRobotAssetsHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_tasksFromJob() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getTasksFromJobHandlerExpectation = expectation(description: "Get Tasks from job handler")
        let completionExpectation = expectation(description: "completion")

        let cursor = PagingModel.Cursor(offset: 0, limit: 10)

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

        jobAPI.getTasksHandler = { token, id, paging in
            return Future<APIResult<[TaskAPIEntity.Data]>, Error> { promise in
                getTasksFromJobHandlerExpectation.fulfill()
                let entity: APIResult<[TaskAPIEntity.Data]> = APIResult.arbitrary.generate
                promise(.success(entity))
                XCTAssertEqual(paging, APIPaging.Input(page: 1, size: 10))
            }.eraseToAnyPublisher()
        }

        useCase.tasksFromJob(id: param, cursor: cursor)
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

        wait(for: [tokenHandlerExpectation, getTasksFromJobHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_tasksFromJobNotReceive() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getTasksFromJobHandlerExpectation = expectation(description: "Get Tasks from job handler")
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

        jobAPI.getTasksHandler = { token, id, _ in
            return Future<APIResult<[TaskAPIEntity.Data]>, Error> { promise in
                getTasksFromJobHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.tasksFromJob(id: param, cursor: nil)
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getTasksFromJobHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_tasksFromJobError() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getTasksFromJobHandlerExpectation = expectation(description: "Get Tasks from job handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)
        let expected = JobOrderError.internalError(error: error) as NSError

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

        jobAPI.getTasksHandler = { token, id, _ in
            return Future<APIResult<[TaskAPIEntity.Data]>, Error> { promise in
                getTasksFromJobHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.tasksFromJob(id: param, cursor: nil)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getTasksFromJobHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_postTask() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let postTaskHandlerExpectation = expectation(description: "Post task handler")
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

        taskAPI.postTaskHandler = {token, task  in
            return Future<APIResult<TaskAPIEntity.Data>, Error> { promise in
                postTaskHandlerExpectation.fulfill()
                let entity: APIResult<TaskAPIEntity.Data> = APIResult.arbitrary.generate
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        let postData = DataManageModel.Input.Task.arbitrary.generate
        useCase.postTask(postData: postData)
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

        wait(for: [tokenHandlerExpectation, postTaskHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_postTaskNotReceive() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let postTaskHandlerExpectation = expectation(description: "Post Task handler")
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

        taskAPI.postTaskHandler = { token, id in
            return Future<APIResult<TaskAPIEntity.Data>, Error> { promise in
                postTaskHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        let postData = DataManageModel.Input.Task.arbitrary.generate
        useCase.postTask(postData: postData)
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, postTaskHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_postTaskError() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let postTaskHandlerExpectation = expectation(description: "Post task handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)
        let expected = JobOrderError.internalError(error: error) as NSError

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

        taskAPI.postTaskHandler = { token, id in
            return Future<APIResult<TaskAPIEntity.Data>, Error> { promise in
                postTaskHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        let postData = DataManageModel.Input.Task.arbitrary.generate
        useCase.postTask(postData: postData)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, postTaskHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_postJob() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let postTaskHandlerExpectation = expectation(description: "Post task handler")
        let completionExpectation = expectation(description: "completion")
        let job = DataManageModel.Input.Job.arbitrary.generate

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

        jobAPI.postHandler = {_, argJob  in
            XCTAssert(job == argJob, "正しい値が取得できていない: \(argJob)")
            return Future<APIResult<JobAPIEntity.Data>, Error> { promise in
                postTaskHandlerExpectation.fulfill()
                let entity: APIResult<JobAPIEntity.Data> = APIResult.arbitrary.generate
                promise(.success(entity))
            }.eraseToAnyPublisher()
        }

        useCase.postJob(postData: job)
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

        wait(for: [tokenHandlerExpectation, postTaskHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_postJobNotReceive() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let postTaskHandlerExpectation = expectation(description: "Post task handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let job = DataManageModel.Input.Job.arbitrary.generate

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

        jobAPI.postHandler = {_, _  in
            return Future<APIResult<JobAPIEntity.Data>, Error> { promise in
                postTaskHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.postJob(postData: job)
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, postTaskHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_postJobError() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let postTaskHandlerExpectation = expectation(description: "Post task handler")
        let completionExpectation = expectation(description: "completion")
        let job = DataManageModel.Input.Job.arbitrary.generate
        let error = NSError(domain: "Error", code: -1, userInfo: nil)
        let expected = JobOrderError.internalError(error: error) as NSError

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

        jobAPI.postHandler = {_, _  in
            return Future<APIResult<JobAPIEntity.Data>, Error> { promise in
                postTaskHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.postJob(postData: job)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, postTaskHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_saveData() {
        let timestamp = FakeFactory.shared.epochTimeGen.generate
        let jobsResult: APIResult<[JobAPIEntity.Data]> = APIResult.arbitrary.suchThat({ $0.time > timestamp }).generate
        let robotsResult: APIResult<[RobotAPIEntity.Data]> = APIResult.arbitrary.suchThat({ $0.time > timestamp }).generate
        let actionLibrariesResult: APIResult<[ActionLibraryAPIEntity.Data]> = APIResult.arbitrary.suchThat({ $0.time > timestamp }).generate
        let aiLibrariesResult: APIResult<[AILibraryAPIEntity.Data]> = APIResult.arbitrary.suchThat({ $0.time > timestamp }).generate
        job.timestamp = timestamp
        robot.timestamp = timestamp
        actionLibrary.timestamp = timestamp
        aiLibrary.timestamp = timestamp

        useCase.saveData(results: (jobsResult,
                                   robotsResult,
                                   actionLibrariesResult,
                                   aiLibrariesResult))

        XCTAssertEqual(job.timestampSetCallCount, 2, "JobRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(job.addCallCount, 1, "JobRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(robot.timestampSetCallCount, 2, "RobotRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(robot.readCallCount, robotsResult.count, "RobotRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(robot.addCallCount, 1, "RobotRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(actionLibrary.timestampSetCallCount, 2, "ActionLibraryRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(actionLibrary.addCallCount, 1, "ActionLibraryRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(aiLibrary.timestampSetCallCount, 2, "AILibraryRepositoryのメソッドが呼ばれない")
        XCTAssertEqual(aiLibrary.addCallCount, 1, "AILibraryRepositoryのメソッドが呼ばれない")
    }

    func test_saveDataOldJobTimestamp() {
        let timestamp = FakeFactory.shared.epochTimeGen.generate
        let jobsResult: APIResult<[JobAPIEntity.Data]> = APIResult.arbitrary.suchThat({ $0.time <= timestamp }).generate
        let robotsResult: APIResult<[RobotAPIEntity.Data]> = APIResult.arbitrary.suchThat({ $0.time <= timestamp }).generate
        let actionLibrariesResult: APIResult<[ActionLibraryAPIEntity.Data]> = APIResult.arbitrary.suchThat({ $0.time <= timestamp }).generate
        let aiLibrariesResult: APIResult<[AILibraryAPIEntity.Data]> = APIResult.arbitrary.suchThat({ $0.time <= timestamp }).generate
        job.timestamp = timestamp
        robot.timestamp = timestamp
        actionLibrary.timestamp = timestamp
        aiLibrary.timestamp = timestamp

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
        let jobsResult = APIResult<[JobAPIEntity.Data]>(time: 1, data: nil, count: 1, paging: nil)
        let robotsResult = APIResult<[RobotAPIEntity.Data]>(time: 1, data: nil, count: 1, paging: nil)
        let actionLibrariesResult = APIResult<[ActionLibraryAPIEntity.Data]>(time: 1, data: nil, count: 1, paging: nil)
        let aiLibrariesResult = APIResult<[AILibraryAPIEntity.Data]>(time: 1, data: nil, count: 1, paging: nil)

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

    func test_executionLogsFromTask() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getExecutionsFromTaskHandlerExpectation = expectation(description: "Get Executions from task handler")
        let completionExpectation = expectation(description: "completion")

        let cursor = PagingModel.Cursor(offset: 0, limit: 10)

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

        taskAPI.getExecutionLogsHandler = { _, _, _, paging in
            return Future<APIResult<[ExecutionEntity.LogData]>, Error> { promise in
                getExecutionsFromTaskHandlerExpectation.fulfill()
                let entity: APIResult<[ExecutionEntity.LogData]> = APIResult.arbitrary.generate
                promise(.success(entity))
                XCTAssertEqual(paging, APIPaging.Input(page: 1, size: 10))
            }.eraseToAnyPublisher()
        }

        useCase.executionLogsFromTask(taskId: param, robotId: param, cursor: cursor)
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

        wait(for: [tokenHandlerExpectation, getExecutionsFromTaskHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_executionLogsFromTaskError() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getExecutionsFromTaskHandlerExpectation = expectation(description: "Get Executions from task handler")
        let completionExpectation = expectation(description: "completion")
        let error = NSError(domain: "Error", code: -1, userInfo: nil)
        let expected = JobOrderError.internalError(error: error) as NSError

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

        taskAPI.getExecutionLogsHandler = { _, _, _, _ in
            return Future<APIResult<[ExecutionEntity.LogData]>, Error> { promise in
                getExecutionsFromTaskHandlerExpectation.fulfill()
                promise(.failure(error))
            }.eraseToAnyPublisher()
        }

        useCase.executionLogsFromTask(taskId: param, robotId: param, cursor: nil)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let e):
                    XCTAssertEqual(expected, e as NSError, "正しい値が取得できていない: \(e)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getExecutionsFromTaskHandlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_executionLogsFromTaskNotReceive() {
        let param = "test"
        let tokenHandlerExpectation = expectation(description: "Token handler")
        let getExecutionsFromTaskHandlerExpectation = expectation(description: "Get Executions from task handler")
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

        taskAPI.getExecutionLogsHandler = { _, _, _, _ in
            return Future<APIResult<[ExecutionEntity.LogData]>, Error> { promise in
                getExecutionsFromTaskHandlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }

        useCase.executionLogsFromTask(taskId: param, robotId: param, cursor: nil)
            .sink(receiveCompletion: { _ in
                XCTFail("値を取得できてはいけない")
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [tokenHandlerExpectation, getExecutionsFromTaskHandlerExpectation, completionExpectation], timeout: ms1000)
    }
}
