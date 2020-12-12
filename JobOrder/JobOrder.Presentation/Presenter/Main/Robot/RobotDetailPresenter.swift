//
//  RobotDetailPresenter.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import UIKit
import Combine
import JobOrder_Domain
import JobOrder_Utility

// MARK: - Interface
/// RobotDetailPresenterProtocol
/// @mockable
protocol RobotDetailPresenterProtocol {
    /// RobotのViewData
    var data: MainViewData.Robot { get }
    /// Robotの表示名
    var displayName: String? { get }
    /// Robotの概要
    var overview: String? { get }
    /// Robotの稼働状態名
    var stateName: String? { get }
    /// Robotの稼働状態画像名
    var stateImageName: String? { get }
    /// Robotの稼働状態カラー
    var stateTintColor: UIColor? { get }
    /// Robotのタイプ名
    var typeName: String? { get }
    /// Robotのシリアル番号
    var serialName: String? { get }
    /// Robotの備考
    var remarks: String? { get }
    /// Robotの画像
    /// - Parameter completion: クロージャ
    func image(_ completion: @escaping (Data?) -> Void)
    /// Moreボタンをタップ
    /// - Parameter button: ボタン
    func tapMoreBarButton(_ button: UIBarButtonItem)
    /// OrderEntryボタンをタップ
    func tapOrderEntryButton()
}

// MARK: - Implementation
/// RobotDetailPresenter
class RobotDetailPresenter {

    /// DataManageUseCaseProtocol
    private let useCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// RobotDetailViewControllerProtocol
    private let vc: RobotDetailViewControllerProtocol
    /// RobotのViewData
    var data: MainViewData.Robot
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []

    /// イニシャライザ
    /// - Parameters:
    ///   - useCase: DataManageUseCaseProtocol
    ///   - vc: RobotDetailViewControllerProtocol
    ///   - viewData: MainViewData.Robot
    required init(useCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: RobotDetailViewControllerProtocol,
                  viewData: MainViewData.Robot) {
        self.useCase = useCase
        self.vc = vc
        self.data = viewData
    }
}

// MARK: - Protocol Function
extension RobotDetailPresenter: RobotDetailPresenterProtocol {

    /// Robotの表示名
    var displayName: String? {
        let robot = useCase.robots?.first(where: { $0.id == data.id })
        return robot?.name
    }

    /// Robotの概要
    var overview: String? {
        let robot = useCase.robots?.first(where: { $0.id == data.id })
        return robot?.overview
    }

    /// Robotの稼働状態名
    var stateName: String? {
        let robot = useCase.robots?.first(where: { $0.id == data.id })
        let state = MainViewData.RobotState(robot?.state)
        return state.displayName
    }

    /// Robotの稼働状態画像名
    var stateImageName: String? {
        let robot = useCase.robots?.first(where: { $0.id == data.id })
        let state = MainViewData.RobotState(robot?.state)
        return state.iconSystemName
    }

    /// Robotの稼働状態カラー
    var stateTintColor: UIColor? {
        let robot = useCase.robots?.first(where: { $0.id == data.id })
        let state = MainViewData.RobotState(robot?.state)
        return state.color
    }

    /// Robotのタイプ名
    var typeName: String? {
        useCase.robots?.first(where: { $0.id == data.id })?.type
    }

    /// Robotのシリアル番号
    var serialName: String? {
        useCase.robots?.first(where: { $0.id == data.id })?.serial
    }

    /// Robotの備考
    var remarks: String? {
        useCase.robots?.first(where: { $0.id == data.id })?.remarks
    }

    /// Robotの画像
    /// - Parameter completion: クロージャ
    func image(_ completion: @escaping (Data?) -> Void) {
        guard let id = data.id else { return }

        useCase.robotImage(id: id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                Logger.debug(target: self, "\(completion)")
                switch completion {
                case .finished: break
                case .failure(let error):
                    // TODO: エラーケース
                    Logger.error(target: self, "\(error.localizedDescription)")
                }
            }, receiveValue: { response in
                completion(response.data)
            }).store(in: &cancellables)
    }
    /// Moreボタンをタップ
    /// - Parameter button: ボタン
    func tapMoreBarButton(_ button: UIBarButtonItem) {
        guard let _ = data.id else { return }
        vc.showActionSheet(button)
    }

    /// OrderEntryボタンをタップ
    func tapOrderEntryButton() {
        vc.launchOrderEntry()
    }
}
