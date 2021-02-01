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
/// JobEntryGeneralInformationFormPresenterProtocol
/// @mockable
protocol JobEntryGeneralInformationFormPresenterProtocol {
//    /// JobEntryのViewData
//    var data: JobEntryViewData { get }
    /// リストの行数
    var numberOfItemsInSection: Int { get }
//    /// Continueボタンの有効無効
//    var isEnabledContinueButton: Bool { get }
    /// Robotの表示名取得
    /// - Parameter index: 配列のIndex
    func displayName(_ index: Int) -> String?
    /// Robotのタイプ取得
    /// - Parameter index: 配列のIndex
    func type(_ index: Int) -> String?
    /// セルの選択可否
    /// - Parameter indexPath: インデックスパス
//    func isSelected(indexPath: IndexPath) -> Bool
//    /// セルの選択
//    /// - Parameter indexPath: インデックスパス
//    func selectItem(indexPath: IndexPath)
    /// Continueボタンをタップ
    func tapContinueButton()
}

// MARK: - Implementation
/// JobEntryRobotGeneralInformationFormPresenter
class JobEntryGeneralInformationFormPresenter {
    private var searchKeyString: String = ""
    /// DataManageUseCaseProtocol
    private let useCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// DataManageUseCaseProtocol
    private let dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// OrderEntryRobotSelectionViewControllerProtocol
    private let vc: JobEntryGeneralInformationFormViewControllerProtocol
//    /// OrderEntryのViewData
//    var data: JobEntryViewData
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// リストに表示するRobotのデータ配列
    private var displayRobots: [JobOrder_Domain.DataManageModel.Output.Robot]?
    /// リストに表示するRobotのデータ配列（フィルタ処理前）
    var originalRobots: [JobOrder_Domain.DataManageModel.Output.Robot]?
    /// 取得したRobotのデータ配列
    private var cachedRobots: [String: JobOrder_Domain.DataManageModel.Output.Robot]?

    /// イニシャライザ
    /// - Parameters:
    ///   - useCase: DataManageUseCaseProtocol
    ///   - vc: JobEntryGeneralInformationFormViewControllerProtocol
    ///   - viewData: OrderEntryViewData
    required init(useCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: JobEntryGeneralInformationFormViewControllerProtocol) {
        self.useCase = useCase
        self.dataUseCase = dataUseCase
        self.vc = vc
//        self.data = viewData
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

//    /// Continueボタンの有効無効
//    var isEnabledContinueButton: Bool {
//        data.form.robotIds?.count ?? 0 > 0
//    }

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
//    func isSelected(indexPath: IndexPath) -> Bool {
//        guard let id = displayRobots?[indexPath.row].id else { return false }
//        return data.form.robotIds?.contains(id) ?? false
//    }

    /// セルの選択
    /// - Parameter indexPath: インデックスパス
//    func selectItem(indexPath: IndexPath) {
//        guard let id = displayRobots?[indexPath.row].id else { return }
//        if let index = data.form.robotIds?.firstIndex(of: id) {
//            data.form.robotIds?.remove(at: index)
//        } else if data.form.robotIds == nil {
//            data.form.robotIds = [id]
//        } else {
//            data.form.robotIds?.append(id)
//        }
//    }

    /// Continueボタンをタップ
    func tapContinueButton() {
        vc.transitionToActionScreen()
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
        print(cachedRobots)
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
//
//    private func observeRobots() {
//        useCase.observeRobotData()
//            .receive(on: DispatchQueue.main)
//            .sink { response in
//                // Logger.debug(target: self, "\(String(describing: response))")
//                self.filterAndSort(robots: response, keywordChanged: false)
//            }.store(in: &cancellables)
//    }
//
//
//    func filterAndSort(keyword: String? = nil, robots: [JobOrder_Domain.DataManageModel.Output.Robot]?, keywordChanged: Bool) {
//        guard var robots = robots else { return }
//
//        var searchKeyWord: String? = keyword
//        if keywordChanged {
//            searchKeyString = searchKeyWord!
//            robots = originalRobots!
//        } else {
//            searchKeyWord = searchKeyString
//            originalRobots = robots
//        }
//
//        // TODO: - Sort by user settings.
//        var display = robots.sorted {
//            if let name0 = $0.name, let name1 = $1.name, name0 != name1 {
//                return name0 < name1
//            } else {
//                return $0.id < $1.id
//            }
//        }
//
//        if let searchKeyWord = searchKeyWord, !searchKeyWord.isEmpty {
//            display = display.filter {
//                guard let name = $0.name else { return false }
//                return name.uppercased().contains(searchKeyWord.uppercased())
//            }
//        }
//        displayRobots = display
//        vc.reloadCollection()
//    }
}