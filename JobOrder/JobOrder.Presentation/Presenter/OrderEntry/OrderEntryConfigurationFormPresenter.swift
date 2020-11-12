//
//  OrderEntryConfigurationFormPresenter.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

// MARK: - Interface
/// OrderEntryConfigurationFormPresenterProtocol
/// @mockable
protocol OrderEntryConfigurationFormPresenterProtocol {
    /// OrderEntryのViewData
    var data: OrderEntryViewData { get }
    /// 稼働開始条件
    var startCondition: String? { get }
    /// 稼働終了条件
    var exitCondition: String? { get }
    /// Continueボタンの有効無効
    var isEnabledContinueButton: Bool { get }
    /// 稼働回数
    var numberOfRuns: String? { get set }
    /// 備考
    var remarks: String? { get set }
    /// IncrementNumberOfRunsボタンをタップ
    /// - Parameter num: 実行回数
    func tapIncrementNumberOfRunsButton(num: Int)
    /// ClearNumberOfRunsボタンをタップ
    func tapClearNumberOfRunsButton()
    /// Continueボタンをタップ
    func tapContinueButton()
}

// MARK: - Implementation
/// OrderEntryConfigurationFormPresenter
class OrderEntryConfigurationFormPresenter {

    /// OrderEntryConfigurationFormViewControllerProtocol
    private let vc: OrderEntryConfigurationFormViewControllerProtocol
    /// OrderEntryのViewData
    var data: OrderEntryViewData

    /// イニシャライザ
    /// - Parameters:
    ///   - vc: OrderEntryConfigurationFormViewControllerProtocol
    ///   - viewData: OrderEntryViewData
    required init(vc: OrderEntryConfigurationFormViewControllerProtocol,
                  viewData: OrderEntryViewData) {
        self.vc = vc
        self.data = viewData
    }
}

// MARK: - Protocol Function
extension OrderEntryConfigurationFormPresenter: OrderEntryConfigurationFormPresenterProtocol {

    /// 稼働開始条件
    var startCondition: String? {
        data.form.startCondition?.displayName
    }

    /// 稼働終了条件
    var exitCondition: String? {
        data.form.exitCondition?.displayName
    }

    /// Continueボタンの有効無効
    var isEnabledContinueButton: Bool {
        guard data.form.numberOfRuns > 0 else { return false }
        return true
    }

    /// 稼働回数
    var numberOfRuns: String? {
        get {
            guard data.form.numberOfRuns > 0 else { return nil }
            return String(data.form.numberOfRuns)
        }
        set {
            if let st = newValue, let num = Int(st) {
                data.form.numberOfRuns = num
            }
        }
    }

    /// 備考
    var remarks: String? {
        get { return data.form.remarks }
        set { data.form.remarks = newValue }
    }

    /// IncrementNumberOfRunsボタンをタップ
    /// - Parameter num: 実行回数
    func tapIncrementNumberOfRunsButton(num: Int) {
        data.form.numberOfRuns += num
    }

    /// ClearNumberOfRunsボタンをタップ
    func tapClearNumberOfRunsButton() {
        data.form.numberOfRuns = 0
    }

    /// Continueボタンをタップ
    func tapContinueButton() {
        vc.transitionToConfirmScreen()
    }
}
