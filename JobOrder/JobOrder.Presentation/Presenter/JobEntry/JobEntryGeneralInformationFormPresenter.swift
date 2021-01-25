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

protocol JobEntryGeneralInformationFormPresenterProtocol {
    /// OrderEntryのViewData
    var data: OrderEntryViewData { get }
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

class JobEntryGeneralInformationFormPresenter {
    /// DataManageUseCaseProtocol
    private let useCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// OrderEntryRobotSelectionViewControllerProtocol
    private let vc: JobEntryGeneralInformationFormViewControllerProtocol
    /// OrderEntryのViewData
    var data: OrderEntryViewData
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// リストに表示するRobotのデータ配列
    private var displayRobots: [JobOrder_Domain.DataManageModel.Output.Robot]?
    /// 取得したRobotのデータ配列
    private var cachedRobots: [String: JobOrder_Domain.DataManageModel.Output.Robot]?

    /// イニシャライザ
    /// - Parameters:
    ///   - useCase: DataManageUseCaseProtocol
    ///   - vc: OrderEntryRobotSelectionViewControllerProtocol
    ///   - viewData: OrderEntryViewData
    required init(useCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: JobEntryGeneralInformationFormViewControllerProtocol,
                  viewData: OrderEntryViewData) {
        self.useCase = useCase
        self.vc = vc
        self.data = viewData
        observeRobots()
        cacheRobots(useCase.robots)
    }
}

// MARK: - Protocol Function
extension JobEntryGeneralInformationFormPresenter: JobEntryGeneralInformationFormPresenterProtocol {

    /// リストの行数
    var numberOfItemsInSection: Int {
        displayRobots?.count ?? 0
    }

    /// Continueボタンの有効無効
    var isEnabledContinueButton: Bool {
        data.form.robotIds?.count ?? 0 > 0
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
        return data.form.robotIds?.contains(id) ?? false
    }

    /// セルの選択
    /// - Parameter indexPath: インデックスパス
    func selectItem(indexPath: IndexPath) {
        guard let id = displayRobots?[indexPath.row].id else { return }
        if let index = data.form.robotIds?.firstIndex(of: id) {
            data.form.robotIds?.remove(at: index)
        } else if data.form.robotIds == nil {
            data.form.robotIds = [id]
        } else {
            data.form.robotIds?.append(id)
        }
    }

    /// Continueボタンをタップ
    func tapContinueButton() {
        vc.transitionToConfigurationFormScreen()
    }
}

// MARK: - Private Function
extension JobEntryGeneralInformationFormPresenter {

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
