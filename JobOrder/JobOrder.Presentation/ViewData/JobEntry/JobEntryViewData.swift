//
//  JobEntryViewData.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import UIKit
import JobOrder_Domain

/// JobEntryViewData
struct JobEntryViewData {

    /// 入力フォーム
    var form: Form

    /// イニシャライザ
    /// - Parameters:
    ///   - jobName: 入力したジョブ名
    ///   - robotId: 選択したRobot ID
    ///   - remarks: 入力した備考
    init(_ jobName: String?, _ robotId: String?, _ remarks: String?) {
        self.form = Form(jobName, robotId, remarks)
    }

    /// 入力フォーム
    struct Form {
        /// Job名
        var jobName: String?
        /// Robot IDの配列
        var robotIds: [String]?
        /// 備考
        var remarks: String?

        /// イニシャライザ
        /// - Parameters:
        ///   - jobId: 選択したJob ID
        ///   - robotId: 選択したRobot ID
        init(_ jobName: String?, _ robotId: String?, _ remarks: String?) {
            self.jobName = jobName
            self.robotIds = []
            if let robotId = robotId {
                self.robotIds?.append(robotId)
            }
            self.remarks = remarks
        }
    }
}
