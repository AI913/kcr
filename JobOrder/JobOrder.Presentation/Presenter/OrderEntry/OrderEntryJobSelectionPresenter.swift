//
//  OrderEntryJobSelectionPresenter.swift
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
/// OrderEntryJobSelectionPresenterProtocol
/// @mockable
protocol OrderEntryJobSelectionPresenterProtocol {
    /// OrderEntryのViewData
    var data: OrderEntryViewData { get }
    /// Viewのロード
    func viewDidLoad()
    /// リストの行数
    var numberOfItemsInSection: Int { get }
    /// Continueボタンの有効無効
    var isEnabledContinueButton: Bool { get }
    /// Jobの表示名取得
    /// - Parameter index: 配列のIndex
    func displayName(_ index: Int) -> String?
    /// Jobのテキスト取得
    /// - Parameter index: 配列のIndex
    func requirementText(_ index: Int) -> String?
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
class OrderEntryJobSelectionPresenter {

    /// DataManageUseCaseProtocol
    private let useCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// OrderEntryJobSelectionViewControllerProtocol
    private let vc: OrderEntryJobSelectionViewControllerProtocol
    /// OrderEntryのViewData
    var data: OrderEntryViewData
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// リストに表示するJobのデータ配列
    private var displayJobs: [JobOrder_Domain.DataManageModel.Output.Job]?
    /// 取得したJobのデータ配列
    private var cachedJobs: [String: JobOrder_Domain.DataManageModel.Output.Job]?

    /// イニシャライザ
    /// - Parameters:
    ///   - useCase: DataManageUseCaseProtocol
    ///   - vc: OrderEntryJobSelectionViewControllerProtocol
    ///   - viewData: OrderEntryViewData
    required init(useCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: OrderEntryJobSelectionViewControllerProtocol,
                  viewData: OrderEntryViewData) {
        self.useCase = useCase
        self.vc = vc
        self.data = viewData
        observeJobs()
        cacheJobs(useCase.jobs)
    }
}

// MARK: - Protocol Function
extension OrderEntryJobSelectionPresenter: OrderEntryJobSelectionPresenterProtocol {

    /// リストの行数
    var numberOfItemsInSection: Int {
        displayJobs?.count ?? 0
    }

    /// Continueボタンの有効無効
    var isEnabledContinueButton: Bool {
        data.form.jobId != nil
    }

    /// Viewのロード
    func viewDidLoad() {
        // 既にJobが指定されている場合は画面をスキップ
        if data.form.jobId != nil {
            vc.transitionToRobotSelectionScreen()
        }
    }

    /// Jobの表示名取得
    /// - Parameter index: 配列のIndex
    /// - Returns: Jobの表示名
    func displayName(_ index: Int) -> String? {
        return displayJobs?[index].name
    }

    /// Jobのテキスト取得
    /// - Parameter index: 配列のIndex
    /// - Returns: Jobのテキスト名
    func requirementText(_ index: Int) -> String? {
        return displayJobs?[index].overview
    }

    /// セルの選択可否
    /// - Parameter indexPath: インデックスパス
    /// - Returns: 選択中かどうか
    func isSelected(indexPath: IndexPath) -> Bool {
        let id = displayJobs?[indexPath.row].id
        return id == data.form.jobId
    }

    /// セルの選択
    /// - Parameter indexPath: インデックスパス
    func selectItem(indexPath: IndexPath) {
        data.form.jobId = displayJobs?[indexPath.row].id
    }

    /// Continueボタンをタップ
    func tapContinueButton() {
        vc.transitionToRobotSelectionScreen()
    }
}

// MARK: - Private Function
extension OrderEntryJobSelectionPresenter {

    func observeJobs() {
        useCase.observeJobData()
            .receive(on: DispatchQueue.main)
            .sink { response in
                // Logger.debug(target: self, "\(String(describing: response))")
                self.cacheJobs(response)
            }.store(in: &cancellables)
    }

    func cacheJobs(_ jobs: [DataManageModel.Output.Job]?) {
        guard let jobs = jobs else { return }
        cachedJobs = jobs.reduce(into: [String: DataManageModel.Output.Job]()) { $0[$1.id] = $1 }
        filterAndSort()
    }

    func filterAndSort() {
        guard let jobs = cachedJobs else { return }

        var display = jobs.values.sorted {
            $0.name < $1.name
        }

        if let robots = useCase.robots, !robots.isEmpty {
            // TODO: 将来的にRobotに適合しないJobは除外するなどのケースが考えられる
            //            display = display.filter { $0.available(robots) }
            display = display.filter { _ in true }
        }
        displayJobs = display
        vc.reloadCollection()
    }
}
