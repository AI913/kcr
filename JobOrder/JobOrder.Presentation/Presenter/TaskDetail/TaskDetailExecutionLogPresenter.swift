//
//  TaskDetailExecutionLogPresenter.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/12/15.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Domain
import JobOrder_Utility

// MARK: - Interface
/// TaskDetailExecutionLogPresenterProtocol
/// @mockable
protocol TaskDetailExecutionLogPresenterProtocol {
    /// View表示開始
    func viewWillAppear()
    /// アイテム数取得
    func numberOfSections() -> Int
    /// ステータス
    /// - Parameter index: 配列Index
    func result(index: Int) -> String?
    /// 実行日時
    /// - Parameter index: 配列Index
    func executedAt(index: Int) -> String?
    /// 前のページに遷移できるか
    func canGoPrev() -> Bool
    /// 次のページに遷移できるか
    func canGoNext() -> Bool
    /// 現在ページおよび総ページの表示状態
    func pageText() -> String?
    /// 前のページを表示
    func viewPrevPage()
    /// 次のページを表示
    func viewNextPage()
}

class TaskDetailExecutionLogPresenter {
    /// DataManageUseCaseProtocol
    private let dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// TaskDetailExecutionLogViewController
    private let vc: TaskDetailExecutionLogViewControllerProtocol
    /// ViewData
    var viewData: TaskDetailViewData!
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// 実行ログ
    var executionLogs: [DataManageModel.Output.ExecutionLog] = []
    /// 現在表示しているカーソル
    var cursor: PagingModel.Cursor?
    /// トータルのタスク数
    var totalItems: Int?

    required init(dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: TaskDetailExecutionLogViewControllerProtocol,
                  viewData: TaskDetailViewData) {
        self.vc = vc
        self.dataUseCase = dataUseCase
        self.viewData = viewData
    }

}

// MARK: - Protocol Function
extension TaskDetailExecutionLogPresenter: TaskDetailExecutionLogPresenterProtocol {

    /// View表示開始
    func viewWillAppear() {
        getCommand()
        getTask()
        getExecutionLogs()
    }

    /// アイテム数取得
    func numberOfSections() -> Int {
        executionLogs.count
    }

    /// 結果
    /// - Parameter index: 配列Index
    func result(index: Int) -> String? {
        executionLogs[index].result
    }

    /// 実行日時
    /// - Parameter index: 配列Index
    func executedAt(index: Int) -> String? {
        executionLogs[index].executedAt.toEpocTime.toMediumDateTimeString
    }

    /// 前のページに遷移できるか
    func canGoPrev() -> Bool {
        guard let currentPage = currentPage else { return false }
        return firstPage <= currentPage - 1
    }

    /// 次のページに遷移できるか
    func canGoNext() -> Bool {
        guard let currentPage = currentPage, let lastPage = lastPage else { return false }
        return currentPage + 1 <= lastPage
    }

    /// 現在ページおよび総ページの表示状態
    func pageText() -> String? {
        guard let currentPage = currentPage, let lastPage = lastPage else { return nil }
        return "\(currentPage) / \(lastPage)"
    }

    /// 前のページを表示
    func viewPrevPage() {
        self.cursor = prevCursor
        getExecutionLogs()
    }

    /// 次のページを表示
    func viewNextPage() {
        self.cursor = nextCursor
        getExecutionLogs()
    }

}

// MARK: - Private Function
extension TaskDetailExecutionLogPresenter {

    private func getExecutionLogs() {
        guard let taskId = viewData.taskId else { return }
        guard let robotId = viewData.robotId else { return }

        let cursor = self.cursor ?? PagingModel.Cursor(offset: 0, limit: itemsPerPage)
        dataUseCase.executionLogsFromTask(taskId: taskId, robotId: robotId, cursor: cursor)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(String(describing: response))")
                self.executionLogs = response.data
                self.totalItems = response.total
                self.cursor = response.cursor
                self.vc.reloadTable()
            }).store(in: &cancellables)
    }

    func getCommand() {
        guard let taskId = viewData.taskId else { return }
        guard let robotId = viewData.robotId else { return }

        dataUseCase.commandFromTask(taskId: taskId, robotId: robotId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(String(describing: response))")
                self.vc.setRobot(name: response.robot?.name)
            }).store(in: &cancellables)
    }

    func getTask() {
        guard let taskId = viewData.taskId else { return }

        dataUseCase.task(taskId: taskId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(String(describing: response))")
                self.vc.setJob(name: response.job.name)
            }).store(in: &cancellables)
    }

    private var itemsPerPage: Int {
        10
    }

    private var firstPage: Int {
        1
    }

    private var lastPage: Int? {
        guard let totalItems = totalItems, totalItems > 0 else { return nil }
        return (totalItems - 1) / itemsPerPage + 1
    }

    private var currentPage: Int? {
        guard let cursor = cursor else { return nil }
        return cursor.toPaging().page
    }

    private var nextCursor: PagingModel.Cursor? {
        guard var cursor = cursor else { return nil }
        cursor.offset += itemsPerPage
        return cursor
    }

    private var prevCursor: PagingModel.Cursor? {
        guard var cursor = cursor else { return nil }
        cursor.offset -= itemsPerPage
        return cursor
    }

}
