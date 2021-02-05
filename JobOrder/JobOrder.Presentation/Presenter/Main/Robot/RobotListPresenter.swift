//
//  RobotListPresenter.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import UIKit
import Combine
import JobOrder_Domain

// MARK: - Interface
/// RobotListPresenterProtocol
/// @mockable
protocol RobotListPresenterProtocol {
    /// リストの行数
    var numberOfRowsInSection: Int { get }
    /// クラウドサーバー使用可否
    var useCloudServer: Bool { get }
    /// クラウドサーバーURL
    var serverUrl: String? { get }
    /// Robot ID取得
    /// - Parameter index: 配列のIndex
    func id(_ index: Int) -> String?
    /// Robotの表示名取得
    /// - Parameter index: 配列のIndex
    func displayName(_ index: Int) -> String?
    /// Robotの稼働状態名取得
    /// - Parameter index: 配列のIndex
    func stateName(_ index: Int) -> String
    /// Robotの稼働状態画像名取得
    /// - Parameter index: 配列のIndex
    func stateImageName(_ index: Int) -> String
    /// Robotの稼働状態カラー取得
    /// - Parameter index: 配列のIndex
    func stateTintColor(_ index: Int) -> UIColor
    /// Robotのタイプ名取得
    /// - Parameter index: 配列のIndex
    func typeName(_ index: Int) -> String?
    /// セルを選択
    /// - Parameter index: 配列のIndex
    func selectRow(index: Int)
    /// 検索
    /// - Parameter keyword: 検索キーワード
    func filterAndSort(keyword: String?, keywordChanged: Bool)
}

// MARK: - Implementation
/// RobotListPresenter
class RobotListPresenter {
    private var searchKeyString: String = ""
    /// SettingsUseCaseProtocol
    private let settingsUseCase: JobOrder_Domain.SettingsUseCaseProtocol
    /// DataManageUseCaseProtocol
    private let dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// MQTTUseCaseProtocol
    private let mqttUseCase: JobOrder_Domain.MQTTUseCaseProtocol
    /// RobotListViewControllerProtocol
    private let vc: RobotListViewControllerProtocol
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// リストに表示するRobotのデータ配列（フィルタ処理後）
    var displayRobots: [JobOrder_Domain.DataManageModel.Output.Robot]?
    /// リストに表示するRobotのデータ配列（フィルタ処理前）
    var originalRobots: [JobOrder_Domain.DataManageModel.Output.Robot]?

    private var sortConditions = [SortCondition(key: .thingName, order: .ASC)] {
        didSet {
            self.filterAndSort(keyword: nil, keywordChanged: false)
        }
    }

    /// イニシャライザ
    /// - Parameters:
    ///   - settingsUseCase: SettingsUseCaseProtocol
    ///   - mqttUseCase: MQTTUseCaseProtocol
    ///   - dataUseCase: DataManageUseCaseProtocol
    ///   - vc: RobotListViewControllerProtocol
    required init(settingsUseCase: JobOrder_Domain.SettingsUseCaseProtocol,
                  mqttUseCase: JobOrder_Domain.MQTTUseCaseProtocol,
                  dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: RobotListViewControllerProtocol) {
        self.settingsUseCase = settingsUseCase
        self.mqttUseCase = mqttUseCase
        self.dataUseCase = dataUseCase
        self.vc = vc
        observeRobots()
    }
}

// MARK: - Protocol Function
extension RobotListPresenter: RobotListPresenterProtocol {
    /// リストの行数
    var numberOfRowsInSection: Int {
        displayRobots?.count ?? 0
    }

    /// クラウドサーバー使用可否
    var useCloudServer: Bool {
        settingsUseCase.useCloudServer
    }

    /// クラウドサーバーURL
    var serverUrl: String? {
        settingsUseCase.serverUrl
    }

    /// Robot ID取得
    /// - Parameter index: 配列のIndex
    /// - Returns: Robot ID
    func id(_ index: Int) -> String? {
        return displayRobots?[index].id
    }

    /// Robotの表示名取得
    /// - Parameter index: 配列のIndex
    /// - Returns: 表示名
    func displayName(_ index: Int) -> String? {
        return displayRobots?[index].name
    }

    /// Robotの稼働状態名取得
    /// - Parameter index: 配列のIndex
    /// - Returns: 稼働状態名
    func stateName(_ index: Int) -> String {
        let state = MainViewData.RobotState(displayRobots?[index].state)
        return state.displayName
    }

    /// Robotの稼働状態画像名取得
    /// - Parameter index: 配列のIndex
    /// - Returns: 稼働状態画像名
    func stateImageName(_ index: Int) -> String {
        let state = MainViewData.RobotState(displayRobots?[index].state)
        return state.iconSystemName
    }

    /// Robotの稼働状態カラー取得
    /// - Parameter index: 配列のIndex
    /// - Returns: 稼働状態カラー
    func stateTintColor(_ index: Int) -> UIColor {
        let state = MainViewData.RobotState(displayRobots?[index].state)
        return state.color
    }

    /// Robotのタイプ名取得
    /// - Parameter index: 配列のIndex
    /// - Returns: タイプ名
    func typeName(_ index: Int) -> String? {
        return displayRobots?[index].type
    }

    /// セルを選択
    /// - Parameter index: 配列のIndex
    func selectRow(index: Int) {
        vc.transitionToRobotDetail()
    }

    /// 検索
    /// - Parameter keyword: 検索キーワード
    func filterAndSort(keyword: String?, keywordChanged: Bool) {

        filterAndSort(keyword: keyword, robots: displayRobots, keywordChanged: keywordChanged)
    }
}

// MARK: - Private Function
extension RobotListPresenter {

    private func observeRobots() {
        dataUseCase.observeRobotData()
            .receive(on: DispatchQueue.main)
            .sink { response in
                // Logger.debug(target: self, "\(String(describing: response))")
                self.filterAndSort(robots: response, keywordChanged: false)
            }.store(in: &cancellables)
    }

    func filterAndSort(keyword: String? = nil, robots: [JobOrder_Domain.DataManageModel.Output.Robot]?, keywordChanged: Bool) {
        guard var robots = robots else { return }

        var searchKeyWord: String? = keyword
        if keywordChanged {
            searchKeyString = searchKeyWord!
            robots = originalRobots!
        } else {
            searchKeyWord = searchKeyString
            originalRobots = robots
        }

        // TODO: - Sort by user settings.
        var display = robots.sorted {
            if let name0 = $0.name, let name1 = $1.name, name0 != name1 {
                return name0 < name1
            } else {
                return $0.id < $1.id
            }
        }

        if let searchKeyWord = searchKeyWord, !searchKeyWord.isEmpty {
            display = display.filter {
                guard let name = $0.name else { return false }
                return name.uppercased().contains(searchKeyWord.uppercased())
            }
        }
        displayRobots = display
        vc.reloadTable()
    }

    private struct SortCondition {
        var key: SortKey
        var order: SortOrder

        enum SortKey {
            case thingName
        }

        enum SortOrder {
            case ASC
            case DESC
        }
    }
}
