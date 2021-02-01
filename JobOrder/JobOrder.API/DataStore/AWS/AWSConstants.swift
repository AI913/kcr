//
//  AWSConstants.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/08.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import AWSIoT

struct AWSConstants {

    // ******** AWS IoT ********
    struct IoT {
        static let region: AWSRegionType = .APNortheast1
        // AWSIoT->設定
        static let endPoint = "https://a12gsp6qvhs13x-ats.iot.ap-northeast-1.amazonaws.com"
        static let ctrlManagerKey = "IOT_CTRL_KCRDEV_KC"
        static let dataManagerKey = "IOT_DATA_KCRDEV_KC"

        struct DistinguishedName {
            static let commonName = Bundle.main.bundleIdentifier!
            static let country = "JP"
            static let organizationName = "Kyocera Corporation"
            static let organizationalUnitName = "Robotics"
        }

        // AWSIoT->安全性->ポリシー
        static let principalPolicyName = "App-JobOrder"
    }

    struct APIGateway {
        
        // static let endPoint: String = "https://k77q3ycfi1.execute-api.ap-northeast-1.amazonaws.com/DEV"
                 static let endPoint: String = "https://e5yhmtp0ib.execute-api.ap-northeast-1.amazonaws.com/dev"
//        static let endPoint: String = "https://uw1j4xtk1h.execute-api.ap-northeast-1.amazonaws.com/joa_phase1"
    }

    struct S3 {
        static let region: AWSRegionType = .APNortheast1
        struct Bucket {
            static let jobDocument: String = "kcr-jobfile"
            static let actionImage: String = "krc-action-image"
            static let aiImage: String = "krc-ai-image"
        }
    }

    struct IAM {
        struct Role {
            static let s3DownloadArn: String = "arn:aws:iam::701006255006:role/IoT-Job-KCR-S3Download"
        }
    }

    class KVS {
        static let region: AWSRegionType = .APNortheast1
        static let managerKey = "KVS_KCRDEV_KC"
    }
}

extension AWSRegionType {

    var stringValue: String {
        switch self {
        case .APNortheast1: return "ap-northeast-1"
        default:
            return ""
        }
    }
}
