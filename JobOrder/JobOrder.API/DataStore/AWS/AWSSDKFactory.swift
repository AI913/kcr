//
//  AWSSDKFactory.swift
//  JobOrder.API
//
//  Created by Yu Suzuki on 2021/01/22.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import AWSCore
import AWSMobileClient
import AWSIoT
import AWSKinesisVideo
import AWSKinesisVideoSignaling
import AWSPinpoint

final class AWSSDKFactory {

    /// シングルトン
    static let shared = AWSSDKFactory()
    private init() {}

    /// AWSMobileClient
    var mobileClient: AWSMobileClientProtocol?
    /// AWSIoT
    var iot: AWSIoTProtocol?
    /// AWSIoTDataManager
    var iotDataManager: AWSIoTDataManagerProtocol?
    /// AWSEndpointProtocolのクラス
    var endpointClass: AWSEndpointProtocol.Type = AWSEndpoint.self
    /// AWSServiceConfigurationProtocolのクラス
    var serviceConfigurationClass: AWSServiceConfigurationProtocol.Type = AWSServiceConfiguration.self
    /// AWSKinesisVideo
    var kinesisVideo: AWSKinesisVideoProtocol?
    /// AWSKinesisVideoSignaling
    var kinesisVideoSignaling: AWSKinesisVideoSignalingProtocol?
    /// AWSKinesisVideoSignalingProtocolのクラス
    var kinesisVideoSignalingClass: AWSKinesisVideoSignalingProtocol.Type = AWSKinesisVideoSignaling.self
    /// KVSSignerProtocolのクラス
    var kvsSignerClass: KVSSignerProtocol.Type = KVSSigner.self
    /// AWSPinpointNotificationManagerProtocol
    var pinpointNotificationManager: AWSPinpointNotificationManagerProtocol?
    /// AWSPinpointTargetingClientProtocol
    var pinpointTargetClient: AWSPinpointTargetingClientProtocol?
    /// AWSAnalyticsClientProtocol
    var analyticsClient: AWSAnalyticsClientProtocol?
    /// アプリの起動オプション
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?

    /// Configuration 設定
    func set(configuration: [String: Any]) {
        mobileClient = AWSMobileClient(configuration: configuration)
    }

    ///  起動オプション設定
    func set(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        self.launchOptions = launchOptions
    }

    /// IoT 系のモジュールを生成
    func generateIoT() {
        guard let client = mobileClient as? AWSMobileClient else { return }

        // TODO: 登録をjsonでできないかAmazonに質問
        let defaultConfiguration = AWSServiceConfiguration(
            region: AWSConstants.IoT.region,
            credentialsProvider: client
        )
        AWSServiceManager.default().defaultServiceConfiguration = defaultConfiguration

        // Configuration for AWSIoT control plane APIs
        let iotCtrlConfiguration = AWSServiceConfiguration(
            region: AWSConstants.IoT.region,
            credentialsProvider: client
        )
        AWSIoTManager.register(with: iotCtrlConfiguration, forKey: AWSConstants.IoT.ctrlManagerKey)

        // Configuration for AWSIoT data plane APIs
        let iotEndPoint = AWSEndpoint(urlString: AWSConstants.IoT.endPoint)
        let iotDataConfiguration = AWSServiceConfiguration(
            region: AWSConstants.IoT.region,
            endpoint: iotEndPoint,
            credentialsProvider: client
        )
        AWSIoTDataManager.register(with: iotDataConfiguration!, forKey: AWSConstants.IoT.dataManagerKey)

        iotDataManager = AWSIoTDataManager(forKey: AWSConstants.IoT.dataManagerKey)
        iot = AWSIoT.default()
    }

    /// KVS 系のモジュールを生成
    func generateKVS() {
        guard let client = mobileClient as? AWSMobileClient else { return }

        // Default
        guard let configuration = AWSServiceConfiguration(region: AWSConstants.KVS.region,
                                                          credentialsProvider: client) else { return }
        AWSKinesisVideo.register(with: configuration, forKey: AWSConstants.KVS.managerKey)
        kinesisVideo = AWSKinesisVideo(forKey: AWSConstants.KVS.managerKey)
        kinesisVideoSignaling = AWSKinesisVideoSignaling(forKey: AWSConstants.KVS.managerKey)
    }

    /// Pinpoint 系のモジュールを生成
    func generatePinpoint(appId: String) {
        let config = AWSPinpointConfiguration(appId: appId, launchOptions: launchOptions)
        // let config = AWSPinpointConfiguration.defaultPinpointConfiguration(launchOptions: launchOptions)
        config.debug = true
        let pinpoint = AWSPinpoint(configuration: config)
        pinpointNotificationManager = pinpoint.notificationManager
        analyticsClient = pinpoint.analyticsClient
        pinpointTargetClient = pinpoint.targetingClient
    }
}

/// @mockable
protocol AWSMobileClientProtocol {
    var username: String? { get }
    var isSignedIn: Bool { get }
    func initialize(_ completionHandler: @escaping (UserState?, Error?) -> Void)
    func addUserStateListener(_ object: AnyObject, _ callback: @escaping UserStateChangeCallback)
    func removeUserStateListener(_ object: AnyObject)
    func signIn(username: String, password: String, completionHandler: @escaping ((SignInResult?, Error?) -> Void))
    func confirmSignIn(challengeResponse: String, completionHandler: @escaping ((SignInResult?, Error?) -> Void))
    func signOut()
    func signOut(completionHandler: @escaping ((Error?) -> Void))
    func getTokens(_ completionHandler: @escaping (Tokens?, Error?) -> Void)
    func getUserAttributes(completionHandler: @escaping (([String: String]?, Error?) -> Void))
    func forgotPassword(username: String, completionHandler: @escaping ((ForgotPasswordResult?, Error?) -> Void))
    func confirmForgotPassword(username: String, newPassword: String, confirmationCode: String, completionHandler: @escaping ((ForgotPasswordResult?, Error?) -> Void))
    func resendSignUpCode(username: String, completionHandler: @escaping ((SignUpResult?, Error?) -> Void))
    func getAWSCredentials(_ completionHandler: @escaping(AWSCredentials?, Error?) -> Void)
    func getIdentityId() -> AWSTask<NSString>
}

extension AWSMobileClient: AWSMobileClientProtocol {
    func resendSignUpCode(username: String, completionHandler: @escaping ((SignUpResult?, Error?) -> Void)) {
        resendSignUpCode(username: username, clientMetaData: [:], completionHandler: completionHandler)
    }
    func signIn(username: String, password: String, completionHandler: @escaping ((SignInResult?, Error?) -> Void)) {
        signIn(username: username, password: password, validationData: nil, completionHandler: completionHandler)
    }
    func confirmSignIn(challengeResponse: String, completionHandler: @escaping ((SignInResult?, Error?) -> Void)) {
        confirmSignIn(challengeResponse: challengeResponse, userAttributes: [:], clientMetaData: [:], completionHandler: completionHandler)
    }
    func signOut(completionHandler: @escaping ((Error?) -> Void)) {
        signOut(options: SignOutOptions(), completionHandler: completionHandler)
    }
    func forgotPassword(username: String, completionHandler: @escaping ((ForgotPasswordResult?, Error?) -> Void)) {
        forgotPassword(username: username, clientMetaData: [:], completionHandler: completionHandler)
    }
    func confirmForgotPassword(username: String, newPassword: String, confirmationCode: String, completionHandler: @escaping ((ForgotPasswordResult?, Error?) -> Void)) {
        confirmForgotPassword(username: username, newPassword: newPassword, confirmationCode: confirmationCode, clientMetaData: [:], completionHandler: completionHandler)
    }
}

/// @mockable
protocol AWSIoTProtocol {
    func createJob(_ request: AWSIoTCreateJobRequest) -> AWSTask<AWSIoTCreateJobResponse>
    func listJobExecutions(forThing: AWSIoTListJobExecutionsForThingRequest) -> AWSTask<AWSIoTListJobExecutionsForThingResponse>
    func attachPolicy(_ request: AWSIoTAttachPolicyRequest) -> AWSTask<AnyObject>
    func detachPolicy(_ request: AWSIoTDetachPolicyRequest) -> AWSTask<AnyObject>
}

extension AWSIoT: AWSIoTProtocol {}

/// @mockable
protocol AWSIoTDataManagerProtocol {
    func getConnectionStatus() -> AWSIoTMQTTStatus
    func subscribe(toTopic: String, qoS: AWSIoTMQTTQoS, extendedCallback: @escaping AWSIoTMQTTExtendedNewMessageBlock) -> Bool
    func unsubscribeTopic(_ topic: String)
    func publishString(_ string: String, onTopic: String, qoS: AWSIoTMQTTQoS) -> Bool
    func connectUsingWebSocket(withClientId clientId: String, cleanSession: Bool, statusCallback callback: @escaping (AWSIoTMQTTStatus) -> Void) -> Bool
    func disconnect()
}

extension AWSIoTDataManager: AWSIoTDataManagerProtocol {}

/// @mockable
protocol AWSEndpointProtocol {
    init(region: AWSRegionType, service: AWSServiceType, url: URL!)
}

extension AWSEndpoint: AWSEndpointProtocol {}

/// @mockable
protocol AWSServiceConfigurationProtocol {
    init(region: AWSRegionType, endpoint: AWSEndpoint!, credentialsProvider: AWSCredentialsProvider!)
}

extension AWSServiceConfiguration: AWSServiceConfigurationProtocol {}

/// @mockable
protocol AWSKinesisVideoProtocol {
    func describeSignalingChannel(_ request: AWSKinesisVideoDescribeSignalingChannelInput) -> AWSTask<AWSKinesisVideoDescribeSignalingChannelOutput>
    func createSignalingChannel(_ request: AWSKinesisVideoCreateSignalingChannelInput) -> AWSTask<AWSKinesisVideoCreateSignalingChannelOutput>
    func getSignalingChannelEndpoint(_ request: AWSKinesisVideoGetSignalingChannelEndpointInput) -> AWSTask<AWSKinesisVideoGetSignalingChannelEndpointOutput>
}

extension AWSKinesisVideo: AWSKinesisVideoProtocol {}

/// @mockable
protocol AWSKinesisVideoSignalingProtocol {
    static func remove(forKey: String)
    static func register(with: AWSServiceConfiguration, forKey: String)
    func getIceServerConfig(_ request: AWSKinesisVideoSignalingGetIceServerConfigRequest) -> AWSTask<AWSKinesisVideoSignalingGetIceServerConfigResponse>
}

extension AWSKinesisVideoSignaling: AWSKinesisVideoSignalingProtocol {}

/// @mockable
protocol KVSSignerProtocol {
    static func sign(signRequest: URL, secretKey: String, accessKey: String, sessionToken: String, wssRequest: URL, region: String) -> URL?
}

extension KVSSigner: KVSSignerProtocol {}

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
