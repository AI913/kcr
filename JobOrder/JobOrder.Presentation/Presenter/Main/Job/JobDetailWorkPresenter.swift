//
//  JobDetailWorkPresenter.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/11/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Domain
import JobOrder_Utility

// MARK: - Interface
/// JobDetailWorkPresenterProtocol
/// @mockable
protocol JobDetailWorkPresenterProtocol {
    /// ViewData
    var data: MainViewData.Job { get }
    /// View表示開始
    func viewWillAppear()
    /// アイテム数取得
    /// - Parameter in: 設定情報識別子
    func numberOfSections(in: JobDetailWorkPresenter.Dataset) -> Int
    /// セルを選択
    /// - Parameter index: 配列のIndex
    func selectRow(in: JobDetailWorkPresenter.Dataset, indexPath: IndexPath)
    /// オーダー名称
    /// - Parameters:
    ///   - in: 設定情報識別子
    ///   - index: 配列のIndex
    func orderName(in: JobDetailWorkPresenter.Dataset, index: Int) -> String?
    /// アサイン情報
    /// - Parameters:
    ///   - in: 設定情報識別子
    ///   - index: 配列のIndex
    func assignName(in: JobDetailWorkPresenter.Dataset, index: Int) -> String?
    /// タスクの状態
    /// - Parameters:
    ///   - in: 設定情報識別子
    ///   - index: 配列のIndex
    func status(in: JobDetailWorkPresenter.Dataset, index: Int) -> String?
}

// MARK: - Implementation
/// JobDetailWorkPresenter
class JobDetailWorkPresenter {
    /// DataManageUseCaseProtocol
    private let dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// JobDetailWorkViewControllerProtocol
    private let vc: JobDetailWorkViewControllerProtocol
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
                  vc: JobDetailWorkViewControllerProtocol,
                  viewData: MainViewData.Job) {
        self.vc = vc
        self.data = viewData
        self.dataUseCase = dataUseCase
    }
}

// MARK: - Protocol Function
extension JobDetailWorkPresenter: JobDetailWorkPresenterProtocol {

    /// View表示開始
    func viewWillAppear() {
        getTasks()
    }

    /// アイテム数取得
    /// - Parameter in: 設定情報識別子
    func numberOfSections(in: JobDetailWorkPresenter.Dataset) -> Int {
        tasks?.count ?? 0
    }

    /// セルを選択
    /// - Parameter index: 配列のIndex
    func selectRow(in: JobDetailWorkPresenter.Dataset, indexPath: IndexPath) {
        let taskId = tasks?[indexPath.section].id
        let robotIds = tasks?[indexPath.section].robotIds
        vc.launchTaskDetail(taskId: taskId, robotIds: robotIds)
    }

    /// オーダー名称
    /// - Parameters:
    ///   - in: 設定情報識別子
    ///   - indexPath: 配列のIndex
    func orderName(in: JobDetailWorkPresenter.Dataset, index: Int) -> String? {
        guard let createTime = tasks?[index].createTime else { return nil }
        let suffix = "のオーダー"
        return toDateString(toEpocTime(createTime)) + suffix
    }
    /// アサイン情報
    /// - Parameters:
    ///   - in: 設定情報識別子
    ///   - indexPath: 配列のIndex
    func assignName(in: JobDetailWorkPresenter.Dataset, index: Int) -> String? {
        guard let robotIds = tasks?[index].robotIds else { return nil }
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
    func status(in: JobDetailWorkPresenter.Dataset, index: Int) -> String? {
        guard let task = self.tasks?[index] else { return nil }
        guard let command = self.commands.first(where: { $0.taskId == task.id }) else { return nil }
        return command.status
    }
}

// MARK: - Private Function
extension JobDetailWorkPresenter {

    private func reset() {
        tasks = nil
        commands.removeAll()
        cancellables.forEach { $0.cancel() }
    }

    private func getTasks() {
        guard let id = data.id else { return }
        reset()

        dataUseCase.tasksFromJob(id: id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    if let tasks = self.tasks {
                        for task in tasks {
                            guard let robotId = task.robotIds.first else { continue }
                            self.getCommand(taskId: task.id, robotId: robotId)
                        }
                    }
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(String(describing: response))")
                self.tasks = response.sorted { $0.createTime < $1.createTime }
                self.vc.reloadTable()
            }).store(in: &cancellables)
    }

    private func getCommand(taskId: String, robotId: String) {
        dataUseCase.commandFromTask(taskId: taskId, robotId: robotId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "taskId: \(taskId), robotId: \(robotId) -> \(String(describing: response))")
                self.commands.append(response)
                if let index = self.updateTaskItem(by: response) {
                    self.vc.reloadRows(dataset: .task, at: [index])
                    self.vc.reloadRows(dataset: .history, at: [index])
                }
            }).store(in: &cancellables)
    }

    private func updateTaskItem(by command: DataManageModel.Output.Command) -> IndexPath? {
        guard let tasks = self.tasks else { return nil }
        if let index = tasks.firstIndex(where: { $0.id == command.taskId }) {
            return IndexPath(row: 0, section: index)
        }
        return nil
    }

    private func toDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func toEpocTime(_ data: Int) -> Date {
        return Date(timeIntervalSince1970: Double(data / 1000))
    }

}
