//
//  APITaskEntity+AWS.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/06.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import AWSCore
import AWSIoT

extension APITaskEntity.State {

    /// AWS -> エンティティ変換
    /// - Parameter task: Task
    public init<T>(_ task: AWSTask<T>) {
        if task.isFaulted {
            self = .faulted
        } else if task.isCancelled {
            self = .cancelled
        } else if task.isCompleted {
            self = .completed
        } else {
            self = .unknown
        }
    }

    /// AWS -> エンティティ変換
    /// - Parameter error: エラー
    init(_ error: Error?) {
        if error != nil {
            self = .faulted
        } else {
            self = .completed
        }
    }
}
