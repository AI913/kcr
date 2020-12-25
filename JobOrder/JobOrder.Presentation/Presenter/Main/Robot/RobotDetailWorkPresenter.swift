//
//  RobotDetailWorkPresenter.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import UIKit
import Combine
import JobOrder_Domain
import JobOrder_Utility

// MARK: - Interface
/// RobotDetailWorkPresenterProtocol
/// @mockable
protocol RobotDetailWorkPresenterProtocol {
    /// ViewData
    var data: MainViewData.Robot { get }
    /// View表示開始
    func viewWillAppear()
    /// セクション数取得
    /// - Parameter in: 設定情報識別子
    func numberOfSections(in: RobotDetailWorkPresenter.Dataset) -> Int
    /// セルを選択
    /// - Parameter in: 設定情報識別子
    /// - Parameter index: 配列のIndex
    func selectRow(in: RobotDetailWorkPresenter.Dataset, indexPath: IndexPath)
    /// Task名取得
    /// - Parameter in: 設定情報識別子
    /// - Parameter index: 配列のIndex
    func taskName(in: RobotDetailWorkPresenter.Dataset, _ index: Int) -> String?
    /// Task ID取得
    /// - Parameter in: 設定情報識別子
    /// - Parameter index: 配列のIndex
    func identifier(in: RobotDetailWorkPresenter.Dataset, _ index: Int) -> String?
    /// Task登録時刻取得
    /// - Parameter in: 設定情報識別子
    /// - Parameter index: 配列のIndex
    /// - Parameter textColor: テキストカラー
    /// - Parameter font: フォント
    func queuedAt(in: RobotDetailWorkPresenter.Dataset, _ index: Int, textColor: UIColor, font: UIFont) -> NSAttributedString?

    /// 実行結果取得
    /// - Parameter in: 設定情報識別子
    /// - Parameter index: 配列のIndex
    func resultInfo(in: RobotDetailWorkPresenter.Dataset, _ index: Int) -> String?
    /// コマンドのステータス取得
    /// - Parameter in: 設定情報識別子
    /// - Parameter index: 配列のIndex
    func status(in: RobotDetailWorkPresenter.Dataset, _ index: Int) -> String
    /// Job名取得
    /// - Parameter in: 設定情報識別子
    /// - Parameter index: 配列のIndex
    func jobName(_ index: Int) -> String?
}

// MARK: - Implementation
/// RobotDetailWorkPresenter
class RobotDetailWorkPresenter {
    /// DataManageUseCaseProtocol
    private let dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// RobotDetailWorkViewControllerProtocol
    private let vc: RobotDetailWorkViewControllerProtocol
    /// ViewData
    var data: MainViewData.Robot
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// 実行中のコマンド
    var tasks: [DataManageModel.Output.Command]?
    /// 実行済みのコマンド
    var history: [DataManageModel.Output.Command]?
    /// タスク情報
    var task: [DataManageModel.Output.Task] = []

    /// タスクと履歴の設定情報識別子
    enum Dataset {
        case tasks
        case history
    }

    /// イニシャライザ
    /// - Parameters:
    ///   - dataUseCase: DataManageUseCaseProtocol
    ///   - vc: RobotDetailWorkViewControllerProtocol
    ///   - viewData: MainViewData.Robot
    required init(dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: RobotDetailWorkViewControllerProtocol,
                  viewData: MainViewData.Robot) {
        self.dataUseCase = dataUseCase
        self.vc = vc
        self.data = viewData
        observeRobots()
    }
}

// MARK: - Protocol Function
extension RobotDetailWorkPresenter: RobotDetailWorkPresenterProtocol {
    /// View表示開始
    func viewWillAppear() {
        guard let id = data.id else { return }
        getTasksAndJob(id: id)
        getHistoryAndJob(id: id)
    }

    /// セクション数取得
    /// - Parameter in: 設定情報識別子
    /// - Returns: セクション数
    func numberOfSections(in dataset: RobotDetailWorkPresenter.Dataset) -> Int {
        let commands = selectCommands(in: dataset)
        return commands?.count ?? 0
    }

    /// セルを選択
    /// - Parameter in: 設定情報識別子
    /// - Parameter index: 配列のIndex
    func selectRow(in dataset: RobotDetailWorkPresenter.Dataset, indexPath: IndexPath) {
        let commands = selectCommands(in: dataset)
        let taskId = commands?[indexPath.section].taskId
        let robotId = commands?[indexPath.section].robotId
        vc.launchTaskDetail(jobId: taskId, robotId: robotId)
    }

    /// Task名取得
    /// - Parameter in: 設定情報識別子
    /// - Parameter index: 配列のIndex
    /// - Returns: Task名
    func taskName(in dataset: RobotDetailWorkPresenter.Dataset, _ index: Int) -> String? {
        let commands = selectCommands(in: dataset)
        let date = commands?[index].createTime.toEpocTime.toDateString ?? "N/A"
        return "Created at : " + date
    }

    /// Task ID取得
    /// - Parameter in: 設定情報識別子
    /// - Parameter index: 配列のIndex
    /// - Returns: Task ID
    func identifier(in dataset: RobotDetailWorkPresenter.Dataset, _ index: Int) -> String? {
        let commands = selectCommands(in: dataset)
        return commands?[index].taskId
    }

    /// Task登録時刻取得
    /// - Parameter in: 設定情報識別子
    /// - Parameter index: 配列のIndex
    /// - Parameter textColor: テキストカラー
    /// - Parameter font: フォント
    /// - Returns: Task登録時刻時刻
    func queuedAt(in dataset: RobotDetailWorkPresenter.Dataset, _ index: Int, textColor: UIColor, font: UIFont) -> NSAttributedString? {
        let commands = selectCommands(in: dataset)
        let date = commands?[index].createTime.toEpocTime
        return string(date: date, label: "Created at : ", textColor: textColor, font: font)
    }

    /// 実行結果取得
    /// - Parameter in: 設定情報識別子
    /// - Parameter index: 配列のIndex
    /// - Returns: 実行結果
    func resultInfo(in dataset: RobotDetailWorkPresenter.Dataset, _ index: Int) -> String? {
        guard let commands = selectCommands(in: dataset) else { return nil }
        return "Success \(commands[index].success ) / Fail \(commands[index].fail) / Error \(commands[index].error)"
    }

    /// 状態取得
    /// - Parameter in: 設定情報識別子
    /// - Parameter index: 配列のindex
    /// - Returns: 状態
    func status(in dataset: RobotDetailWorkPresenter.Dataset, _ index: Int) -> String {
        let commands = selectCommands(in: dataset)
        return commands?[index].status ?? ""
    }

    /// Job名取得
    /// - Parameter in: 設定情報識別子
    /// - Parameter index: 配列のIndex
    /// - Returns: Job名
    func jobName(_ index: Int) -> String? {
        guard self.task.indices.contains(index) else { return "" }
        return self.task[index].job.name
    }
}

// MARK: - Private Function
extension RobotDetailWorkPresenter {

    private func observeRobots() {
        dataUseCase.observeRobotData()
            .receive(on: DispatchQueue.main)
            .sink { response in
                // Logger.debug(target: self, "\(String(describing: response))")
                self.vc.reloadTable()
            }.store(in: &cancellables)
    }

    func getTasksAndJob(id: String) {
        dataUseCase.commandFromRobot(id: id, status: CommandModel.Status.inProgress, cursor: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(String(describing: response))")
                self.tasks = response.data.sorted(by: self.commandSortRule)
                self.tasks?.filter { !$0.taskId.isEmpty }
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
                        self.task.append(response)
                        self.vc.reloadRows(dataset: .tasks)
                    }).store(in: &self.cancellables)
                self.vc.reloadTable()
            }).store(in: &cancellables)
    }

    func getHistoryAndJob(id: String) {
        dataUseCase.commandFromRobot(id: id, status: CommandModel.Status.done, cursor: PagingModel.Cursor(offset: 0, limit: 20))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(String(describing: response))")
                self.history = response.data.sorted(by: self.commandSortRule)
                self.history?.filter { !$0.taskId.isEmpty }
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
                        self.task.append(response)
                        self.vc.reloadRows(dataset: .history)
                    }).store(in: &self.cancellables)
                self.vc.reloadTable()
            }).store(in: &cancellables)
    }

    private func string(date: Date?, label: String, textColor: UIColor, font: UIFont) -> NSAttributedString? {
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(NSAttributedString(string: label, attributes: [
            .foregroundColor: textColor,
            .font: font
        ]))
        let queuedAt = date?.toDateString ?? "N/A"
        mutableAttributedString.append(NSAttributedString(string: queuedAt, attributes: [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 14.0)
        ]))
        return mutableAttributedString
    }

    private func selectCommands(in dataset: Dataset) -> [DataManageModel.Output.Command]? {
        switch dataset {
        case .tasks:
            return self.tasks
        case .history:
            return self.history
        }
    }

    private func commandSortRule(lhs: DataManageModel.Output.Command, rhs: DataManageModel.Output.Command) -> Bool {
        lhs.createTime.toEpocTime < rhs.createTime.toEpocTime
    }
}
