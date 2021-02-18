//
//  AWSAuthenticationDataStoreTests.swift
//  JobOrder.APITests
//
//  Created by Yu Suzuki on 2020/08/04.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_API
@testable import AWSMobileClient

class AWSAuthenticationDataStoreTests: XCTestCase {

    private let ms1000 = 1.0
    private let mock = AWSMobileClientProtocolMock()
    private let dataStore = AWSAuthenticationDataStore()
    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        dataStore.factory.mobileClient = mock
    }

    override func tearDownWithError() throws {}

    func test_currentUsername () {
        let param = "test"

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertNil(dataStore.currentUsername, "値を取得できてはいけない")
        }

        XCTContext.runActivity(named: "\(param)が設定済みの場合") { _ in
            mock.username = param
            XCTAssertEqual(dataStore.currentUsername, param, "正しい値が取得できていない: \(param)")
        }
    }

    func test_isSignedIn() {

        XCTContext.runActivity(named: "未設定の場合") { _ in
            XCTAssertFalse(dataStore.isSignedIn, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Trueが設定済みの場合") { _ in
            mock.isSignedIn = true
            XCTAssertTrue(dataStore.isSignedIn, "有効になってはいけない")
        }

        XCTContext.runActivity(named: "Falseが設定済みの場合") { _ in
            mock.isSignedIn = false
            XCTAssertFalse(dataStore.isSignedIn, "有効になってはいけない")
        }
    }

    func test_registerUserStateChange() {

        UserState.allValues.forEach { userState in
            let handlerExpectation = expectation(description: "handler \(userState)")
            let completionExpectation = expectation(description: "completion \(userState)")
            let entity = AuthenticationEntity.Output.AuthenticationState(userState)

            mock.addUserStateListenerHandler = { object, callback in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // PublisherのReturnより前にsendされて失敗するのでDelayを入れる
                    callback(userState, [:])
                    handlerExpectation.fulfill()
                }
            }

            dataStore.registerUserStateChange()
                .sink { response in
                    XCTAssertEqual(response, entity, "正しい値が取得できていない: \(entity)")
                    completionExpectation.fulfill()
                }.store(in: &cancellables)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_registerUserStateChangeNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mock.addUserStateListenerHandler = { object, callback in
            handlerExpectation.fulfill()
        }

        dataStore.registerUserStateChange()
            .sink { response in
                completionExpectation.fulfill()
            }.store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_unregisterUserStateChange() {

        dataStore.unregisterUserStateChange()
        XCTAssertEqual(mock.removeUserStateListenerCallCount, 1, "AWSMobileClientのメソッドが呼ばれない")
    }

    func test_signIn() {
        let param = "test"

        SignInState.allValues.forEach { state in
            let handlerExpectation = expectation(description: "handler \(state)")
            let completionExpectation = expectation(description: "completion \(state)")
            let result = SignInResult(signInState: state)
            let entity = JobOrder_API.AuthenticationEntity.Output.SignInResult(result)

            mock.signInHandler = { username, password, completionHandler in
                completionHandler(result, nil)
                handlerExpectation.fulfill()
            }

            dataStore.signIn(username: param, password: param)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { response in
                    XCTAssertEqual(response.state, entity.state, "正しい値が取得できていない: \(entity.state)")
                }).store(in: &cancellables)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_signInCheckWithSignedIn() {
        let param = "test"
        mock.isSignedIn = true
        _ = dataStore.signIn(username: param, password: param)
        XCTAssertEqual(mock.signOutCallCount, 1, "AWSMobileClientのメソッドが呼ばれない")
    }

    func test_signInCheckWithoutSignedIn() {
        let param = "test"
        mock.isSignedIn = false
        _ = dataStore.signIn(username: param, password: param)
        XCTAssertEqual(mock.signOutCallCount, 0, "AWSMobileClientのメソッドが呼ばれてはいけない")
    }

    func test_signInError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let error = AWSMobileClientError.internalError(message: "")
        let expected = AWSError.authenticationFailed(reason: .init(error)) as NSError
        let param = "test"

        mock.signInHandler = { username, password, completionHandler in
            completionHandler(nil, error)
            handlerExpectation.fulfill()
        }

        dataStore.signIn(username: param, password: param)
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

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_signInReceivedNil() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let param = "test"

        mock.signInHandler = { username, password, completionHandler in
            completionHandler(nil, nil)
            handlerExpectation.fulfill()
        }

        dataStore.signIn(username: param, password: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertEqual(response.state, .unknown, "正しい値が取得できていない")
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_signInNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"

        mock.signInHandler = { username, password, completionHandler in
            handlerExpectation.fulfill()
        }

        dataStore.signIn(username: param, password: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_confirmSignIn() {
        let param = "test"

        SignInState.allValues.forEach { state in
            let handlerExpectation = expectation(description: "handler \(state)")
            let completionExpectation = expectation(description: "completion \(state)")
            let result = SignInResult(signInState: state)
            let entity = JobOrder_API.AuthenticationEntity.Output.SignInResult(result)

            mock.confirmSignInHandler = { newPassword, completionHandler in
                completionHandler(result, nil)
                handlerExpectation.fulfill()
            }

            dataStore.confirmSignIn(newPassword: param)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { response in
                    XCTAssertEqual(response.state, entity.state, "正しい値が取得できていない: \(entity.state)")
                }).store(in: &cancellables)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_confirmSignInError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let error = AWSMobileClientError.internalError(message: "")
        let expected = AWSError.authenticationFailed(reason: .init(error)) as NSError
        let param = "test"

        mock.confirmSignInHandler = { challengeResponse, completionHandler in
            completionHandler(nil, error)
            handlerExpectation.fulfill()
        }

        dataStore.confirmSignIn(newPassword: param)
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

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_confirmSignInReceivedNil() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let param = "test"

        mock.confirmSignInHandler = { challengeResponse, completionHandler in
            completionHandler(nil, nil)
            handlerExpectation.fulfill()
        }

        dataStore.confirmSignIn(newPassword: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertEqual(response.state, .unknown, "正しい値が取得できていない")
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_confirmSignInNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"

        mock.confirmSignInHandler = { challengeResponse, completionHandler in
            handlerExpectation.fulfill()
        }

        dataStore.confirmSignIn(newPassword: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_signOut() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mock.signOutCompletionHandlerHandler = { completionHandler in
            completionHandler(nil)
            handlerExpectation.fulfill()
        }

        dataStore.signOut()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertEqual(response.state, .success, "正しい値が取得できていない")
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_signOutError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let error = AWSMobileClientError.internalError(message: "")
        let expected = AWSError.authenticationFailed(reason: .init(error)) as NSError

        mock.signOutCompletionHandlerHandler = { completionHandler in
            completionHandler(error)
            handlerExpectation.fulfill()
        }

        dataStore.signOut()
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

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_signOutNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mock.signOutCompletionHandlerHandler = { completionHandler in
            handlerExpectation.fulfill()
        }

        dataStore.signOut()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_getTokens() {
        let param = "test"

        SignInState.allValues.forEach { state in
            let handlerExpectation = expectation(description: "handler \(state)")
            let completionExpectation = expectation(description: "completion \(state)")
            let token = SessionToken(tokenString: param)
            let tokens = Tokens(idToken: token, accessToken: token, refreshToken: token, expiration: Date(timeIntervalSince1970: 1.0))
            let entity = JobOrder_API.AuthenticationEntity.Output.Tokens(tokens)

            mock.getTokensHandler = { completionHandler in
                completionHandler(tokens, nil)
                handlerExpectation.fulfill()
            }

            dataStore.getTokens()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { response in
                    XCTAssert(response == entity, "正しい値が取得できていない: \(entity)")
                }).store(in: &cancellables)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_getTokensError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let error = AWSMobileClientError.internalError(message: "")
        let expected = AWSError.authenticationFailed(reason: .init(error)) as NSError

        mock.getTokensHandler = { completionHandler in
            completionHandler(nil, error)
            handlerExpectation.fulfill()
        }

        dataStore.getTokens()
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

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_getTokensReceivedNil() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mock.getTokensHandler = { completionHandler in
            completionHandler(nil, nil)
            handlerExpectation.fulfill()
        }

        dataStore.getTokens()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertNil(response.accessToken, "値を取得できてはいけない")
                XCTAssertNil(response.refreshToken, "値を取得できてはいけない")
                XCTAssertNil(response.idToken, "値を取得できてはいけない")
                XCTAssertNil(response.expiration, "値を取得できてはいけない")
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_getTokensNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mock.getTokensHandler = { completionHandler in
            handlerExpectation.fulfill()
        }

        dataStore.getTokens()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_getAttrlibutes() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let param = "test"

        mock.getUserAttributesHandler = { completionHandler in
            completionHandler(["email": param], nil)
            handlerExpectation.fulfill()
        }

        dataStore.getAttrlibutes()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertEqual(response.email, param, "正しい値が取得できていない: \(param)")
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_getAttrlibutesError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let error = AWSMobileClientError.internalError(message: "")
        let expected = AWSError.authenticationFailed(reason: .init(error)) as NSError

        mock.getUserAttributesHandler = { completionHandler in
            completionHandler(nil, error)
            handlerExpectation.fulfill()
        }

        dataStore.getAttrlibutes()
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

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_getAttrlibutesReceivedNil() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")

        mock.getUserAttributesHandler = { completionHandler in
            completionHandler(nil, nil)
            handlerExpectation.fulfill()
        }

        dataStore.getAttrlibutes()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertNil(response.email, "値を取得できてはいけない")
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_getAttrlibutesNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true

        mock.getUserAttributesHandler = { completionHandler in
            handlerExpectation.fulfill()
        }

        dataStore.getAttrlibutes()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_forgotPassword() {
        let param = "test"

        ForgotPasswordState.allValues.forEach { state in
            let handlerExpectation = expectation(description: "handler \(state)")
            let completionExpectation = expectation(description: "completion \(state)")
            let result = ForgotPasswordResult(forgotPasswordState: state, codeDeliveryDetails: nil)
            let entity = JobOrder_API.AuthenticationEntity.Output.ForgotPasswordResult(result)

            mock.forgotPasswordHandler = { username, completionHandler in
                completionHandler(result, nil)
                handlerExpectation.fulfill()
            }

            dataStore.forgotPassword(username: param)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { response in
                    XCTAssertEqual(response.state, entity.state, "正しい値が取得できていない: \(entity.state)")
                }).store(in: &cancellables)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_forgotPasswordError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let error = AWSMobileClientError.internalError(message: "")
        let expected = AWSError.authenticationFailed(reason: .init(error)) as NSError
        let param = "test"

        mock.forgotPasswordHandler = { username, completionHandler in
            completionHandler(nil, error)
            handlerExpectation.fulfill()
        }

        dataStore.forgotPassword(username: param)
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

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_forgotPasswordReceivedNil() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let param = "test"

        mock.forgotPasswordHandler = { username, completionHandler in
            completionHandler(nil, nil)
            handlerExpectation.fulfill()
        }

        dataStore.forgotPassword(username: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertEqual(response.state, .unknown, "正しい値が取得できていない")
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_forgotPasswordNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"

        mock.forgotPasswordHandler = { username, completionHandler in
            handlerExpectation.fulfill()
        }

        dataStore.forgotPassword(username: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_confirmForgotPassword() {
        let param = "test"

        ForgotPasswordState.allValues.forEach { state in
            let handlerExpectation = expectation(description: "handler \(state)")
            let completionExpectation = expectation(description: "completion \(state)")
            let result = ForgotPasswordResult(forgotPasswordState: state, codeDeliveryDetails: nil)
            let entity = JobOrder_API.AuthenticationEntity.Output.ForgotPasswordResult(result)

            mock.confirmForgotPasswordHandler = { username, newPassword, confirmationCode, completionHandler in
                completionHandler(result, nil)
                handlerExpectation.fulfill()
            }

            dataStore.confirmForgotPassword(username: param, newPassword: param, confirmationCode: param)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { response in
                    XCTAssertEqual(response.state, entity.state, "正しい値が取得できていない: \(entity.state)")
                }).store(in: &cancellables)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_confirmForgotPasswordError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let error = AWSMobileClientError.internalError(message: "")
        let expected = AWSError.authenticationFailed(reason: .init(error)) as NSError
        let param = "test"

        mock.confirmForgotPasswordHandler = { username, newPassword, confirmationCode, completionHandler in
            completionHandler(nil, error)
            handlerExpectation.fulfill()
        }

        dataStore.confirmForgotPassword(username: param, newPassword: param, confirmationCode: param)
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

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_confirmForgotPasswordReceivedNil() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let param = "test"

        mock.confirmForgotPasswordHandler = { username, newPassword, confirmationCode, completionHandler in
            completionHandler(nil, nil)
            handlerExpectation.fulfill()
        }

        dataStore.confirmForgotPassword(username: param, newPassword: param, confirmationCode: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertEqual(response.state, .unknown, "正しい値が取得できていない")
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_confirmForgotPasswordNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"

        mock.confirmForgotPasswordHandler = { username, newPassword, confirmationCode, completionHandler in
            handlerExpectation.fulfill()
        }

        dataStore.confirmForgotPassword(username: param, newPassword: param, confirmationCode: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_resendConfirmationCode() {
        let param = "test"

        SignUpConfirmationState.allValues.forEach { state in
            let handlerExpectation = expectation(description: "handler \(state)")
            let completionExpectation = expectation(description: "completion \(state)")
            let result = SignUpResult(signUpState: state, codeDeliveryDetails: nil)
            let entity = JobOrder_API.AuthenticationEntity.Output.SignUpResult(result)

            mock.resendSignUpCodeHandler = { username, completionHandler in
                completionHandler(result, nil)
                handlerExpectation.fulfill()
            }

            dataStore.resendConfirmationCode(username: param)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                    }
                    completionExpectation.fulfill()
                }, receiveValue: { response in
                    XCTAssertEqual(response.state, entity.state, "正しい値が取得できていない: \(entity.state)")
                }).store(in: &cancellables)

            wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        }
    }

    func test_resendConfirmationCodeError() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let error = AWSMobileClientError.internalError(message: "")
        let expected = AWSError.authenticationFailed(reason: .init(error)) as NSError
        let param = "test"

        mock.resendSignUpCodeHandler = { username, completionHandler in
            completionHandler(nil, error)
            handlerExpectation.fulfill()
        }

        dataStore.resendConfirmationCode(username: param)
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

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_resendConfirmationCodeReceivedNil() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        let param = "test"

        mock.resendSignUpCodeHandler = { username, completionHandler in
            completionHandler(nil, nil)
            handlerExpectation.fulfill()
        }

        dataStore.resendConfirmationCode(username: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { response in
                XCTAssertEqual(response.state, .unknown, "正しい値が取得できていない")
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }

    func test_resendConfirmationCodeNotReceived() {
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        let param = "test"

        mock.resendSignUpCodeHandler = { username, completionHandler in
            handlerExpectation.fulfill()
        }

        dataStore.resendConfirmationCode(username: param)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("値を取得できてはいけない")
                case .failure(let error):
                    XCTFail("エラーを取得できてはいけない: \(error.localizedDescription)")
                }
                completionExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)

        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
    }
}

extension SignInState {
    static let allValues = [unknown, smsMFA, passwordVerifier, customChallenge, deviceSRPAuth, devicePasswordVerifier, adminNoSRPAuth, newPasswordRequired, signedIn]
}

extension UserState {
    static let allValues = [signedIn, signedOut, signedOutFederatedTokensInvalid, signedOutUserPoolsTokenInvalid, guest, unknown]
}

extension ForgotPasswordState {
    static let allValues = [done, confirmationCodeSent]
}

extension SignUpConfirmationState {
    static let allValues = [confirmed, unconfirmed, unknown]
}
