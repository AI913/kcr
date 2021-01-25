//
//  AWSError.swift
//  JobOrder.API
//
//  Created by 藤井一暢 on 2020/12/28.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import AWSMobileClient

public enum AWSError: Error {

    public enum AuthenticationFailureReason {
        public init(_ error: Error) {
            if let error = error as? AWSMobileClientError {
                self = .awsMobileClientFailed(error: error)
                return
            }
            self = .unknown(error: error)
        }
        case awsMobileClientFailed(error: AWSMobileClientError)
        case unknown(error: Error)
    }

    public enum IoTControlFailureReason {
        case awsIoTClientFailed(error: Error)
        case connectionFailed(reason: connectionFailureReason)

        public enum connectionFailureReason {
            /// Client ID is not available.
            case clientIDisNotAvailable
            /// Connect failed.
            case connectFailed
        }
    }

    public enum KVSControlFailureReason {
        case awsTask(error: Error)
        /// Get Channel ARN is not completed.
        case getChannelARNisNotCompleted
        /// Get Channel ARN is not available.
        case getChannelARNisNotAvailable
        /// Get Signed WSS URL is not completed.
        case getSignedWSSURLisNotCompleted
        /// Get Signed WSS URL, ICE Server List is not available.
        case getSignedWSSURL_ICEServerListisNotAvailable
        /// httpResourceEndpoint or wssResourceEndpoint is not available.
        case httpResourceEndpointORwssResourceEndpointIsNotAvailable
        /// wssUrl or httpUrl is not available.
        case wssUrlORhttpUrlIsNotAvailable
        /// wssUrl is not available.
        case wssUrlIsNotAvailable
    }

    case authenticationFailed(reason: AuthenticationFailureReason)
    case ioTControlFailed(reason: IoTControlFailureReason)
    case s3ControlFailed(error: Error)
    case kvsControlFailed(reason: KVSControlFailureReason)
}
