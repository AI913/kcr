//
//  WebRTCEvent.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/02/21.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

// https://github.com/awslabs/amazon-kinesis-video-streams-webrtc-sdk-ios

import Foundation
import WebRTC
import JobOrder_Utility

public class WebRTCEvent {

    public class func parseEvent(event: String) -> WebRTCMessage? {
        do {
            print("Event = \(event)")

            let payLoad = try event.convertToDictionaryValueAsString()

            if payLoad.count >= 2 {
                print(payLoad)

                let messageType: String = payLoad["messageType"]!
                let messagePayload: String = payLoad["messagePayload"]!
                if let senderClientId = payLoad["senderClientId"] {
                    print("senderClientId : \(senderClientId)")
                    return WebRTCMessage(messageType, "", senderClientId, messagePayload)
                } else {
                    return WebRTCMessage(messageType, "", "", messagePayload)
                }
            }

        } catch {
            print("payload Error \(error)")
        }
        return nil
    }
}
