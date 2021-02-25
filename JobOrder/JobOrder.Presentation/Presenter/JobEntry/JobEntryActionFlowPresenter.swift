//
//  JobEntryActionFlowPresenter.swift
//  JobOrder.Presentation
//
//  Created by Frontarc on 2021/02/25.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Domain
import JobOrder_Utility

// MARK: - Interface
/// JobListPresenterProtocol
/// @mockable
protocol JobEntryActionFlowPresenterProtocol {
    /// セルを選択
    func infoButtonTapped(index: Int)
}

// MARK: - Implementation
/// JobListPresenter
class JobEntryActionFlowPresenter {

    /// DataManageUseCaseProtocol
    private let useCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// JobListViewControllerProtocol
    private let vc: JobEntryActionFlowViewControllerProtocol

    /// イニシャライザ
    /// - Parameters:
    ///   - useCase: DataManageUseCaseProtocol
    ///   - vc: JobEntryActionFlowViewControllerProtocol
    required init(useCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: JobEntryActionFlowViewControllerProtocol) {
        self.useCase = useCase
        self.vc = vc
    }
}

// MARK: - Protocol Function
extension JobEntryActionFlowPresenter: JobEntryActionFlowPresenterProtocol {

    /// セルを選択
    /// - Parameter index: 配列のIndex
    func infoButtonTapped(index: Int) {
        vc.transitionToActionEntryConfiguration()
    }
}
