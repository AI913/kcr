//
//  AnalyticsUseCase.swift
//  JobOrder.Domain
//
//  Created by Yu Suzuki on 2020/12/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import JobOrder_API
import JobOrder_Utility

// MARK: - Interface
/// AnalyticsUseCaseProtocol
/// @mockable
public protocol AnalyticsUseCaseProtocol {
    /// エンドポイントID
    var endpointId: String? { get }
    /// 表示モード設定
    /// - Parameter value: 表示モード
    func setDisplayAppearance(_ value: String)
    /// ユーザー名設定
    /// - Parameter value: ユーザー名
    func setUserName(_ value: String)
    /// 生体認証有無設定
    /// - Parameter value: 生体認証有無
    func setBiometricsSetting(_ value: Bool)
    /// ボタンイベント送信
    /// - Parameters:
    ///   - name: イベント名
    ///   - view: View名
    func recordEventButton(name: String, view: String)
    /// スイッチイベント送信
    /// - Parameters:
    ///   - name: イベント名
    ///   - view: View名
    ///   - isOn: スイッチON/OFF
    func recordEventSwitch(name: String, view: String, isOn: Bool)
}

// MARK: - Implementation
/// AnalyticsUseCase
public class AnalyticsUseCase: AnalyticsUseCaseProtocol {

    /// AnalyticsServiceレポジトリ
    private let analytics: JobOrder_API.AnalyticsServiceRepository

    /// イニシャライザ
    /// - Parameters:
    ///   - analyticsServiceRepository: AnalyticsServiceレポジトリ
    public required init(analyticsServiceRepository: JobOrder_API.AnalyticsServiceRepository) {
        self.analytics = analyticsServiceRepository
    }

    /// エンドポイントID
    public var endpointId: String? {
        analytics.endpointId
    }

    /// 表示モード設定
    /// - Parameter value: 表示モード
    public func setDisplayAppearance(_ value: String) {
        analytics.updateEndpointProfile("Display Appearance", value: value)
    }

    /// ユーザー名設定
    /// - Parameter value: ユーザー名
    public func setUserName(_ value: String) {
        analytics.updateEndpointProfile("User name", value: value)
    }

    /// 生体認証有無設定
    /// - Parameter value: 生体認証有無
    public func setBiometricsSetting(_ value: Bool) {
        analytics.updateEndpointProfile("Biometrics", value: value ? "true" : "false")
    }

    /// ボタンイベント送信
    /// - Parameters:
    ///   - name: イベント名
    ///   - view: View名
    public func recordEventButton(name: String, view: String) {
        analytics.recordEvent("tapButton", parameters: ["name": name, "view": view], metrics: ["count": 1])
    }

    /// スイッチイベント送信
    /// - Parameters:
    ///   - name: イベント名
    ///   - view: View名
    ///   - isOn: スイッチON/OFF
    public func recordEventSwitch(name: String, view: String, isOn: Bool) {
        analytics.recordEvent("changedSwitch", parameters: ["name": name, "view": view, "isOn": isOn ? "true" : "false"], metrics: ["count": 1])
    }
}
