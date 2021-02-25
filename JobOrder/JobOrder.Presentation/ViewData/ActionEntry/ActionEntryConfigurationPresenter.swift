//
//  ActionEntryConfigurationPresenter.swift
//  JobOrder.Presentation
//
//  Created by Frontarc on 2021/02/25.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import UIKit
import Foundation
import JobOrder_Domain

// MARK: - Interface
/// ActionEntryConfigurationPresenterProtocol
/// @mockable
protocol ActionEntryConfigurationPresenterProtocol {
    /// JobのViewData
    var data: MainViewData.Job { get }
    /// ActionLibraryの表示名
    var displayName: String? { get }
}

// MARK: - Implementation
/// ActionEntryConfigurationPresenter
class ActionEntryConfigurationPresenter {

    /// DataManageUseCaseProtocol
    private let useCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// ActionEntryConfigurationViewControllerProtocol
    private let vc: ActionEntryConfigurationViewControllerProtocol
    /// JobのViewData
    var data: MainViewData.Job

    /// イニシャライザ
    /// - Parameters:
    ///   - useCase: DataManageUseCaseProtocol
    ///   - vc: ActionEntryConfigurationViewControllerProtocol
    ///   - viewData: MainViewData.Job
    required init(useCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: ActionEntryConfigurationViewControllerProtocol,
                  viewData: MainViewData.Job) {
        self.useCase = useCase
        self.vc = vc
        self.data = viewData
    }
}

// MARK: - Protocol Function
extension ActionEntryConfigurationPresenter: ActionEntryConfigurationPresenterProtocol {

    /// Jobの表示名
    var displayName: String? {
        useCase.jobs?.first(where: { $0.id == data.id })?.name
    }
}
