//
//  SignalingClient.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/02/21.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

// https://github.com/awslabs/amazon-kinesis-video-streams-webrtc-sdk-ios

import Foundation
import Starscream
import WebRTC
import JobOrder_Utility

// interface for remote connectivity events
protocol SignalClientDelegate: class {
    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(_ signalClient: SignalingClient, senderClientId: String, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ signalClient: SignalingClient, senderClientId: String, didReceiveCandidate candidate: RTCIceCandidate)
}

final class SignalingClient {
    private let socket: WebSocket
    private let encoder = JSONEncoder()
    weak var delegate: SignalClientDelegate?

    init(serverUrl: URL) {
        socket = WebSocket(url: serverUrl)
    }

    func connect() {
        socket.delegate = self
        socket.connect()
    }

    func disconnect() {
        socket.disconnect()
    }

    func sendOffer(rtcSdp: RTCSessionDescription, senderClientid: String) {
        do {
            debugPrint("Sending SDP offer")
            // debugPrint("Sending SDP offer \(rtcSdp)")
            let message: WebRTCMessage = WebRTCMessage.createOfferMessage(sdp: rtcSdp.sdp, senderClientId: senderClientid)
            let data = try encoder.encode(message)
            let msg = String(data: data, encoding: .utf8)!
            socket.write(string: msg)
            print("Sent SDP offer message over to signaling")
            // print("Sent SDP offer message over to signaling:", msg)

        } catch {
            print(error)
        }
    }

    func sendAnswer(rtcSdp: RTCSessionDescription, recipientClientId: String) {
        do {
            debugPrint("Sending SDP answer")
            // debugPrint("Sending SDP answer\(rtcSdp)")
            let message: WebRTCMessage = WebRTCMessage.createAnswerMessage(sdp: rtcSdp.sdp, recipientClientId)
            let data = try encoder.encode(message)
            let msg = String(data: data, encoding: .utf8)!
            socket.write(string: msg)
            print("Sent SDP answer message over to signaling")
            // print("Sent SDP answer message over to signaling:", msg)
        } catch {
            print(error)
        }
    }

    func sendIceCandidate(rtcIceCandidate: RTCIceCandidate, master: Bool,
                          recipientClientId: String,
                          senderClientId: String) {
        do {
            debugPrint("Sending ICE candidate")
            // debugPrint("Sending ICE candidate \(rtcIceCandidate)")

            let message: WebRTCMessage = WebRTCMessage.createIceCandidateMessage(candidate: rtcIceCandidate,
                                                                                 master,
                                                                                 recipientClientId: recipientClientId,
                                                                                 senderClientId: senderClientId)
            let data = try encoder.encode(message)
            let msg = String(data: data, encoding: .utf8)!
            socket.write(string: msg)
            print("Sent ICE candidate message over to signaling")
            // print("Sent ICE candidate message over to signaling:", msg)
        } catch {
            print(error)
        }
    }
}

// MARK: Websocket
extension SignalingClient: WebSocketDelegate {
    func websocketDidConnect(socket _: WebSocketClient) {
        debugPrint("Connection to signaling success.")
        delegate?.signalClientDidConnect(self)
        // debugPrint("Connection to signaling success.")
    }

    func websocketDidDisconnect(socket _: WebSocketClient, error: Error?) {
        debugPrint("Disconnected from signaling. \(error!)")
        delegate?.signalClientDidDisconnect(self)
        // debugPrint("Disconnected from signaling. \(error!)")
    }

    func websocketDidReceiveData(socket _: WebSocketClient, data: Data) {
        debugPrint("Additional signaling data (not supported) \(data)")
    }

    func websocketDidReceiveMessage(socket _: WebSocketClient, text: String) {
        debugPrint("Additional signaling messages")
        // debugPrint("Additional signaling messages \(text)")
        var parsedMessage: WebRTCMessage?

        parsedMessage = WebRTCEvent.parseEvent(event: text)

        if parsedMessage != nil {
            let messagePayload = parsedMessage?.getMessagePayload()

            let messageType = parsedMessage?.getAction()
            let senderClientId = parsedMessage?.getSenderClientId()
            // todo: add a guard here because some of java base64 encode options might break ios base64 decode unless extended
            let message: String = String(messagePayload!.base64Decoded()!)

            do {
                let jsonObject = try message.trim().convertToDictionary()
                if !jsonObject.isEmpty {
                    if messageType == "SDP_OFFER" {
                        guard let sdp = jsonObject["sdp"] as? String else {
                            return
                        }
                        let rcSessionDescription: RTCSessionDescription = RTCSessionDescription(type: .offer, sdp: sdp)
                        debugPrint("SDP offer received from signaling")
                        delegate?.signalClient(self, senderClientId: senderClientId!, didReceiveRemoteSdp: rcSessionDescription)
                        // debugPrint("SDP offer received from signaling \(sdp)")
                    } else if messageType == "SDP_ANSWER" {
                        guard let sdp = jsonObject["sdp"] as? String else {
                            return
                        }
                        let rcSessionDescription: RTCSessionDescription = RTCSessionDescription(type: .answer, sdp: sdp)
                        debugPrint("SDP answer received from signaling")
                        delegate?.signalClient(self, senderClientId: "", didReceiveRemoteSdp: rcSessionDescription)
                        // debugPrint("SDP answer received from signaling \(sdp)")
                    } else if messageType == "ICE_CANDIDATE" {
                        guard let iceCandidate = jsonObject["candidate"] as? String else {
                            return
                        }
                        guard let sdpMid = jsonObject["sdpMid"] as? String else {
                            return
                        }
                        guard let sdpMLineIndex = jsonObject["sdpMLineIndex"] as? Int32 else {
                            return
                        }
                        let rtcIceCandidate: RTCIceCandidate = RTCIceCandidate(sdp: iceCandidate, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
                        debugPrint("ICE candidate received from signaling")
                        delegate?.signalClient(self, senderClientId: senderClientId!, didReceiveCandidate: rtcIceCandidate)
                        // debugPrint("ICE candidate received from signaling \(iceCandidate)")
                    }
                } else {
                    dump(jsonObject)
                }
            } catch {
                print("payLoad parsing Error \(error)")
            }
        }
    }
}
