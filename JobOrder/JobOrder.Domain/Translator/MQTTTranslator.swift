//
//  MQTTTranslator.swift
//  JobOrder.Domain
//
//  Created by Yu Suzuki on 2020/05/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import JobOrder_API

/// MQTTデータ変換
struct MQTTTranslator {

    /// モデル -> エンティティ変換
    /// - Parameter model: モデル
    /// - Returns: エンティティ
    func toData(model: MQTTModel.Input.CreateJob?) -> JobOrder_API.APITaskEntity.Document? {
        guard let model = model else { return nil }

        return JobOrder_API.APITaskEntity.Document(jobId: model.jobId,
                                                   startCondition: model.startCondition?.rawValue,
                                                   exitCondition: model.exitCondition?.rawValue,
                                                   numberOfRuns: model.numberOfRuns)
    }
}
