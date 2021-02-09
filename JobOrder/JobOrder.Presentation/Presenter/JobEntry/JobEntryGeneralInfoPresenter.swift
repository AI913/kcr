//
//  JobEntryGeneralInformationFormPresenter.swift
//  JobOrder.Presentation
//
//  Created by frontarc on 2021/01/19.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Domain
import JobOrder_Utility

// MARK: - Interface
/// JobEntryGeneralInfoPresenterProtocol
/// @mockable
protocol JobEntryGeneralInfoPresenterProtocol {
    /// リストの行数
    var numberOfItemsInSection: Int { get }
    /// Continueボタンの有効無効
    var isEnabledContinueButton: Bool { get }
    /// Robotの表示名取得
    /// - Parameter index: 配列のIndex
    func displayName(_ index: Int) -> String?
    /// Robotのタイプ取得
    /// - Parameter index: 配列のIndex
    func type(_ index: Int) -> String?
    /// セルの選択可否
    /// - Parameter indexPath: インデックスパス
    func isSelected(indexPath: IndexPath) -> Bool
    /// セルの選択
    /// - Parameter indexPath: インデックスパス
    func selectItem(indexPath: IndexPath)
    /// Continueボタンをタップ
    func tapContinueButton()
}

// MARK: - Implementation
/// JobEntryRobotGeneralInfoPresenter
class JobEntryGeneralInfoPresenter {
    var data: JobEntryViewData = JobEntryViewData()
    private var searchKeyString: String = ""
    /// DataManageUseCaseProtocol
    private let useCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// JobEntryGeneralInfoViewControllerProtocol
    private let vc: JobEntryGeneralInfoViewControllerProtocol
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// リストに表示するRobotのデータ配列
    private var displayRobots: [JobOrder_Domain.DataManageModel.Output.Robot]?
    /// 取得したRobotのデータ配列
    private var cachedRobots: [String: JobOrder_Domain.DataManageModel.Output.Robot]?

    /// イニシャライザ
    /// - Parameters:
    ///   - useCase: DataManageUseCaseProtocol
    ///   - vc: JobEntryGeneralInformationFormViewControllerProtocol
    ///   - viewData: JobEntryViewData
    required init(useCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: JobEntryGeneralInfoViewControllerProtocol) {
        self.useCase = useCase
        self.vc = vc
        observeRobots()
        cacheRobots(useCase.robots)
    }
}

// MARK: - Protocol Function
extension JobEntryGeneralInfoPresenter: JobEntryGeneralInfoPresenterProtocol {

    /// リストの行数
    var numberOfItemsInSection: Int {
        displayRobots?.count ?? 0
    }

    /// Continueボタンの有効無効
    var isEnabledContinueButton: Bool {
        data.robotIds?.count ?? 0 > 0
    }

    /// Robotの表示名取得
    /// - Parameter index: 配列のIndex
    /// - Returns: Robotの表示名
    func displayName(_ index: Int) -> String? {
        return displayRobots?[index].name
    }

    /// Robotのタイプ取得
    /// - Parameter index: 配列のIndex
    /// - Returns: Robotのタイプ名
    func type(_ index: Int) -> String? {
        return displayRobots?[index].type
    }

    /// セルの選択可否
    /// - Parameter indexPath: インデックスパス
    /// - Returns: 選択中かどうか
    func isSelected(indexPath: IndexPath) -> Bool {
        guard let id = displayRobots?[indexPath.row].id else { return false }
        return data.robotIds?.contains(id) ?? false
    }

    /// セルの選択
    /// - Parameter indexPath: インデックスパス
    func selectItem(indexPath: IndexPath) {
        guard let id = displayRobots?[indexPath.row].id else { return }
        if let index = data.robotIds?.firstIndex(of: id) {
            data.robotIds?.remove(at: index)
        } else if data.robotIds == nil {
            data.robotIds = [id]
        } else {
            data.robotIds?.append(id)
        }
    }

    /// Continueボタンをタップ
    func tapContinueButton() {
        vc.transitionToActionScreen()
    }
}

// MARK: - Private Function
extension JobEntryGeneralInfoPresenter {

    func observeRobots() {
        useCase.observeRobotData()
            .receive(on: DispatchQueue.main)
            .sink { response in
                // Logger.debug(target: self, "\(String(describing: response))")
                self.cacheRobots(response)
            }.store(in: &cancellables)
    }

    func cacheRobots(_ robots: [DataManageModel.Output.Robot]?) {
        guard let robots = robots else { return }
        cachedRobots = robots.reduce(into: [String: DataManageModel.Output.Robot]()) { $0[$1.id] = $1 }
        filterAndSort()
    }

    func filterAndSort() {
        guard let robots = cachedRobots else { return }

        var display = robots.values.sorted {
            $0.name ?? "N/A" < $1.name ?? "N/A"
        }

        if let jobs = useCase.jobs, !jobs.isEmpty {
            // TODO: 将来的にRobotに適合しないJobは除外するなどのケースが考えられる
            //            display = display.filter { $0.available(jobs) }
            display = display.filter { _ in true }
        }
        displayRobots = display
        vc.reloadCollection()
    }

}
