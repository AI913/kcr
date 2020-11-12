//
//  CloudStorageRepository.swift
//  JobOrder.API
//
//  Created by Yu Suzuki on 2020/05/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

/// @mockable
public protocol CloudStorageRepository {
    func uploadJsonText(bucketType: CloudStorageEntity.BucketType, key: String, document: APITaskEntity.Document) -> AnyPublisher<Bool, Error>
    func getText(bucketType: CloudStorageEntity.BucketType, key: String) -> AnyPublisher<Bool, Error>
    func getData(bucketType: CloudStorageEntity.BucketType, key: String) -> AnyPublisher<Bool, Error>
}
