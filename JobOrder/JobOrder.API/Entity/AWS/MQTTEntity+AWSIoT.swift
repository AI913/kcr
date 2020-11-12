//
//  MQTTEntity+AWSIoT.swift
//  JobOrder.API
//
//  Created by Yu Suzuki on 2020/03/31.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import AWSIoT

extension MQTTEntity.Output.ConnectionStatus {

    /// AWS -> エンティティ変換
    /// - Parameter status: AWS SDKで保持している接続状態
    init(_ status: AWSIoTMQTTStatus?) {
        switch status {
        case .connecting: self = .connecting
        case .connected:  self = .connected
        case .disconnected: self = .disconnected
        case .connectionRefused: self = .connectionRefused
        case .connectionError: self = .connectionError
        case .protocolError: self = .protocolError
        default: self = .unknown
        }
    }
}
