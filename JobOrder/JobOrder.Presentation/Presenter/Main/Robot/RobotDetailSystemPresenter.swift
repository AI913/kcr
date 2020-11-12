//
//  RobotDetailSystemPresenter.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import JobOrder_Domain

// MARK: - Interface
/// RobotDetailSystemPresenterProtocol
/// @mockable
protocol RobotDetailSystemPresenterProtocol {
    /// RobotのViewData
    var data: MainViewData.Robot { get }
    /// RobotのOS名
    var operatingSystem: String? { get }
    /// Robotのミドルウェア名
    var middleware: String? { get }
    /// Robotのシステムバージョン
    var systemVersion: String? { get }
}

// MARK: - Implementation
/// RobotDetailSystemPresenter
class RobotDetailSystemPresenter {

    /// MQTTUseCaseProtocol
    private let mqttUseCase: JobOrder_Domain.MQTTUseCaseProtocol
    /// DataManageUseCaseProtocol
    private let dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// RobotDetailSystemViewControllerProtocol
    private let vc: RobotDetailSystemViewControllerProtocol
    /// RobotのViewData
    var data: MainViewData.Robot

    /// イニシャライザ
    /// - Parameters:
    ///   - mqttUseCase: MQTTUseCaseProtocol
    ///   - dataUseCase: DataManageUseCaseProtocol
    ///   - vc: RobotDetailSystemViewControllerProtocol
    ///   - viewData: MainViewData.Robot
    required init(mqttUseCase: JobOrder_Domain.MQTTUseCaseProtocol,
                  dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: RobotDetailSystemViewControllerProtocol,
                  viewData: MainViewData.Robot) {
        self.mqttUseCase = mqttUseCase
        self.dataUseCase = dataUseCase
        self.vc = vc
        self.data = viewData
    }
}

// MARK: - Protocol Function
extension RobotDetailSystemPresenter: RobotDetailSystemPresenterProtocol {

    /// RobotのOS名
    var operatingSystem: String? {
        // TODO: UseCaseから取得
        "Ubuntu 18.04 LTS"
    }

    /// Robotのミドルウェア名
    var middleware: String? {
        // TODO: UseCaseから取得
        "ROS Melodic Morenia"
    }

    /// Robotのシステムバージョン
    var systemVersion: String? {
        // TODO: UseCaseから取得
        "0.1 Techman"
    }
}

// MARK: - Private Function
extension RobotDetailSystemPresenter {}
