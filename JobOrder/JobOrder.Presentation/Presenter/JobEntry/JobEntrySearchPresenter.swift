//
//  JobEntrySearchPresenter.swift
//  JobOrder.Presentation
//
//  Created by Frontarc on 2021/02/04.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import UIKit
import Combine
import JobOrder_Domain

// MARK: - Interface
/// JobEntrySearchPresenterProtocol
/// @mockable
protocol JobEntrySearchPresenterProtocol {
    /// アイテム数
    var numberOfItemsInSection: Int { get }
    /// ActionLibrary ID取得
    /// - Parameter index: 配列のIndex
    func id(_ index: Int) -> String?
    /// ActionLibraryの画像名取得
    /// - Parameter index: 配列のIndex
    func actionLibraryImagePath(_ index: Int) -> String?
    /// ActionLibraryの表示名取得
    /// - Parameter index: 配列のIndex
    func displayName(_ index: Int) -> String?
    /// ActionLibraryのバージョン取得
    /// - Parameter index: 配列のIndex
    func version(_ index: Int) -> Int?
    /// 検索
    /// - Parameter keyword: 検索キーワード
    func filterAndSort(keyword: String?, keywordChanged: Bool)
}

// MARK: - Implementation
/// JobEntrySearchPresenter
class JobEntrySearchPresenter {
    private var searchKeyString: String = ""
    /// DataManageUseCaseProtocol
    private let dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// JobEntrySearchViewControllerProtocol
    private let vc: JobEntrySearchViewControllerProtocol
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// リストに表示するActionLibraryのデータ配列（フィルタ処理後）
    var displayActionLibraries: [JobOrder_Domain.DataManageModel.Output.ActionLibrary]?
    /// リストに表示するActionLibraryのデータ配列（フィルタ処理前）
    var originalActionLibraries: [JobOrder_Domain.DataManageModel.Output.ActionLibrary]?
    /// 取得したRobotのデータ配列
    private var cachedActionLibraries: [String: JobOrder_Domain.DataManageModel.Output.ActionLibrary]?

    /// イニシャライザ
    /// - Parameters:
    ///   - dataUseCase: DataManageUseCaseProtocol
    ///   - vc: JobEntrySearchViewControllerProtocol
    required init(dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: JobEntrySearchViewControllerProtocol) {
        self.dataUseCase = dataUseCase
        self.vc = vc
        observeActionLibraries()
        cacheActionLibraries(dataUseCase.actionLibraries)
    }
}

// MARK: - Protocol Function
extension JobEntrySearchPresenter: JobEntrySearchPresenterProtocol {
    /// リストの行数
    var numberOfItemsInSection: Int {
        displayActionLibraries?.count ?? 0
    }

    /// ActionLibrary ID取得
    /// - Parameter index: 配列のIndex
    /// - Returns: ActionLibrary ID
    func id(_ index: Int) -> String? {
        return displayActionLibraries?[index].id
    }

    /// ActionLibraryの画像名取得
    /// - Parameter index: 配列のIndex
    /// - Returns: 画像名
    func actionLibraryImagePath(_ index: Int) -> String? {
        return displayActionLibraries?[index].imagePath
    }

    /// ActionLibraryの表示名取得
    /// - Parameter index: 配列のIndex
    /// - Returns: 表示名
    func displayName(_ index: Int) -> String? {
        return displayActionLibraries?[index].name
    }

    /// ActionLibraryのバージョン取得
    /// - Parameter index: 配列のIndex
    /// - Returns: バージョン
    func version(_ index: Int) -> Int? {
        return displayActionLibraries?[index].version
    }

    /// 検索
    /// - Parameter keyword: 検索キーワード
    func filterAndSort(keyword: String?, keywordChanged: Bool) {

        filterAndSort(keyword: keyword, actionLibraries: displayActionLibraries, keywordChanged: keywordChanged)
    }
}

// MARK: - Private Function
extension JobEntrySearchPresenter {

    func observeActionLibraries() {
        dataUseCase.observeActionLibraryData()
            .receive(on: DispatchQueue.main)
            .sink { response in
                // Logger.debug(target: self, "\(String(describing: response))")
                self.cacheActionLibraries(response)
            }.store(in: &cancellables)
    }

    func cacheActionLibraries(_ actionLibraries: [DataManageModel.Output.ActionLibrary]?) {
        guard let actionLibraries = actionLibraries else { return }
        cachedActionLibraries = actionLibraries.reduce(into: [String: DataManageModel.Output.ActionLibrary]()) { $0[$1.id] = $1 }
        filterAndSort()
    }

    func filterAndSort() {
        guard let actionLibraries = cachedActionLibraries else { return }

        var display = actionLibraries.values.sorted {
            $0.name < $1.name
        }

        if let actionLibraries = dataUseCase.actionLibraries, !actionLibraries.isEmpty {
            display = display.filter { _ in true }
        }
        displayActionLibraries = display
        originalActionLibraries = display
        vc.reloadCollection()
    }

    func filterAndSort(keyword: String? = nil, actionLibraries: [JobOrder_Domain.DataManageModel.Output.ActionLibrary]?, keywordChanged: Bool) {
        guard var actionLibraries = actionLibraries else { return }

        var searchKeyWord: String? = keyword
        if keywordChanged {
            searchKeyString = searchKeyWord!
            actionLibraries = originalActionLibraries!
        } else {
            searchKeyWord = searchKeyString
            originalActionLibraries = actionLibraries
        }

        // TODO: - Sort by user settings.
        var display = actionLibraries.sorted {
            if $0.name != $1.name {
                return $0.name < $1.name
            } else {
                return $0.id < $1.id
            }
        }

        if let searchKeyWord = searchKeyWord, !searchKeyWord.isEmpty {
            display = display.filter {
                return $0.name.uppercased().contains(searchKeyWord.uppercased())
            }
        }
        displayActionLibraries = display
        vc.reloadCollection()
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
