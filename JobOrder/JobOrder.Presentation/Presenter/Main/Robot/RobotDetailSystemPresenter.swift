//
//  RobotDetailSystemPresenter.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Domain
import JobOrder_Utility

// MARK: - Interface
/// RobotDetailSystemPresenterProtocol
/// @mockable
protocol RobotDetailSystemPresenterProtocol {
    /// RobotのViewData
    var data: MainViewData.Robot { get }
    /// View表示開始
    func viewWillAppear()
    /// セクション数取得
    /// - Parameter in: 設定情報種別
    func numberOfSections(in: RobotDetailSystemPresenter.Dataset) -> Int
    /// アイテム数取得
    /// - Parameters:
    ///   - in: 設定情報種別
    ///   - section: セクションIndex
    func numberOfRowsInSection(in: RobotDetailSystemPresenter.Dataset, section: Int) -> Int
    /// タイトル取得
    /// - Parameters:
    ///   - in: 設定情報種別
    ///   - section: セクションIndex
    func title(in: RobotDetailSystemPresenter.Dataset, section: Int) -> (String, String?)
    /// 詳細取得
    /// - Parameters:
    ///   - in: 設定情報種別
    ///   - indexPath: アイテムIndex
    func detail(in: RobotDetailSystemPresenter.Dataset, indexPath: IndexPath) -> (String, String)
    /// アコーディオン開閉
    /// - Parameters:
    ///   - in: 設定情報種別
    ///   - section: セクションIndex
    func tapHeader(in: RobotDetailSystemPresenter.Dataset, section: Int)
    /// アコーディオン記号取得
    /// - Parameter in: 開閉状態
    func accessory(in: Bool) -> String
}

// MARK: - Implementation
/// RobotDetailSystemPresenter
class RobotDetailSystemPresenter {
    enum Dataset {
        case software
        case hardware
    }

    /// MQTTUseCaseProtocol
    private let mqttUseCase: JobOrder_Domain.MQTTUseCaseProtocol
    /// DataManageUseCaseProtocol
    private let dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// RobotDetailSystemViewControllerProtocol
    private let vc: RobotDetailSystemViewControllerProtocol
    /// RobotのViewData
    var data: MainViewData.Robot
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []

    var detailSystem: DataManageModel.Output.System?

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

    /// View表示開始
    func viewWillAppear() {
        guard let id = data.id else { return }
        getRobotSystem(id: id)
    }

    /// セクション数取得
    /// - Parameter in: 設定情報種別
    /// - Returns: セクション数
    func numberOfSections(in config: RobotDetailSystemPresenter.Dataset) -> Int {
        guard let detailSystem = detailSystem else { return 0 }

        switch config {
        case .software:
            return 3	// detailSystem?.softwareConfiguration.[system,distribution,installs]
        case .hardware:
            return detailSystem.hardwareConfigurations.count
        }
    }

    /// アイテム数取得
    /// - Parameters:
    ///   - in: 設定情報種別
    ///   - section: セクションIndex
    /// - Returns: アイテム数
    func numberOfRowsInSection(in config: RobotDetailSystemPresenter.Dataset, section: Int) -> Int {
        guard let detailSystem = detailSystem else { return 0 }

        switch config {
        case .software:
            if section == 2 {	// detailSystem?.softwareConfiguration.installs
                return detailSystem.softwareConfiguration.installs.count
            }
            return 0
        case .hardware:
            return 2	// detailSystem?.hardwareConfigurations.[maker,serialNo]
        }
    }

    /// タイトル取得
    /// - Parameters:
    ///   - in: 設定情報種別
    ///   - section: セクションIndex
    /// - Returns: (タイトル, 内容)
    func title(in config: RobotDetailSystemPresenter.Dataset, section: Int) -> (String, String?) {
        switch config {
        case .software:
            switch section {
            case 0:
                return (data.detailSystem.softwareSystemTitle, detailSystem?.softwareConfiguration.system)
            case 1:
                return (data.detailSystem.softwareDistributionTitle, detailSystem?.softwareConfiguration.distribution)
            case 2:
                return (data.detailSystem.softwareInstalledsoftwareTitle, nil)
            default:
                return ("", nil)
            }
        case .hardware:
            if let hardware = detailSystem?.hardwareConfigurations[section] {
                return (hardware.type, hardware.model)
            }
            return ("", nil)
        }
    }

    /// 詳細取得
    /// - Parameters:
    ///   - in: 設定情報種別
    ///   - indexPath: アイテムIndex
    /// - Returns: (詳細, 内容)
    func detail(in config: RobotDetailSystemPresenter.Dataset, indexPath: IndexPath) -> (String, String) {
        switch config {
        case .software:
            if indexPath.section == 2 {
                if let software = detailSystem?.softwareConfiguration.installs[indexPath.row] {
                    return (software.name, software.version)
                }
            }
            return ("", "")
        case .hardware:
            if let hardware = detailSystem?.hardwareConfigurations[indexPath.section] {
                switch indexPath.row {
                case 0:
                    return (data.detailSystem.hardwareMakerTitle, hardware.maker)
                case 1:
                    return (data.detailSystem.hardwareSerialNoTitle, hardware.serialNo)
                default:
                    return ("", "")
                }
            }
            return ("", "")
        }
    }

    /// アコーディオン開閉
    /// - Parameters:
    ///   - in: 設定情報種別
    ///   - section: セクションIndex
    func tapHeader(in config: RobotDetailSystemPresenter.Dataset, section: Int) {
        vc.toggleExtensionTable(in: config, section: section)
    }

    /// アコーディオン記号取得
    /// - Parameter in: 開閉状態
    /// - Returns: アコーディオン記号
    func accessory(in state: Bool) -> String {
        return state ? data.detailSystem.accessoryOpened : data.detailSystem.accessoryClosed
    }
}

// MARK: - Private Function
extension RobotDetailSystemPresenter {

    private func getRobotSystem(id: String) {
        dataUseCase.robotSystem(id: id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(String(describing: response))")
                if let detailSystem = self.detailSystem, response == detailSystem { return }
                // 初回取得またはデータに更新があった場合
                self.detailSystem = response
                self.vc.reloadTable()
            }).store(in: &cancellables)
    }

}
