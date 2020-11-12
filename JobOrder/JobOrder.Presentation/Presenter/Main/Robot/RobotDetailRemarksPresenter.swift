//
//  RobotDetailRemarksPresenter.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import JobOrder_Domain

// MARK: - Interface
/// RobotDetailRemarksPresenterProtocol
/// @mockable
protocol RobotDetailRemarksPresenterProtocol {
    /// RobotのViewData
    var data: MainViewData.Robot { get }
    /// Robotの備考
    var remarks: String? { get }
}

// MARK: - Implementation
/// RobotDetailRemarksPresenter
class RobotDetailRemarksPresenter {

    /// DataManageUseCaseProtocol
    private let useCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// RobotDetailRemarksViewControllerProtocol
    private let vc: RobotDetailRemarksViewControllerProtocol
    /// RobotのViewData
    var data: MainViewData.Robot

    /// イニシャライザ
    /// - Parameters:
    ///   - useCase: DataManageUseCaseProtocol
    ///   - vc: RobotDetailRemarksViewControllerProtocol
    ///   - viewData: MainViewData.Robot
    required init(useCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: RobotDetailRemarksViewControllerProtocol,
                  viewData: MainViewData.Robot) {
        self.useCase = useCase
        self.vc = vc
        self.data = viewData
    }
}

// MARK: - Protocol Function
extension RobotDetailRemarksPresenter: RobotDetailRemarksPresenterProtocol {

    /// Robotの備考
    var remarks: String? {
        useCase.robots?.first(where: { $0.id == data.id })?.remarks
    }
}
