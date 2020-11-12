//
//  CloudStorageEntity+AWSS3.swift
//  JobOrder.API
//
//  Created by Yu Suzuki on 2020/05/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

extension CloudStorageEntity.Bucket {

    init(_ type: CloudStorageEntity.BucketType) {

        switch type {
        case .jobDocument:
            self.name = AWSConstants.S3.Bucket.jobDocument
        case .actionImage:
            self.name = AWSConstants.S3.Bucket.actionImage
        case .aiImage:
            self.name = AWSConstants.S3.Bucket.aiImage
        }
    }
}
