//
//  AboutAppPresenter.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/03/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Domain

// MARK: - Interface
/// AboutAppPresenterProtocol
/// @mockable
protocol AboutAppPresenterProtocol {
    /// アプリ名
    var appName: String? { get }
    /// アプリバージョン
    var appVersion: String { get }
    /// Thing名
    var thingName: String? { get }
}

// MARK: - Implementation
/// AboutAppPresenter
class AboutAppPresenter {

    /// SettingsUseCaseProtocol
    private let useCase: JobOrder_Domain.SettingsUseCaseProtocol
    /// AboutAppViewControllerProtocol
    private let vc: AboutAppViewControllerProtocol

    /// イニシャライザ
    /// - Parameters:
    ///   - useCase: SettingsUseCaseProtocol
    ///   - vc: AboutAppViewControllerProtocol
    required init(useCase: JobOrder_Domain.SettingsUseCaseProtocol,
                  vc: AboutAppViewControllerProtocol) {
        self.useCase = useCase
        self.vc = vc
    }
}

// MARK: - Protocol Function
extension AboutAppPresenter: AboutAppPresenterProtocol {

    /// アプリ名
    var appName: String? {
        Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
    }

    /// アプリバージョン
    var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return "Ver. \(version) (\(build))"
    }

    /// Thing名
    var thingName: String? {
        useCase.thingName
    }
}
