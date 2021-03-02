//
//  ActionEntryConfigurationParametersResultPresenter.swift
//  JobOrder.Presentation
//
//  Created by Frontarc on 2021/02/25.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Domain
import JobOrder_Utility

// MARK: - Interface
/// ActionEntryConfigurationParametersResultPresenterProtocol
/// @mockable
protocol ActionEntryConfigurationParametersResultPresenterProtocol {
    /// ViewData
    var data: MainViewData.Job { get }
    /// View表示開始
    func viewWillAppear()
    /// アイテム数取得
    /// - Parameter in: 設定情報識別子
    func numberOfSections(in: ActionEntryConfigurationParametersResultPresenter.Dataset) -> Int
//    /// セルを選択
//    /// - Parameter index: 配列のIndex
    func selectRow(in: ActionEntryConfigurationParametersResultPresenter.Dataset, indexPath: IndexPath)
    /// 概要
    /// - Parameters:
    ///   - in: 設定情報識別子
    ///   - index: 配列のIndex
    func overview(in: ActionEntryConfigurationParametersResultPresenter.Dataset, index: Int) -> String?
    /// ActionLibrary名称
    /// - Parameters:
    ///   - in: 設定情報識別子
    ///   - index: 配列のIndex
    func name(in: ActionEntryConfigurationParametersResultPresenter.Dataset, index: Int) -> String?
//    /// タスクの状態
//    /// - Parameters:
//    ///   - in: 設定情報識別子
//    ///   - index: 配列のIndex
//    func status(in: ActionEntryConfigurationParametersResultPresenter.Dataset, index: Int) -> String?
}

// MARK: - Implementation
/// ActionEntryConfigurationParametersResultPresenter
class ActionEntryConfigurationParametersResultPresenter {
    /// DataManageUseCaseProtocol
    private let dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// ActionEntryConfigurationParametersResultViewControllerProtocol
    private let vc: ActionEntryConfigurationParametersResultViewControllerProtocol
    /// ViewData
    var data: MainViewData.Job
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// タスクリスト
    var tasks: [DataManageModel.Output.Task]?
    /// コマンドリスト
    var commands: [DataManageModel.Output.Command] = []

    /// タスクと履歴の設定情報識別子
    enum Dataset {
        case task
        case history
    }

    required init(dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: ActionEntryConfigurationParametersResultViewControllerProtocol,
                  viewData: MainViewData.Job) {
        self.vc = vc
        self.data = viewData
        self.dataUseCase = dataUseCase
    }
}

// MARK: - Protocol Function
extension ActionEntryConfigurationParametersResultPresenter: ActionEntryConfigurationParametersResultPresenterProtocol {

    /// View表示開始
    func viewWillAppear() {
//        getTasksAndCommands()
    }

    /// アイテム数取得
    /// - Parameter in: 設定情報識別子
    func numberOfSections(in: ActionEntryConfigurationParametersResultPresenter.Dataset) -> Int {
        tasks?.count ?? 0
    }

//    /// セルを選択
    /// - Parameter index: 配列のIndex
    func selectRow(in: ActionEntryConfigurationParametersResultPresenter.Dataset, indexPath: IndexPath) {
//        let taskId = tasks?[indexPath.section].id
//        let robotIds = tasks?[indexPath.section].robotIds
//        vc.launchTaskDetail(taskId: taskId, robotIds: robotIds)
    }

    /// 概要
    /// - Parameters:
    ///   - in: 設定情報識別子
    ///   - indexPath: 配列のIndex
    func overview(in: ActionEntryConfigurationParametersResultPresenter.Dataset, index: Int) -> String? {
        guard let robotIds = tasks?[index].robotIds else { return nil }
        guard let firstRobotId = robotIds.first else { return nil }
        guard let name = dataUseCase.robots?.first(where: { $0.id == firstRobotId })?.name else { return nil }

        if robotIds.count > 1 {
            return "\(name) 他\(robotIds.count - 1)台にアサイン"
        }
        return name
    }
    /// オーダー名称
    /// - Parameters:
    ///   - in: 設定情報識別子
    ///   - indexPath: 配列のIndex
    func name(in: ActionEntryConfigurationParametersResultPresenter.Dataset, index: Int) -> String? {
        guard let createTime = tasks?[index].createTime else { return nil }
        let suffix = "のオーダー"
        return createTime.toEpocTime.toMediumDateString + suffix
    }
//    /// タスクの状態
//    /// - Parameters:
//    ///   - in: 設定情報識別子
//    ///   - indexPath: 配列のIndex
//    func status(in: JobDetailWorkPresenter.Dataset, index: Int) -> String? {
//        guard let task = self.tasks?[index] else { return nil }
//        guard let command = self.commands.first(where: { $0.taskId == task.id }) else { return nil }
//        return command.status
//    }
}

// MARK: - Private Function
extension ActionEntryConfigurationParametersResultPresenter {

    private func reset() {
        tasks = nil
        commands.removeAll()
        cancellables.forEach { $0.cancel() }
    }

//    private func getTasksAndCommands() {
//        guard let id = data.id else { return }
//        reset()
//
//        dataUseCase.tasksFromJob(id: id, cursor: PagingModel.Cursor(offset: 0, limit: 10))
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .finished: break
//                case .failure(let error):
//                    self.vc.showErrorAlert(error)
//                }
//            }, receiveValue: { response in
//                Logger.debug(target: self, "\(String(describing: response))")
//                self.tasks = response.data
//                self.tasks?.filter { !$0.robotIds.isEmpty }
//                    .compactMap { self.dataUseCase.commandFromTask(taskId: $0.id, robotId: $0.robotIds.first!) }
//                    .serialize()?
//                    .receive(on: DispatchQueue.main)
//                    .sink(receiveCompletion: { completion in
//                        switch completion {
//                        case .finished: break
//                        case .failure(let error):
//                            self.vc.showErrorAlert(error)
//                        }
//                    }, receiveValue: { response in
//                        Logger.debug(target: self, "\(String(describing: response))")
//                        self.commands.append(response)
//                        if let index = self.updateTaskItem(by: response) {
//                            self.vc.reloadRows(dataset: .task, at: [index])
//                            self.vc.reloadRows(dataset: .history, at: [index])
//                        }
//                    }).store(in: &self.cancellables)
//                self.vc.reloadTable()
//            }).store(in: &cancellables)
//    }

//    private func updateTaskItem(by command: DataManageModel.Output.Command) -> IndexPath? {
//        guard let tasks = self.tasks else { return nil }
//        if let index = tasks.firstIndex(where: { $0.id == command.taskId }) {
//            return IndexPath(row: 0, section: index)
//        }
//        return nil
//    }
}
