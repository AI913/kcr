//
//  APIRequestTests.swift
//  JobOrder.APITests
//
//  Created by Yu Suzuki on 2020/07/27.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
import Mockingjay
@testable import JobOrder_API

class APIRequestTests: XCTestCase {

    private let ms1000 = 1.0
    private let api = APIRequest()
    private lazy var robot = RobotAPIDataStore(api: api)
    private lazy var job = JobAPIDataStore(api: api)
    private lazy var actionLibrary = ActionLibraryAPIDataStore(api: api)
    private lazy var aiLibrary = AILibraryAPIDataStore(api: api)
    private lazy var task = TaskAPIDataStore(api: api)
    private var cancellables: Set<AnyCancellable> = []

    private let jobJson = "api_mock_examples_GET_jobs_jobid_response"
    private let robotAssetsJson = "api_mock_examples_GET_robots_robotid_assets_response"
    private let robotJson = "api_mock_examples_GET_robots_robotid_response"
    private let robotSwconfJson = "api_mock_examples_GET_robots_robotid_swconf_response"
    private let taskCommandJson = "api_mock_examples_GET_tasks_taskid_commands_robotid_response"
    private let taskJson = "api_mock_examples_GET_tasks_taskid_response"

    private let actionLibsJson = "api_mock_examples_GET_action_libs_response"
    private let aiLibsJson = "api_mock_examples_GET_ai_libs_response"
    private let jobTasksJson = "api_mock_examples_GET_jobs_jobid_tasks_response"
    private let jobsJson = "api_mock_examples_GET_jobs_response"
    private let robotsJson = "api_mock_examples_GET_robots_response"
    private let robotCommandsJson = "api_mock_examples_GET_robots_robotid_commands_response"
    private let taskCommandsJson = "api_mock_examples_GET_tasks_taskid_commands_response"

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_buildGetRequest() {
        let url = URL(string: "http://example.org/endpoint")!
        let token = "token"

        XCTContext.runActivity(named: "クエリが未設定の場合") { _ in
            let request = api.buildGetRequest(url: url, token: token, query: nil)
            XCTAssertEqual(request.url?.absoluteString, "http://example.org/endpoint")
        }

        XCTContext.runActivity(named: "クエリが空の場合") { _ in
            let query: [URLQueryItem] = []
            let request = api.buildGetRequest(url: url, token: token, query: query)
            XCTAssertEqual(request.url?.absoluteString, "http://example.org/endpoint")
        }

        XCTContext.runActivity(named: "クエリが設定済みの場合(1つ)") { _ in
            let query: [URLQueryItem] = [
                URLQueryItem(name: "param", value: "value")
            ]
            let request = api.buildGetRequest(url: url, token: token, query: query)
            XCTAssertEqual(request.url?.absoluteString, "http://example.org/endpoint?param=value")
        }

        XCTContext.runActivity(named: "クエリが設定済みの場合(複数)") { _ in
            let query: [URLQueryItem] = [
                URLQueryItem(name: "param", value: "value"),
                URLQueryItem(name: "param", value: "value")
            ]
            let request = api.buildGetRequest(url: url, token: token, query: query)
            XCTAssertEqual(request.url?.absoluteString, "http://example.org/endpoint?param=value&param=value")
        }

        XCTContext.runActivity(named: "クエリが設定済みの場合(パラメータだけ)") { _ in
            let query: [URLQueryItem] = [
                URLQueryItem(name: "param", value: nil)
            ]
            let request = api.buildGetRequest(url: url, token: token, query: query)
            XCTAssertEqual(request.url?.absoluteString, "http://example.org/endpoint?param")
        }

    }

    func test_get() {

        let param = "test"

        XCTContext.runActivity(named: "GET_jobs_jobid_response.json") { _ in
            guard let data = try? getJSONData(jobJson) else { XCTFail("jsonデータが存在しない"); return }
            stub(uri(job.url.absoluteString + "/\(param)"), jsonData(data))
            request(
                APIResult<JobAPIEntity.Data>.self,
                result: api.get(resUrl: job.url, token: nil, dataId: param),
                onSuccess: { data in XCTAssertNotNil(data, "値が取得できていない: \(data)") },
                onError: { error in XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)") })
        }

        XCTContext.runActivity(named: "GET_robots_robotid_assets_response.json") { _ in
            guard let data = try? getJSONData(robotAssetsJson) else { XCTFail("jsonデータが存在しない"); return }
            stub(uri(robot.url.absoluteString + "/\(param)/assets"), jsonData(data))
            request(
                APIResult<[RobotAPIEntity.Asset]>.self,
                result: api.get(resUrl: robot.url, token: nil, dataId: param + "/assets"),
                onSuccess: { data in XCTAssertNotNil(data, "値が取得できていない: \(data)") },
                onError: { error in XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)") })
        }

        XCTContext.runActivity(named: "GET_robots_robotid_response.json") { _ in
            guard let data = try? getJSONData(robotJson) else { XCTFail("jsonデータが存在しない"); return }
            stub(uri(robot.url.absoluteString + "/\(param)"), jsonData(data))
            request(
                APIResult<RobotAPIEntity.Data>.self,
                result: api.get(resUrl: robot.url, token: nil, dataId: param),
                onSuccess: { data in XCTAssertNotNil(data, "値が取得できていない: \(data)") },
                onError: { error in XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)") })
        }

        XCTContext.runActivity(named: "GET_robots_robotid_swconf_response.json") { _ in
            guard let data = try? getJSONData(robotSwconfJson) else { XCTFail("jsonデータが存在しない"); return }
            stub(uri(robot.url.absoluteString + "/\(param)/swconf"), jsonData(data))
            request(
                APIResult<RobotAPIEntity.Swconf>.self,
                result: api.get(resUrl: robot.url, token: nil, dataId: param + "/swconf"),
                onSuccess: { data in XCTAssertNotNil(data, "値が取得できていない: \(data)") },
                onError: { error in XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)") })
        }

        XCTContext.runActivity(named: "GET_tasks_taskid_commands_robotid_response.json") { _ in
            guard let data = try? getJSONData(taskCommandJson) else { XCTFail("jsonデータが存在しない"); return }
            stub(uri(task.url.absoluteString + "/\(param)/commands/\(param)"), jsonData(data))
            request(
                APIResult<CommandEntity.Data>.self,
                result: api.get(resUrl: task.url, token: nil, dataId: param + "/commands/" + param),
                onSuccess: { data in XCTAssertNotNil(data, "値が取得できていない: \(data)") },
                onError: { error in XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)") })
        }

        XCTContext.runActivity(named: "GET_tasks_taskid_response.json") { _ in
            guard let data = try? getJSONData(taskJson) else { XCTFail("jsonデータが存在しない"); return }
            stub(uri(task.url.absoluteString + "/\(param)"), jsonData(data))
            request(
                APIResult<TaskAPIEntity.Data>.self,
                result: api.get(resUrl: task.url, token: nil, dataId: param),
                onSuccess: { data in XCTAssertNotNil(data, "値が取得できていない: \(data)") },
                onError: { error in XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)") })
        }

    }

    func test_getPaginated() {
        let param = "test"

        XCTContext.runActivity(named: "GET_action_libs_response.json") { _ in
            guard let data = try? getJSONData(actionLibsJson) else { XCTFail("jsonデータが存在しない"); return }
            stub(uri(actionLibrary.url.absoluteString), jsonData(data))
            request(
                APIResult<[ActionLibraryAPIEntity.Data]>.self,
                result: api.get(url: actionLibrary.url, token: nil),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                    XCTAssertEqual(data.paging, APIPaging.Output(page: 2, size: 5, totalPages: 2, totalCount: 8), "正しい値が取得できていない")
                },
                onError: { error in
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }

        XCTContext.runActivity(named: "GET_ai_libs_response.json") { _ in
            guard let data = try? getJSONData(aiLibsJson) else { XCTFail("jsonデータが存在しない"); return }
            stub(uri(aiLibrary.url.absoluteString), jsonData(data))
            request(
                APIResult<[AILibraryAPIEntity.Data]>.self,
                result: api.get(url: aiLibrary.url, token: nil),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                    XCTAssertEqual(data.paging, APIPaging.Output(page: 1, size: 5, totalPages: 1, totalCount: 4), "正しい値が取得できていない")
                },
                onError: { error in
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }

        XCTContext.runActivity(named: "GET_jobs_jobid_tasks_response.json") { _ in
            guard let data = try? getJSONData(jobTasksJson) else { XCTFail("jsonデータが存在しない"); return }
            stub(uri(job.url.absoluteString + "/\(param)/tasks"), jsonData(data))
            request(
                APIResult<[TaskAPIEntity.Data]>.self,
                result: api.get(resUrl: job.url, token: nil, dataId: param + "/tasks"),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                    XCTAssertEqual(data.paging, APIPaging.Output(page: 2, size: 4, totalPages: 2, totalCount: 6), "正しい値が取得できていない")
                },
                onError: { error in
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }

        XCTContext.runActivity(named: "GET_jobs_response.json") { _ in
            guard let data = try? getJSONData(jobsJson) else { XCTFail("jsonデータが存在しない"); return }
            stub(uri(job.url.absoluteString), jsonData(data))
            request(
                APIResult<[JobAPIEntity.Data]>.self,
                result: api.get(url: job.url, token: nil),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                    XCTAssertEqual(data.paging, APIPaging.Output(page: 2, size: 5, totalPages: 2, totalCount: 8), "正しい値が取得できていない")
                },
                onError: { error in
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }

        XCTContext.runActivity(named: "GET_robots_response.json") { _ in
            guard let data = try? getJSONData(robotsJson) else { XCTFail("jsonデータが存在しない"); return }
            stub(uri(robot.url.absoluteString), jsonData(data))
            request(
                APIResult<[RobotAPIEntity.Data]>.self,
                result: api.get(url: robot.url, token: nil),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                    XCTAssertEqual(data.paging, APIPaging.Output(page: 1, size: 50, totalPages: 1, totalCount: 4), "正しい値が取得できていない")
                },
                onError: { error in
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }

        XCTContext.runActivity(named: "GET_robots_robotid_commands_response.json") { _ in
            guard let data = try? getJSONData(robotCommandsJson) else { XCTFail("jsonデータが存在しない"); return }
            stub(uri(robot.url.absoluteString + "/\(param)/commands"), jsonData(data))
            request(
                APIResult<[CommandEntity.Data]>.self,
                result: api.get(resUrl: robot.url, token: nil, dataId: param + "/commands"),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                    XCTAssertEqual(data.paging, APIPaging.Output(page: 2, size: 5, totalPages: 8, totalCount: 37), "正しい値が取得できていない")
                },
                onError: { error in
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }

        XCTContext.runActivity(named: "GET_tasks_taskid_commands_response.json") { _ in
            guard let data = try? getJSONData(taskCommandsJson) else { XCTFail("jsonデータが存在しない"); return }
            stub(uri(task.url.absoluteString + "/\(param)/commands"), jsonData(data))
            request(
                APIResult<[CommandEntity.Data]>.self,
                result: api.get(resUrl: task.url, token: nil, dataId: param + "/commands"),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                    XCTAssertEqual(data.paging, APIPaging.Output(page: 2, size: 4, totalPages: 16, totalCount: 61), "正しい値が取得できていない")
                },
                onError: { error in
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }
    }

    func test_getError() {

        XCTContext.runActivity(named: "通信エラーの場合") { _ in
            let error = NSError(domain: "Error", code: -1, userInfo: nil)
            stub(uri(robot.url.absoluteString), failure(error))

            request(
                APIResult<[RobotAPIEntity.Data]>.self,
                result: api.get(url: robot.url, token: nil),
                onSuccess: { data in
                    XCTFail("値を取得できてはいけない: \(data)")
                },
                onError: { error in
                    let error = error as NSError
                    XCTAssertEqual(error.code, -1, "正しい値が取得できていない: \(error.code)")
                    XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (NSURLErrorDomain error -1.)", "正しい値が取得できていない: \(error.localizedDescription)")
                })
        }

        XCTContext.runActivity(named: "空のデータを取得した場合") { _ in
            stub(uri(robot.url.absoluteString), json([""]))

            request(
                APIResult<[RobotAPIEntity.Data]>.self,
                result: api.get(url: robot.url, token: nil),
                onSuccess: { data in
                    XCTFail("値を取得できてはいけない: \(data)")
                },
                onError: { error in
                    let error = error as NSError
                    XCTAssertEqual(error.code, 4864, "正しい値が取得できていない: \(error.code)")
                    XCTAssertEqual(error.localizedDescription, "The data couldn’t be read because it isn’t in the correct format.", "正しい値が取得できていない: \(error.localizedDescription)")
                })
        }

        XCTContext.runActivity(named: "無効なデータを取得した場合") { _ in
            let body = ["test": "data"]
            stub(uri(robot.url.absoluteString), json(body))

            request(
                APIResult<[RobotAPIEntity.Data]>.self,
                result: api.get(url: robot.url, token: nil),
                onSuccess: { data in
                    XCTFail("値を取得できてはいけない: \(data)")
                },
                onError: { error in
                    let error = error as NSError
                    XCTAssertEqual(error.code, 4865, "正しい値が取得できていない: \(error.code)")
                    XCTAssertEqual(error.localizedDescription, "The data couldn’t be read because it is missing.", "正しい値が取得できていない: \(error.localizedDescription)")
                })
        }
    }

    func test_getErrorCode() {
        var errorCode = 300

        XCTContext.runActivity(named: "\(errorCode)エラーの場合") { _ in
            guard let data = try? getJSONData(robotsJson) else {
                XCTFail("jsonデータが存在しない")
                return
            }

            stub(uri(robot.url.absoluteString), jsonData(data, status: errorCode))

            request(
                APIResult<[RobotAPIEntity.Data]>.self,
                result: api.get(url: robot.url, token: nil),
                onSuccess: { data in
                    XCTFail("値を取得できてはいけない: \(data)")
                },
                onError: { error in
                    switch error as! APIError {
                    case .invalidStatus(let code, _):
                        XCTAssertEqual(code, errorCode, "正しい値が取得できていない: \(errorCode)")
                    default:
                        XCTFail("想定外のエラー")
                    }
                })
        }

        errorCode = 299
        XCTContext.runActivity(named: "\(errorCode)エラーの場合") { _ in
            guard let data = try? getJSONData(robotsJson) else {
                XCTFail("jsonデータが存在しない")
                return
            }

            stub(uri(robot.url.absoluteString), jsonData(data, status: errorCode))

            request(
                APIResult<[RobotAPIEntity.Data]>.self,
                result: api.get(url: robot.url, token: nil),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                },
                onError: { error in
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }
    }

    func test_getWithDataId() throws {
        let param = "test"

        XCTContext.runActivity(named: "Robotデータを取得した場合") { _ in
            guard let data = try? getJSONData(robotJson) else {
                XCTFail("jsonデータが存在しない")
                return
            }

            stub(uri(robot.url.absoluteString + "/\(param)"), jsonData(data))

            request(
                APIResult<RobotAPIEntity.Data>.self,
                result: api.get(resUrl: robot.url, token: nil, dataId: param),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                },
                onError: { error in
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }
    }

    func test_getImage() throws {
        let param = "test"

        XCTContext.runActivity(named: "Robot画像を取得した場合") { _ in

            let bundle = Bundle(for: type(of: self))
            guard let imagePath = bundle.path(forResource: "tmrobot", ofType: "png") else {
                XCTFail("データが存在しない")
                return
            }
            let url = URL(fileURLWithPath: imagePath)
            guard let data = try? Data(contentsOf: url) else {
                XCTFail("データが存在しない")
                return
            }
            stub(uri(robot.url.absoluteString + "/\(param)/image"), http(download: .content(data)))

            request(
                Data.self,
                result: api.getImage(resUrl: robot.url, token: nil, dataId: param + "/image"),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                },
                onError: { error in
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }
    }
}

extension APIRequestTests {

    private func getJSONData(_ name: String) throws -> Data? {
        guard let url = Bundle(for: type(of: self)).url(forResource: name, withExtension: "json") else { return nil }
        return try Data(contentsOf: url)
    }

    private func request<T: Codable>(_ : T.Type, result: AnyPublisher<T, Error>, onSuccess: @escaping (T) -> Void, onError: @escaping (Error) -> Void) {
        let completionExpectation = expectation(description: "completion")

        result.sink(receiveCompletion: { completion in
            switch completion {
            case .finished: break
            case .failure(let error):
                onError(error)
            }
            completionExpectation.fulfill()
        }, receiveValue: { response in
            onSuccess(response)
        }).store(in: &cancellables)

        XCTAssertNotNil(result)
        wait(for: [completionExpectation], timeout: ms1000)
    }
}
