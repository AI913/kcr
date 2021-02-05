//
//  TaskDetailRunHistoryPresenter.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/12/08.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Domain
import JobOrder_Utility

// MARK: - Interface
/// TaskDetailRunHistoryPresenterProtocol
/// @mockable
protocol TaskDetailRunHistoryPresenterProtocol {
    /// 表示中のアイテム
    var browsing: TaskDetailRunHistoryPresenter.Browsing { get }
    /// View表示開始
    func viewWillAppear()
    /// アイテム数取得
    func numberOfSections() -> Int
    /// セルを選択
    func selectRow(indexPath: IndexPath)
    /// オーダー名称(タスク)
    /// - Parameters:
    ///   - index: 配列のIndex
    func orderName(index: Int) -> String?
    /// アサイン情報(タスク)
    /// - Parameters:
    ///   - index: 配列のIndex
    func assignName(index: Int) -> String?
    /// タスクの状態
    /// - Parameters:
    ///   - index: 配列のIndex
    func taskStatus(index: Int) -> String?
    /// ジョブ名称(コマンド)
    /// - Parameter index: 配列のIndex
    func jobName(index: Int) -> String?
    /// 作成日(コマンド)
    /// - Parameter index: 配列のIndex
    func createdAt(index: Int) -> String?
    /// コマンドの結果情報
    /// - Parameter index: 配列のIndex
    func result(index: Int) -> String?
    /// コマンドの状態
    /// - Parameter index: 配列のIndex
    func commandStatus(index: Int) -> String?
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

// MARK: - Implementation
/// TaskRunHistoryPresenter
class TaskDetailRunHistoryPresenter {
    /// DataManageUseCaseProtocol
    private let dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// TaskDetailRunHistoryViewControllerProtocol
    private let vc: TaskDetailRunHistoryViewControllerProtocol
    /// ViewData(Job)
    var jobData: MainViewData.Job?
    /// ViewData(Robot)
    var robotData: MainViewData.Robot?
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// タスクリスト
    var tasks: [DataManageModel.Output.Task] = []
    /// コマンドリスト
    var commands: [DataManageModel.Output.Command] = []
    /// 現在表示しているカーソル
    var cursor: PagingModel.Cursor?
    /// トータルのタスク数
    var totalItems: Int?
    /// 一覧の取得方法
    var method: FetchMethod
    /// 一覧に表示するもの
    var browsing: Browsing

    enum FetchMethod {
        case tasksEachCommands
        case commandsEachTasks
    }

    enum Browsing {
        case tasks
        case commands
    }

    required init(dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: TaskDetailRunHistoryViewControllerProtocol,
                  jobData: MainViewData.Job) {
        self.vc = vc
        self.jobData = jobData
        self.dataUseCase = dataUseCase
        self.method = .tasksEachCommands
        self.browsing = .tasks
    }

    required init(dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: TaskDetailRunHistoryViewControllerProtocol,
                  robotData: MainViewData.Robot) {
        self.vc = vc
        self.robotData = robotData
        self.dataUseCase = dataUseCase
        self.method = .commandsEachTasks
        self.browsing = .commands
    }

}

// MARK: - Protocol Function
extension TaskDetailRunHistoryPresenter: TaskDetailRunHistoryPresenterProtocol {

    /// View表示開始
    func viewWillAppear() {
        getTasks()
    }

    /// アイテム数取得
    /// - Parameter in: 設定情報識別子
    func numberOfSections() -> Int {
        switch browsing {
        case .tasks:
            return tasks.count
        case .commands:
            return commands.count
        }
    }

    /// セルを選択
    func selectRow(indexPath: IndexPath) {
        switch browsing {
        case .tasks:
            let robotIds = tasks[indexPath.section].robotIds
            if robotIds.count > 1 {
                let taskId = tasks[indexPath.section].id
                vc.launchTaskDetailRobotSelection(taskId: taskId)
            } else {
                let jobId = tasks[indexPath.section].jobId
                guard let robotId = tasks[indexPath.section].robotIds.first else { return }
                vc.launchTaskDetailTaskInformation(jobId: jobId, robotId: robotId)
            }
        case .commands:
            let taskId = commands[indexPath.section].taskId
            let robotId = commands[indexPath.section].robotId
            guard let jobId = tasks.first(where: { $0.id == taskId })?.jobId else { return }
            vc.launchTaskDetailTaskInformation(jobId: jobId, robotId: robotId)
        }
    }

    /// オーダー名称(タスク)
    /// - Parameters:
    ///   - indexPath: 配列のIndex
    func orderName(index: Int) -> String? {
        let createTime = tasks[index].createTime
        let suffix = "のオーダー"
        return createTime.toEpocTime.toMediumDateString + suffix
    }

    /// アサイン情報(タスク)
    /// - Parameters:
    ///   - indexPath: 配列のIndex
    func assignName(index: Int) -> String? {
        let robotIds = tasks[index].robotIds
        guard let firstRobotId = robotIds.first else { return nil }
        guard let name = dataUseCase.robots?.first(where: { $0.id == firstRobotId })?.name else { return nil }

        if robotIds.count > 1 {
            return "\(name) 他\(robotIds.count - 1)台にアサイン"
        }
        return name
    }

    /// タスクの状態
    /// - Parameters:
    ///   - in: 設定情報識別子
    ///   - indexPath: 配列のIndex
    func taskStatus(index: Int) -> String? {
        let task = self.tasks[index]
        guard let command = self.commands.first(where: { $0.taskId == task.id }) else { return nil }
        return command.status
    }

    /// ジョブ名称(コマンド)
    /// - Parameter index: 配列のIndex
    func jobName(index: Int) -> String? {
        let command = self.commands[index]
        guard let task = self.tasks.first(where: { $0.id == command.taskId }) else { return "N/A" }
        return task.job.name
    }

    /// 作成日(コマンド)
    /// - Parameter index: 配列のIndex
    func createdAt(index: Int) -> String? {
        "Created at: " + self.commands[index].createTime.toEpocTime.toDateString
    }

    /// コマンドの結果情報
    /// - Parameter index: 配列のIndex
    func result(index: Int) -> String? {
        let success = self.commands[index].success
        let fail = self.commands[index].fail
        let error = self.commands[index].error
        return "Success \(success) / Fail \(fail) / Error \(error)"
    }

    /// コマンドの状態
    /// - Parameter index: 配列のIndex
    func commandStatus(index: Int) -> String? {
        commands[index].status
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
        getTasks()
    }

    /// 次のページを表示
    func viewNextPage() {
        self.cursor = nextCursor
        getTasks()
    }

}

// MARK: - Private Function
extension TaskDetailRunHistoryPresenter {

    private func reset() {
        tasks.removeAll()
        commands.removeAll()
        cancellables.forEach { $0.cancel() }
    }

    private func getTasks() {
        switch method {
        case .tasksEachCommands:
            getTasksAndCommands()
        case .commandsEachTasks:
            getCommandsAndTasks()
        }
    }

    private func getTasksAndCommands() {
        guard let id = jobData?.id else { return }
        reset()

        let cursor = self.cursor ?? PagingModel.Cursor(offset: 0, limit: itemsPerPage)
        dataUseCase.tasksFromJob(id: id, cursor: cursor)
            .receive(on: DispatchQueue.main)
            .tryMap({ response -> PagingModel.PaginatedResult<[DataManageModel.Output.Task]> in
                if response.data.allSatisfy({ !$0.robotIds.isEmpty }) {
                    return response
                }
                throw JobOrderError.connectionFailed(reason: .unacceptableResponse)
            })
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(String(describing: response))")
                self.tasks = response.data
                self.totalItems = response.total
                self.cursor = response.cursor
                self.tasks
                    .compactMap { self.dataUseCase.commandFromTask(taskId: $0.id, robotId: $0.robotIds.first!) }
                    .serialize()?
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished: break
                        case .failure(let error):
                            self.vc.showErrorAlert(error)
                        }
                    }, receiveValue: { response in
                        Logger.debug(target: self, "\(String(describing: response))")
                        self.commands.append(response)
                        if let index = self.updateTaskItem(by: response) {
                            self.vc.reloadRows(at: [index])
                        }
                    }).store(in: &self.cancellables)
                self.vc.reloadTable()
            }).store(in: &cancellables)
    }

    private func updateTaskItem(by command: DataManageModel.Output.Command) -> IndexPath? {
        if let index = tasks.firstIndex(where: { $0.id == command.taskId }) {
            return IndexPath(row: 0, section: index)
        }
        return nil
    }

    private func getCommandsAndTasks() {
        guard let id = robotData?.id else { return }
        reset()

        let cursor = self.cursor ?? PagingModel.Cursor(offset: 0, limit: itemsPerPage)
        dataUseCase.commandFromRobot(id: id, status: CommandModel.Status.done, cursor: cursor)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(String(describing: response))")
                self.commands = response.data
                self.totalItems = response.total
                self.cursor = response.cursor
                self.commands
                    .compactMap { self.dataUseCase.task(taskId: $0.taskId) }
                    .serialize()?
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished: break
                        case .failure(let error):
                            self.vc.showErrorAlert(error)
                        }
                    }, receiveValue: { response in
                        Logger.debug(target: self, "\(String(describing: response))")
                        self.tasks.append(response)
                        if let index = self.updateTaskItem(by: response) {
                            self.vc.reloadRows(at: [index])
                        }
                    }).store(in: &self.cancellables)
                self.vc.reloadTable()
            }).store(in: &cancellables)
    }

    private func updateTaskItem(by task: DataManageModel.Output.Task) -> IndexPath? {
        if let index = commands.firstIndex(where: { $0.taskId == task.id }) {
            return IndexPath(row: 0, section: index)
        }
        return nil
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
