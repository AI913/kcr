//
//  JobDetailPresenter.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import JobOrder_Domain

// MARK: - Interface
/// JobDetailPresenterProtocol
/// @mockable
protocol JobDetailPresenterProtocol {
    /// JobのViewData
    var data: MainViewData.Job { get }
    /// Jobの表示名
    var displayName: String? { get }
    /// Jobの概要
    var overview: String? { get }
    /// Jobの備考
    var remarks: String? { get }
    /// Orderボタンをタップ
    func tapOrderButton()
}

// MARK: - Implementation
/// JobDetailPresenter
class JobDetailPresenter {

    /// DataManageUseCaseProtocol
    private let useCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// JobDetailViewControllerProtocol
    private let vc: JobDetailViewControllerProtocol
    /// JobのViewData
    var data: MainViewData.Job

    /// イニシャライザ
    /// - Parameters:
    ///   - useCase: DataManageUseCaseProtocol
    ///   - vc: JobDetailViewControllerProtocol
    ///   - viewData: MainViewData.Job
    required init(useCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: JobDetailViewControllerProtocol,
                  viewData: MainViewData.Job) {
        self.useCase = useCase
        self.vc = vc
        self.data = viewData
    }
}

// MARK: - Protocol Function
extension JobDetailPresenter: JobDetailPresenterProtocol {

    /// Jobの表示名
    var displayName: String? {
        useCase.jobs?.first(where: { $0.id == data.id })?.name
    }

    /// Jobの概要
    var overview: String? {
        useCase.jobs?.first(where: { $0.id == data.id })?.overview
    }

    /// Jobの備考
    var remarks: String? {
        useCase.jobs?.first(where: { $0.id == data.id })?.remarks
    }

    /// Orderボタンをタップ
    func tapOrderButton() {
        vc.launchOrderEntry()
    }
}
