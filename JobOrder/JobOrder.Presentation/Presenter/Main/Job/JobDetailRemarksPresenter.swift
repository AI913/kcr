//
//  JobDetailRemarksPresenter.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/11/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import JobOrder_Domain

// MARK: - Interface
/// JobDetailRemarksPresenterProtocol
/// @mockable
protocol JobDetailRemarksPresenterProtocol {
    /// ViewData
    var data: MainViewData.Job { get }
    /// Jobの備考
    var remarks: String? { get }
}

// MARK: - Implementation
/// JobDetailRemarksPresenter
class JobDetailRemarksPresenter {
    /// DataManageUseCaseProtocol
    private let dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// JobDetailWorkViewControllerProtocol
    private let vc: JobDetailRemarksViewControllerProtocol
    /// ViewData
    var data: MainViewData.Job

    required init(dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: JobDetailRemarksViewControllerProtocol,
                  viewData: MainViewData.Job) {
        self.dataUseCase = dataUseCase
        self.vc = vc
        self.data = viewData
    }
}

// MARK: - Protocol Function
extension JobDetailRemarksPresenter: JobDetailRemarksPresenterProtocol {

    /// Robotの備考
    var remarks: String? {
        dataUseCase.jobs?.first(where: { $0.id == data.id })?.remarks
    }

}
