//
//  CloudStorageEntity.swift
//  JobOrder.API
//
//  Created by Yu Suzuki on 2020/05/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

public struct CloudStorageEntity {

    struct Bucket {
        let name: String
    }

    public enum BucketType {
        case jobDocument
        case actionImage
        case aiImage
    }
}
