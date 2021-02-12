//
//  AWSS3DataStore.swift
//  JobOrder.API
//
//  Created by Yu Suzuki on 2020/05/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import AWSS3

public class AWSS3DataStore: CloudStorageRepository {

    public init() {}

    /// Upload Json text to AWS S3
    public func uploadJsonText(bucketType: CloudStorageEntity.BucketType, key: String, document: APITaskEntity.Document) -> AnyPublisher<Bool, Error> {

        return Future<Bool, Error> { promise in
            let bucket = CloudStorageEntity.Bucket(bucketType)
            let body: String
            do {
                let data = try JSONEncoder().encode(document)
                body = String(data: data, encoding: .utf8)!
            } catch let error {
                promise(.failure(AWSError.s3ControlFailed(error: error)))
                return
            }

            AWSS3TransferUtility.default().uploadData(body.data(using: .utf8)!,
                                                      bucket: bucket.name,
                                                      key: key,
                                                      contentType: "application/json",
                                                      expression: nil,
                                                      completionHandler: { (_, error) -> Void in
                                                        if let error = error {
                                                            promise(.failure(AWSError.s3ControlFailed(error: error)))
                                                        } else {
                                                            promise(.success(true))
                                                        }
                                                      }).continueWith { (task) -> AnyObject? in
                                                        return nil
            }
        }.eraseToAnyPublisher()
    }

    /// Download text to AWS S3
    public func getText(bucketType: CloudStorageEntity.BucketType, key: String) -> AnyPublisher<Bool, Error> {

        return Future<Bool, Error> { promise in
            let bucket = CloudStorageEntity.Bucket(bucketType)
            AWSS3TransferUtility.default().downloadData(fromBucket: bucket.name, key: key, expression: nil, completionHandler: { (task, location, data, error) -> Void in
                if let error = error {
                    promise(.failure(AWSError.s3ControlFailed(error: error)))
                } else {
                    promise(.success(true))
                }
            }).continueWith { (task) -> AnyObject? in
                return nil
            }
        }.eraseToAnyPublisher()

    }

    /// Download data to AWS S3
    public func getData(bucketType: CloudStorageEntity.BucketType, key: String) -> AnyPublisher<Bool, Error> {

        return Future<Bool, Error> { promise in
            let bucket = CloudStorageEntity.Bucket(bucketType)
            AWSS3TransferUtility.default().downloadData(fromBucket: bucket.name, key: key, expression: nil, completionHandler: { (task, location, data, error) -> Void in
                if let error = error {
                    promise(.failure(AWSError.s3ControlFailed(error: error)))
                } else {
                    promise(.success(true))
                }
            }).continueWith { (task) -> AnyObject? in
                return nil
            }
        }.eraseToAnyPublisher()
    }
}
