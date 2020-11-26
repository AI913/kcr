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
    private let robotsJson = "list_robot_response_example"
    private let jobsJson = "list_job_response_example"
    private let actionLibrariesJson = "list_action_library_response_example"
    private let aiLibrariesJson = "list_ai_library_response_example"
    private let commandJson = "api_openapi-spec_v1_examples_list_command_response_example"
    private let taskJson = "api_openapi-spec_v1_examples_command_response_succeeded_example01"
    private let robotJson = "robot_response_example01"
    private let tasksJson = "task_response_example01"
    private let swconfJson = "swconfig_response_example01"
    private let assetJson = "list_hw_config_asset_response_example"
    private let tasksFromJobJson = "list_task_filtered_by_jobid_response_example"
    private let commandsFromTaskJson = "api_mock_examples_GET_tasks_taskid_commands_response"

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_get() {

        XCTContext.runActivity(named: "Robotリストを取得した場合") { _ in
            guard let data = try? getJSONData(robotsJson) else {
                XCTFail("jsonデータが存在しない")
                return
            }

            stub(uri(robot.url.absoluteString), jsonData(data))

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

        XCTContext.runActivity(named: "Jobリストを取得した場合") { _ in
            guard let data = try? getJSONData(jobsJson) else {
                XCTFail("jsonデータが存在しない")
                return
            }

            stub(uri(job.url.absoluteString), jsonData(data))

            request(
                APIResult<[JobAPIEntity.Data]>.self,
                result: api.get(url: job.url, token: nil),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                },
                onError: { error in
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }

        let param = "test"

        XCTContext.runActivity(named: "JobのTaskリストを取得する場合") { _ in
            guard let data = try? getJSONData(tasksFromJobJson) else {
                XCTFail("jsonデータが存在しない")
                return
            }

            stub(uri(job.url.absoluteString + "/\(param)/tasks"), jsonData(data))

            request(
                APIResult<[TaskAPIEntity.Data]>.self,
                result: api.get(resUrl: job.url, token: nil, dataId: param + "/tasks"),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                },
                onError: { error in
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }

        XCTContext.runActivity(named: "TaskのCommandリストを取得する場合") { _ in
            guard let data = try? getJSONData(commandsFromTaskJson) else {
                XCTFail("jsonデータが存在しない")
                return
            }

            stub(uri(task.url.absoluteString + "/\(param)/commands"), jsonData(data))

            request(
                APIResult<[CommandEntity.Data]>.self,
                result: api.get(resUrl: task.url, token: nil, dataId: param + "/commands"),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                },
                onError: { error in
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }

        XCTContext.runActivity(named: "ActionLibraryリストを取得した場合") { _ in
            guard let data = try? getJSONData(actionLibrariesJson) else {
                XCTFail("jsonデータが存在しない")
                return
            }

            stub(uri(actionLibrary.url.absoluteString), jsonData(data))

            request(
                APIResult<[ActionLibraryAPIEntity.Data]>.self,
                result: api.get(url: actionLibrary.url, token: nil),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                },
                onError: { error in
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }

        XCTContext.runActivity(named: "AILibraryリストを取得した場合") { _ in
            guard let data = try? getJSONData(aiLibrariesJson) else {
                XCTFail("jsonデータが存在しない")
                return
            }

            stub(uri(aiLibrary.url.absoluteString), jsonData(data))

            request(
                APIResult<[AILibraryAPIEntity.Data]>.self,
                result: api.get(url: aiLibrary.url, token: nil),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                },
                onError: { error in
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }

        XCTContext.runActivity(named: "command listを取得する場合") { _ in
            guard let data = try? getJSONData(commandJson) else {
                XCTFail("jsonデータが存在しない")
                return
            }

            stub(uri(robot.url.absoluteString + "/\(param)/commands"), jsonData(data))

            request(
                APIResult<[CommandEntity.Data]>.self,
                result: api.get(resUrl: robot.url, token: nil, dataId: param + "/commands"),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                },
                onError: { error in
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }

        XCTContext.runActivity(named: "taskのCommandを取得する場合") { _ in
            guard let data = try? getJSONData(taskJson) else {
                XCTFail("jsonデータが存在しない")
                return
            }

            stub(uri(task.url.absoluteString + "/\(param)/commands/\(param)"), jsonData(data))

            request(
                APIResult<CommandEntity.Data>.self,
                result: api.get(resUrl: task.url, token: nil, dataId: param + "/commands/" + param),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                },
                onError: { error in
                    //TODO:Entity変更の影響対応
                    //XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }

        XCTContext.runActivity(named: "taskを取得する場合") { _ in
            guard let data = try? getJSONData(tasksJson) else {
                XCTFail("jsonデータが存在しない")
                return
            }

            stub(uri(task.url.absoluteString + "/\(param)"), jsonData(data))

            request(
                APIResult<TaskAPIEntity.Data>.self,
                result: api.get(resUrl: task.url, token: nil, dataId: param),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                },
                onError: { error in
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }

        XCTContext.runActivity(named: "SW構成情報を取得する場合") { _ in
            guard let data = try? getJSONData(swconfJson) else {
                XCTFail("jsonデータが存在しない")
                return
            }

            stub(uri(robot.url.absoluteString + "/\(param)/swconf"), jsonData(data))

            request(
                APIResult<RobotAPIEntity.Swconf>.self,
                result: api.get(resUrl: robot.url, token: nil, dataId: param + "/swconf"),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
                },
                onError: { error in
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                })
        }

        XCTContext.runActivity(named: "アセット情報を取得する場合") { _ in
            guard let data = try? getJSONData(assetJson) else {
                XCTFail("jsonデータが存在しない")
                return
            }

            stub(uri(robot.url.absoluteString + "/\(param)/assets"), jsonData(data))

            request(
                APIResult<[RobotAPIEntity.Asset]>.self,
                result: api.get(resUrl: robot.url, token: nil, dataId: param + "/assets"),
                onSuccess: { data in
                    XCTAssertNotNil(data, "値が取得できていない: \(data)")
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
