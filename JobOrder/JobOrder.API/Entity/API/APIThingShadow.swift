//
//  APIThingShadow.swift
//  JobOrder.API
//
//  Created by Yu Suzuki on 2020/06/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

public struct APIThingShadow {

    public func shadowState(topic: String, payload: String) -> String? {
        guard let thingName = Interact().getThingName(topic: topic) else { return nil }

        switch topic {
        case Interact().topicGetThisThingShadowAccepted(thingName):
            return shadowStateFromShadowGetAccepted(payload)
        case Interact().topicUpdateThingShadowDocuments(thingName):
            return shadowStateFromShadowUpdateDocuments(payload)
        default:
            return nil
        }

        // if topic.hasSuffix("/jobs/get/accepted") {
        // return detectMessageFromJobsGetAccepted(payload)
        // } else if topic.hasSuffix("/jobs/notify") {
        // return detectMessageFromNotifyJobs(payload)
        // }
    }

    /// Get this thing shadow acceptedで取得したデータからShadow Stateを取得
    /// - Parameter payload: ペイロード
    /// - Returns: Shadow State
    func shadowStateFromShadowGetAccepted(_ payload: String) -> String {
        let data = Shadow().parseShadowGetAccepted(payload)
        return data?.state.reported?.state ?? "unknown" // 空データの場合はunknownで返す
    }

    /// Update this thing shadow documentsで取得したデータからShadow Stateを取得
    /// - Parameter payload: ペイロード
    /// - Returns: Shadow State
    func shadowStateFromShadowUpdateDocuments(_ payload: String) -> String {
        let data = Shadow().parseShadowUpdateDocuments(payload)
        return data?.current.state.reported?.state ?? "unknown" // 空データの場合はunknownで返す
    }

    /// シャドウ
    struct Shadow {

        struct ThingShadow: Codable {
            public let state: String
        }

        struct ThingShadowMetaData: Codable {
            public let state: ThingShadowMetaDataItem
        }

        struct ThingShadowMetaDataItem: Codable {
            public let timestamp: Int
        }

        struct ShadowUpdateDocuments<T1: Codable, T2: Codable>: Codable {
            public let current: ShadowUpdateDocumentItem<T1, T2>
            public let previous: ShadowUpdateDocumentItem<T1, T2>?
            public let timestamp: Int
        }

        struct ShadowUpdateDocumentItem<T1: Codable, T2: Codable>: Codable {
            public let state: ThingShadowState<T1>
            public let metadata: ThingShadowState<T2>
            public let version: Int
        }

        struct ShadowGetAccepted<T1: Codable, T2: Codable>: Codable {
            public let state: ThingShadowState<T1>
            public let metadata: ThingShadowState<T2>
            public let version: Int
            public let timestamp: Int
        }

        struct ThingShadowState<T: Codable>: Codable {
            public let desired: T?
            public let reported: T?
            public let delta: T?
        }

        /// Get this thing shadow acceptedで取得したデータをデコード
        /// - Parameter payload: ペイロード
        /// - Returns: デコード結果
        func parseShadowGetAccepted(_ payload: String) -> ShadowGetAccepted<ThingShadow, ThingShadowMetaData>? {

            guard let data = payload.data(using: .utf8) else { return nil }

            do {
                let decoder = JSONDecoder()
                return try decoder.decode(ShadowGetAccepted<ThingShadow, ThingShadowMetaData>.self, from: data)
            } catch {
                print("error:", error.localizedDescription)
            }
            return nil
        }

        /// Update this thing shadow documentsで取得したデータをデコード
        /// - Parameter payload: ペイロード
        /// - Returns: デコード結果
        func parseShadowUpdateDocuments(_ payload: String) -> ShadowUpdateDocuments<ThingShadow, ThingShadowMetaData>? {

            guard let data = payload.data(using: .utf8) else { return nil }

            do {
                let decoder = JSONDecoder()
                return try decoder.decode(ShadowUpdateDocuments<ThingShadow, ThingShadowMetaData>.self, from: data)
            } catch {
                print("error:", error.localizedDescription)
            }
            return nil
        }
    }

    /// 操作
    struct Interact {
        /// Things名のPrefix
        private let prefixThings = "$aws/things/"

        /// トピックからThing名を取得
        /// - Parameter topic: トピック
        /// - Returns: Thing名
        func getThingName(topic: String) -> String? {
            let strings = topic.components(separatedBy: "/")
            guard case strings.indices = 2 else { return nil }
            return strings[2]
        }

        /// Thing名で指定した全てのThing Shadowを取得するトピックを取得
        /// - Parameter thingName: Thing名
        /// - Returns: トピック
        func topicThingAll(_ thingName: String) -> String? {
            if thingName == "" { return nil }
            return prefixThings + thingName + "/#"
        }

        /// Update to this thing shadow
        /// - Parameter thingName: Thing名
        /// - Returns: トピック
        func topicUpdateToThisThingShadow(_ thingName: String) -> String? {
            if thingName == "" { return nil }
            return prefixThings + thingName + "/shadow/update"
        }

        /// Update to this thing shadow was accepted
        /// - Parameter thingName: Thing名
        /// - Returns: トピック
        func topicUpdateToThisThingShadowWasAccepted(_ thingName: String) -> String? {
            if thingName == "" { return nil }
            return prefixThings + thingName + "/shadow/update/accepted"
        }

        /// Update this thing shadow documents
        /// - Parameter thingName: Thing名
        /// - Returns: トピック
        func topicUpdateThingShadowDocuments(_ thingName: String) -> String? {
            if thingName == "" { return nil }
            return prefixThings + thingName + "/shadow/update/documents"
        }

        /// Update to this thing shadow was rejected
        /// - Parameter thingName: Thing名
        /// - Returns: トピック
        func topicUpdateToThisThingShadowWasRejected(_ thingName: String) -> String? {
            if thingName == "" { return nil }
            return prefixThings + thingName + "/shadow/update/rejected"
        }

        /// Get this thing shadow
        /// - Parameter thingName: Thing名
        /// - Returns: トピック
        func topicGetThisThingShadow(_ thingName: String) -> String? {
            if thingName == "" { return nil }
            return prefixThings + thingName + "/shadow/get"
        }

        /// Get this thing shadow accepted
        /// - Parameter thingName: Thing名
        /// - Returns: トピック
        func topicGetThisThingShadowAccepted(_ thingName: String) -> String? {
            if thingName == "" { return nil }
            return prefixThings + thingName + "/shadow/get/accepted"
        }

        /// Getting this thing shadow was rejected
        /// - Parameter thingName: Thing名
        /// - Returns: トピック
        func topicGettingThisThingShadowWasRejected(_ thingName: String) -> String? {
            if thingName == "" { return nil }
            return prefixThings + thingName + "/shadow/get/rejected"
        }

        /// Delete this thing shadow
        /// - Parameter thingName: Thing名
        /// - Returns: トピック
        func topicDeleteThisThingShadow(_ thingName: String) -> String? {
            if thingName == "" { return nil }
            return prefixThings + thingName + "/shadow/delete"
        }

        /// Deleting this thing shadow was accepted
        /// - Parameter thingName: Thing名
        /// - Returns: トピック
        func topicDeletingThisThingShadowWasAccepted(_ thingName: String) -> String? {
            if thingName == "" { return nil }
            return prefixThings + thingName + "/shadow/delete/accepted"
        }

        /// Deleting this thing shadow was rejected
        /// - Parameter thingName: Thing名
        /// - Returns: トピック
        func topicDeletingThisThingShadowWasRejected(_ thingName: String) -> String? {
            if thingName == "" { return nil }
            return prefixThings + thingName + "/shadow/delete/rejected"
        }
    }
}
