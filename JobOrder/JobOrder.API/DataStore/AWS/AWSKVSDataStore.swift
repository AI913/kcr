//
//  AWSKVSDataStore.swift
//  JobOrder.API
//
//  Created by Yu Suzuki on 2020/05/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import AWSMobileClient
import AWSKinesisVideo
import AWSKinesisVideoSignaling
import WebRTC
import JobOrder_Utility

/// AWS KVSを操作する
public class AWSKVSDataStore: VideoStreamingRepository {

    /// Factory
    let factory = AWSSDKFactory.shared
    /// Signaling接続状態配信
    private var signalingConnectionStatusPublisher = PassthroughSubject<VideoStreamingEntity.Output.SignalingConnectionStatus, Never>()
    /// SDP受信通知
    private var receiveRemoteSdpPublisher = PassthroughSubject<VideoStreamingEntity.Output.ReceiveRemoteSdp, Never>()
    /// ICE Candidate受信通知
    private var receiveIceCandidatePublisher = PassthroughSubject<VideoStreamingEntity.Output.ReceiveIceCandidate, Never>()
    /// SignalingClient
    var signalingClient: SignalingClientProtocol?
    /// Local Client ID
    private let localSenderClientId = NSUUID().uuidString.lowercased()
    /// Remote Client ID
    private var remoteSenderClientId = "ConsumerViewer"
    /// Master or Viewer
    private var isMaster: Bool = true

    /// イニシャライザ
    public init() {}

    /// 初期化
    public func initialize() {
        factory.generateKVS()
    }

    /// Signaling接続状態通知イベントの登録
    /// - Returns: 接続状態
    public func registerSignalingConnectionStatusChange() -> AnyPublisher<VideoStreamingEntity.Output.SignalingConnectionStatus, Never> {
        return signalingConnectionStatusPublisher.eraseToAnyPublisher()
    }

    /// Signaling接続状態通知イベントの解除
    public func unregisterSignalingConnectionStatusChange() {}

    /// SDP受信通知イベントの登録
    /// - Returns: SDP
    public func registerReceiveRemoteSdp() -> AnyPublisher<VideoStreamingEntity.Output.ReceiveRemoteSdp, Never> {
        return receiveRemoteSdpPublisher.eraseToAnyPublisher()
    }

    /// SDP受信通知イベントの解除
    public func unregisterReceiveRemoteSdp() {}

    /// ICE Candidate受信通知イベントの登録
    /// - Returns: ICE Candidate
    public func registerReceiveIceCandidate() -> AnyPublisher<VideoStreamingEntity.Output.ReceiveIceCandidate, Never> {
        return receiveIceCandidatePublisher.eraseToAnyPublisher()
    }

    /// ICE Candidate受信通知イベントの解除
    public func unregisterReceiveIceCandidate() {}

    /// 指定したRoleで接続
    /// - Parameter isMaster: Master or Viewer
    /// - Returns: 接続結果
    public func connectAsRole(isMaster: Bool) -> AnyPublisher<VideoStreamingEntity.Output.Connect, Error> {
        Logger.info(target: self)
        self.isMaster = isMaster

        return Future<VideoStreamingEntity.Output.Connect, Error> { promise in

            let channelName = UIDevice.current.identifierForVendor!.uuidString

            self.getChannelArn(channelName) { (state, arn, error) -> Void in

                if let error = error {
                    promise(.failure(AWSError.kvsControlFailed(reason: .awsTask(error: error))))
                    return
                }

                guard state == .completed else {
                    promise(.failure(AWSError.kvsControlFailed(reason: .getChannelARNisNotCompleted)))
                    return
                }

                guard let arn = arn else {
                    promise(.failure(AWSError.kvsControlFailed(reason: .getChannelARNisNotAvailable)))
                    return
                }

                self.getSignedWSSUrl(arn, self.localSenderClientId) { (state, _result, error) -> Void in

                    guard state == .completed else {
                        promise(.failure(AWSError.kvsControlFailed(reason: .getSignedWSSURLisNotCompleted)))
                        return
                    }

                    guard let result = _result else {
                        promise(.failure(AWSError.kvsControlFailed(reason: .getSignedWSSURL_ICEServerListisNotAvailable)))
                        return
                    }

                    self.signalingClient = SignalingClient(serverUrl: result.wssUrl)
                    self.signalingClient?.delegate = self
                    self.signalingClient?.connect()

                    let entity = VideoStreamingEntity.Output.Connect(iceServerList: result.iceServerList)
                    promise(.success(entity))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// 切断
    public func disconnect() -> AnyPublisher<VideoStreamingEntity.Output.Disconnect, Never> {

        return Future<VideoStreamingEntity.Output.Disconnect, Never> { promise in
            self.signalingClient?.disconnect()
            let entity = VideoStreamingEntity.Output.Disconnect()
            promise(.success(entity))
        }.eraseToAnyPublisher()
    }

    /// シグナリングサーバーへSDP送信
    /// - Parameter input: sdp, Offer or Answer
    public func sendSdp(input: VideoStreamingEntity.Input.SendSdp) {
        if input.isOffer {
            signalingClient?.sendOffer(rtcSdp: input.sdp, senderClientid: localSenderClientId)
        } else {
            signalingClient?.sendAnswer(rtcSdp: input.sdp, recipientClientId: remoteSenderClientId)
        }
    }

    /// シグナリングサーバーへICE Candidate送信
    /// - Parameter input: ICE Candidate
    public func sendIceCandidate(input: VideoStreamingEntity.Input.SendIceCandidate) {
        signalingClient?.sendIceCandidate(rtcIceCandidate: input.candidate,
                                          master: isMaster,
                                          recipientClientId: remoteSenderClientId,
                                          senderClientId: localSenderClientId)
    }
}

// MARK: - Private functions
extension AWSKVSDataStore {

    /// チャネル名からARNを取得
    /// KVSから取得し、存在しなければ作成する
    /// - Parameters:
    ///   - channelName: チャネル名
    ///   - callback: 結果
    func getChannelArn(_ channelName: String, callback: ((_ state: APITaskEntity.State, _ info: String?, _ error: Error?) -> Void)?) {

        retrieveChannelArn(channelName) { (state, info, error) -> Void in
            if state == .completed, let info = info, let arn = info.channelARN {
                callback?(state, arn, error)
                return
            }
            self.createChannel(channelName) { (state, arn, error) -> Void in
                callback?(state, arn, error)
            }
        }
    }

    /// チャネル名からチャネル情報を取得する
    /// - Parameters:
    ///   - channelName: チャネル名
    ///   - callback: チャネル情報
    func retrieveChannelArn(_ channelName: String, callback: ((_ state: APITaskEntity.State, _ info: AWSKinesisVideoChannelInfo?, _ error: Error?) -> Void)?) {
        let input = AWSKinesisVideoDescribeSignalingChannelInput()!
        input.channelName = channelName
        factory.kinesisVideo?.describeSignalingChannel(input).continueWith { (task) -> Void in
            callback?(APITaskEntity.State(task), task.result?.channelInfo, task.error)
        }
    }

    /// チャネル名からチャネルを作成する
    /// - Parameters:
    ///   - channelName: チャネル名
    ///   - callback: チャネル情報
    func createChannel(_ channelName: String, callback: ((_ state: APITaskEntity.State, _ arn: String?, _ error: Error?) -> Void)?) {
        let input = AWSKinesisVideoCreateSignalingChannelInput()!
        input.channelName = channelName
        factory.kinesisVideo?.createSignalingChannel(input).continueWith { (task) -> Void in
            callback?(APITaskEntity.State(task), task.result?.channelARN, task.error)
        }
    }

    /// AWSKVSからICEサーバーのリストを取得し、WebRTCのICEサーバーリストへ変換して取得する
    /// - Parameters:
    ///   - channelArn: チャネルARN
    ///   - clientId: クライアントID
    ///   - callback: WebRTCのICEサーバーリスト
    func getSignedWSSUrl(_ channelArn: String, _ clientId: String, callback: ((_ state: APITaskEntity.State, (wssUrl: URL, httpUrl: URL, iceServerList: [RTCIceServer])?, _ error: Error?) -> Void)?) {

        getSignalingChannelEndpoint(channelArn, clientId) { (state, result, error) -> Void in

            guard state == .completed, let result = result else {
                callback?(state, nil, error)
                return
            }

            let wssUrl = result.wssUrl
            let httpUrl = result.httpUrl

            self.getIceServerConfig(httpUrl, channelArn, clientId) { (state, iceServerList, error) -> Void in

                guard state == .completed, let iceServerList = iceServerList else {
                    callback?(state, nil, error)
                    return
                }

                var rTCIceServerList = [RTCIceServer]()

                for iceServer in iceServerList {
                    rTCIceServerList.append(RTCIceServer(urlStrings: iceServer.uris!, username: iceServer.username, credential: iceServer.password))
                }
                rTCIceServerList.append(RTCIceServer(urlStrings: ["stun:stun.kinesisvideo." + AWSConstants.KVS.region.stringValue + ".amazonaws.com:443"]))

                callback?(state, (wssUrl: wssUrl, httpUrl: httpUrl, iceServerList: rTCIceServerList), error)
            }
        }
    }

    /// ARNとClientIdからシグナリングチャネルのエンドポイントを取得する
    /// - Parameters:
    ///   - channelArn: チャネルARN
    ///   - clientId: クライアントID
    ///   - callback: エンドポイント
    func getSignalingChannelEndpoint(_ channelArn: String, _ clientId: String, callback: ((_ state: APITaskEntity.State, (wssUrl: URL, httpUrl: URL)?, _ error: Error?) -> Void)?) {

        let configuration = AWSKinesisVideoSingleMasterChannelEndpointConfiguration()!
        configuration.protocols = ["WSS", "HTTPS"]
        configuration.role = isMaster ? .master : .viewer

        let input = AWSKinesisVideoGetSignalingChannelEndpointInput()!
        input.channelARN = channelArn
        input.singleMasterChannelEndpointConfiguration = configuration

        factory.kinesisVideo?.getSignalingChannelEndpoint(input).continueWith { (task) -> Void in

            let state = APITaskEntity.State(task)

            guard state == .completed,
                  let result = task.result,
                  let resourceEndpointList = result.resourceEndpointList else {
                callback?(state, nil, task.error)
                return
            }

            var _httpResourceEndpointItem: AWSKinesisVideoResourceEndpointListItem?
            var _wssResourceEndpointItem: AWSKinesisVideoResourceEndpointListItem?

            for endpoint in resourceEndpointList {
                switch endpoint.protocols {
                case .https:
                    _httpResourceEndpointItem = endpoint
                case .wss:
                    _wssResourceEndpointItem = endpoint
                default:
                    print("Error: Unknown endpoint protocol ", endpoint.protocols, "for endpoint" + endpoint.description())
                }
            }

            guard let httpResourceEndpointItem = _httpResourceEndpointItem,
                  let httpResourceEndpoint = httpResourceEndpointItem.resourceEndpoint,
                  let wssResourceEndpointItem = _wssResourceEndpointItem,
                  let wssResourceEndpoint = wssResourceEndpointItem.resourceEndpoint else {
                callback?(.faulted, nil, AWSError.kvsControlFailed(reason: .httpResourceEndpointORwssResourceEndpointIsNotAvailable))
                return
            }

            guard let wssUrl = URL(string: wssResourceEndpoint),
                  let httpUrl = URL(string: httpResourceEndpoint),
                  var wssUrlComponents = URLComponents(url: wssUrl, resolvingAgainstBaseURL: nil != wssUrl.baseURL) else {
                callback?(.faulted, nil, AWSError.kvsControlFailed(reason: .wssUrlORhttpUrlIsNotAvailable))
                return
            }

            if self.isMaster {
                wssUrlComponents.queryItems = [
                    URLQueryItem(name: "X-Amz-ChannelARN", value: channelArn)
                ]
            } else {
                wssUrlComponents.queryItems = [
                    URLQueryItem(name: "X-Amz-ChannelARN", value: channelArn),
                    URLQueryItem(name: "X-Amz-ClientId", value: clientId)
                ]
            }

            self.factory.mobileClient?.getAWSCredentials { credentials, error in

                guard let credentials = credentials, let sessionKey = credentials.sessionKey else {
                    callback?(.faulted, nil, error)
                    return
                }

                let _wssUrl = self.factory.kvsSignerClass.sign(signRequest: wssUrlComponents.url!,
                                                               secretKey: credentials.secretKey,
                                                               accessKey: credentials.accessKey,
                                                               sessionToken: sessionKey,
                                                               wssRequest: wssUrl,
                                                               region: AWSConstants.KVS.region.stringValue)

                guard let wssUrl = _wssUrl else {
                    callback?(.faulted, nil, AWSError.kvsControlFailed(reason: .wssUrlIsNotAvailable))
                    return
                }

                callback?(state, (wssUrl: wssUrl, httpUrl: httpUrl), error)
            }
        }
    }

    /// AWSKVSからICEサーバーのリストを取得する
    /// - Parameters:
    ///   - endpointUrl: HTTP URL
    ///   - channelArn: チャネルURL
    ///   - clientId: クライアントID
    ///   - callback: ICEサーバーのConfig
    func getIceServerConfig(_ endpointUrl: URL, _ channelArn: String, _ clientId: String, callback: ((_ state: APITaskEntity.State, _ iceServerList: [AWSKinesisVideoSignalingIceServer]?, _ error: Error?) -> Void)?) {

        // Get the List of Ice Server Config and store it in the self.iceServerList.
        guard let endpoint =
                factory.endpointClass.init(region: AWSConstants.KVS.region,
                                           service: .KinesisVideo,
                                           url: endpointUrl) as? AWSEndpoint else { return }

        guard let configuration =
                factory.serviceConfigurationClass.init(region: AWSConstants.KVS.region,
                                                       endpoint: endpoint,
                                                       credentialsProvider: factory.mobileClient as? AWSMobileClient) as? AWSServiceConfiguration else { return }

        factory.kinesisVideoSignalingClass.remove(forKey: AWSConstants.KVS.managerKey)
        factory.kinesisVideoSignalingClass.register(with: configuration, forKey: AWSConstants.KVS.managerKey)

        let iceServerConfigRequest = AWSKinesisVideoSignalingGetIceServerConfigRequest()!
        iceServerConfigRequest.channelARN = channelArn
        iceServerConfigRequest.clientId = clientId
        factory.kinesisVideoSignaling?.getIceServerConfig(iceServerConfigRequest).continueWith(block: { (task) -> Void in
            callback?(APITaskEntity.State(task), task.result?.iceServerList, task.error)
        })
    }
}

// MARK: - Implement SignalClientDelegate
extension AWSKVSDataStore: SignalClientDelegate {

    func signalClientDidConnect(_ signalClient: SignalingClient) {
        let entity: VideoStreamingEntity.Output.SignalingConnectionStatus = .connected
        signalingConnectionStatusPublisher.send(entity)
    }

    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        let entity: VideoStreamingEntity.Output.SignalingConnectionStatus = .disconnected
        signalingConnectionStatusPublisher.send(entity)
    }

    func signalClient(_ signalClient: SignalingClient, senderClientId: String, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        remoteSenderClientId = senderClientId
        let entity = VideoStreamingEntity.Output.ReceiveRemoteSdp(sdp: sdp)
        receiveRemoteSdpPublisher.send(entity)
    }

    func signalClient(_ signalClient: SignalingClient, senderClientId: String, didReceiveCandidate candidate: RTCIceCandidate) {
        remoteSenderClientId = senderClientId
        let entity = VideoStreamingEntity.Output.ReceiveIceCandidate(candidate: candidate)
        receiveIceCandidatePublisher.send(entity)
    }
}

/// @mockable
protocol SignalingClientProtocol {
    var delegate: SignalClientDelegate? { get set }
    func connect()
    func disconnect()
    func sendOffer(rtcSdp: RTCSessionDescription, senderClientid: String)
    func sendAnswer(rtcSdp: RTCSessionDescription, recipientClientId: String)
    func sendIceCandidate(rtcIceCandidate: RTCIceCandidate, master: Bool, recipientClientId: String, senderClientId: String)
}

extension SignalingClient: SignalingClientProtocol {}
