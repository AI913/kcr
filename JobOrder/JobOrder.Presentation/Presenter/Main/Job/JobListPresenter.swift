//
//  JobListPresenter.swift
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
/// JobListPresenterProtocol
/// @mockable
protocol JobListPresenterProtocol {
    /// リストの行数
    var numberOfRowsInSection: Int { get }
    /// Job ID
    /// - Parameter index: 配列のIndex
    func id(_ index: Int) -> String?
    /// Jobの表示名
    /// - Parameter index: 配列のIndex
    func displayName(_ index: Int) -> String?
    /// Jobの詳細
    /// - Parameter index: 配列のIndex
    func requirementText(_ index: Int) -> String?
    /// セルを選択
    func selectRow(index: Int)
    /// Addボタンをタップ
    /// - Parameter index: 配列のIndex
    func tapAddButton()
    /// 検索
    /// - Parameter index: 配列のIndex
    func filterAndSort(keyword: String?)
}

// MARK: - Implementation
/// JobListPresenter
class JobListPresenter {

    /// DataManageUseCaseProtocol
    private let useCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// JobListViewControllerProtocol
    private let vc: JobListViewControllerProtocol
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// リストに表示するJobのデータ配列
    var displayJobs: [JobOrder_Domain.DataManageModel.Output.Job]?

    private var sortConditions = [SortCondition(key: .dataId, order: .ASC)] {
        didSet {
            self.filterAndSort(keyword: nil)
        }
    }

    /// イニシャライザ
    /// - Parameters:
    ///   - useCase: DataManageUseCaseProtocol
    ///   - vc: JobListViewControllerProtocol
    required init(useCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: JobListViewControllerProtocol) {
        self.useCase = useCase
        self.vc = vc
        observeJobs()
    }
}

// MARK: - Protocol Function
extension JobListPresenter: JobListPresenterProtocol {

    /// リストの行数
    var numberOfRowsInSection: Int {
        displayJobs?.count ?? 0
    }

    /// Job ID
    /// - Parameter index: 配列のIndex
    /// - Returns: Job ID
    func id(_ index: Int) -> String? {
        return displayJobs?[index].id
    }

    /// Jobの表示名
    /// - Parameter index: 配列のIndex
    /// - Returns: 表示名
    func displayName(_ index: Int) -> String? {
        return displayJobs?[index].name
    }

    /// Jobの詳細
    /// - Parameter index: 配列のIndex
    /// - Returns: 詳細
    func requirementText(_ index: Int) -> String? {
        return displayJobs?[index].overview
    }

    /// セルを選択
    /// - Parameter index: 配列のIndex
    func selectRow(index: Int) {
        vc.transitionToJobDetail()
    }

    /// Addボタンをタップ
    func tapAddButton() {
        vc.launchJobEntry()
    }

    /// 検索
    /// - Parameter keyword: 検索キーワード
    func filterAndSort(keyword: String?) {
        filterAndSort(keyword: keyword, jobs: displayJobs)
    }
}

// MARK: - Private Function
extension JobListPresenter {

    private func observeJobs() {
        useCase.observeJobData()
            .receive(on: DispatchQueue.main)
            .sink { response in
                // Logger.debug(target: self, "\(String(describing: response))")
                self.filterAndSort(jobs: response)
            }.store(in: &cancellables)
    }

    func filterAndSort(keyword: String? = nil, jobs: [JobOrder_Domain.DataManageModel.Output.Job]?) {
        guard let jobs = jobs else { return }

        // TODO: - Sort by user settings.
        var display = jobs.sorted {
            if $0.name != $1.name {
                return $0.name < $1.name
            } else {
                return $0.id < $1.id
            }
        }

        if let keyword = keyword, !keyword.isEmpty {
            display = display.filter {
                ($0.name).uppercased().contains(keyword.uppercased())
            }
        }
        displayJobs = display
        vc.reloadTable()
    }

    private struct SortCondition {
        var key: SortKey
        var order: SortOrder

        enum SortKey {
            case dataId
        }

        enum SortOrder {
            case ASC
            case DESC
        }
    }
}
