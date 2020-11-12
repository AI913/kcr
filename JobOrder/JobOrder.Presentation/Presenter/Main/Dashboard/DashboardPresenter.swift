//
//  DashboardPresenter.swift
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
/// DashboardPresenterProtocol
/// @mockable
protocol DashboardPresenterProtocol {
    /// ExecutionStatsを取得
    func fetchExecutionStats()
}

// MARK: - Implementation
/// DashboardPresenter
class DashboardPresenter {

    /// MQTTUseCaseProtocol
    private let mqttUseCase: JobOrder_Domain.MQTTUseCaseProtocol
    /// DataManageUseCaseProtocol
    private let dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// DashboardViewControllerProtocol
    private let vc: DashboardViewControllerProtocol
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// Robotの稼働状態の配列
    private var cachedRobotState: [MainViewData.RobotState: Int]?

    /// イニシャライザ
    /// - Parameters:
    ///   - mqttUseCase: MQTTUseCaseProtocol
    ///   - dataUseCase: DataManageUseCaseProtocol
    ///   - vc: RobotDetailWorkViewControllerProtocol
    required init(mqttUseCase: JobOrder_Domain.MQTTUseCaseProtocol,
                  dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: DashboardViewControllerProtocol) {
        self.mqttUseCase = mqttUseCase
        self.dataUseCase = dataUseCase
        self.vc = vc
        registerStateChanges()
        observeRobots()
    }
}

// MARK: - Protocol Function
extension DashboardPresenter: DashboardPresenterProtocol {

    /// ExecutionStatsを取得
    func fetchExecutionStats() {

        // ****** API GET satatistics/execution ******

        //        StatisticsAPI.getExecution(Date(), TimeInterval(60 * 60 * 24 * 6)) { (param, result, error) -> Void in
        //            if let error = error {
        //                DispatchQueue.main.async {
        //                    self.presentSingleAlert(error)
        //                }
        //                return
        //            }
        //
        //            guard let result = result else {
        //                // TODO show message
        //                return
        //            }
        //
        //            var executionCounts: [Date: StatisticsAPI.ExecutionData] = [:]
        //            var date = param.start
        //            let formatter = DateFormatter()
        //            formatter.dateFormat = "yyyyMMdd"
        //            repeat {
        //                let next = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        //                let data = result.data.filter {
        //                    $0.date == formatter.string(from: date)
        //                }
        //                if !data.count.isEmpty {
        //                    executionCounts[date] = data[0]
        //                } else {
        //                    executionCounts[date] = StatisticsAPI.ExecutionData(date: formatter.string(from: date), succeeded: 0, failed: 0, rejected: 0, canceled: 0, removed: 0)
        //                }
        //                date = next
        //            } while (date <= param.end)
        //
        //            DispatchQueue.main.async {
        //                self.executionCounts = executionCounts
        //            }
        //        }
    }

}

// MARK: - Private Function
extension DashboardPresenter {

    private func registerStateChanges() {

        mqttUseCase.registerConnectionStatusChange()
            .receive(on: DispatchQueue.main)
            .map { value -> MainViewData.ConnectionInfo.Status in
                return MainViewData.ConnectionInfo.Status(value)
            }.sink { response in
                Logger.debug(target: self, "connectionState: \(response)")
                if response == .connected {
                    self.fetchExecutionStats()
                } else {
                    self.vc.updateExecutionChart(nil)
                }
            }.store(in: &cancellables)
    }

    private func observeRobots() {
        dataUseCase.observeRobotData()
            .receive(on: DispatchQueue.main)
            .map { value -> [MainViewData.RobotState]? in
                return value?.compactMap {
                    guard let state = $0.state else { return nil }
                    return MainViewData.RobotState(state)
                }
            }.sink { response in
                // Logger.debug(target: self, "\(String(describing: response))")
                if self.cache(response) {
                    self.vc.updateRobotStatusChart(self.cachedRobotState)
                }
            }.store(in: &cancellables)
    }

    /// Robotの稼働状態をキャッシュする
    /// - Parameter robotState: Robotの稼働状態
    /// - Returns: 更新の有無
    private func cache(_ robotState: [MainViewData.RobotState]?) -> Bool {
        var state: [MainViewData.RobotState: Int] = [:]

        // 重複要素はまとめる
        robotState?.forEach {
            state[$0, default: 0] += 1
        }

        // 変化がある場合のみキャッシュする
        if cachedRobotState != state {
            cachedRobotState = state
        }

        // 全てのRobotの稼働状態が取得できたら更新する
        return dataUseCase.robots?.count == robotState?.count
    }
}
