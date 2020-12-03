//
//  TaskDetailRobotSelectionPresenter.swift
//  JobOrder.Presentation
//
//  Created by frontarc on 2020/11/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import UIKit
import Combine
import JobOrder_Domain
import JobOrder_Utility

// MARK: - Interface
/// @mockable
public protocol TaskDetailRobotSelectionPresenterProtocol {
    /// TaskDetailRobotSlectionのViewData
    var data: TaskDetailViewData { get }
    func viewWillAppear(taskId: String)
    /// リストの行数
    var numberOfItems: Int { get }
    /// Job名の取得
    func jobName() -> String?
    /// Robot名の取得
    /// - Parameter index: 配列のIndex
    func displayName(_ index: Int) -> String?
    /// タイプの取得
    /// - Parameter index: 配列のIndex
    func type(_ index: Int) -> String?
    /// 更新時間の取得
    /// - Parameters:
    ///   - textColor: テキストカラー
    ///   - font: フォント
    func updatedAt(textColor: UIColor, font: UIFont) -> NSAttributedString?
    /// 作成時間の取得
    /// - Parameters:
    ///   - textColor: テキストカラー
    ///   - font: フォント
    func createdAt(textColor: UIColor, font: UIFont) -> NSAttributedString?
    /// 状態の取得
    /// - Parameter index: 配列のIndex
    func status(_ index: Int) -> String?
    /// 成功数取得
    func success(_ index: Int) -> Int?
    /// 失敗数取得
    func failure(_ index: Int) -> Int?
    /// エラー数取得
    func error(_ index: Int) -> Int?
    /// N/A数取得
    func na(_ index: Int) -> Int?
    /// Robotの画像
    /// - Parameter completion: クロージャ
    /// - Parameter index: 配列のIndex
    func image(index: Int, _ completion: @escaping (Data?) -> Void)
    func tapCancelButton()
    /// セルを選択
    /// - Parameter index: 配列のIndex
    func selectCell(indexPath: IndexPath)
}

// MARK: - Implementation
class TaskDetailRobotSelectionPresenter {
    private let dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol
    private let vc: TaskDetailRobotSelectionViewControllerProtocol
    /// TaskDetailのViewData
    var data: TaskDetailViewData
    private var cancellables: Set<AnyCancellable> = []
    private var displayRobots: [JobOrder_Domain.DataManageModel.Output.Robot]?
    var commands: [JobOrder_Domain.DataManageModel.Output.Command]?
    var task: JobOrder_Domain.DataManageModel.Output.Task?
    var robot: JobOrder_Domain.DataManageModel.Output.Robot?

    required init(dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: TaskDetailRobotSelectionViewControllerProtocol,
                  viewData: TaskDetailViewData
    ) {
        self.dataUseCase = dataUseCase
        self.vc = vc
        self.data = viewData
        observeRobots()
    }
}

// MARK: - Protocol Function
extension TaskDetailRobotSelectionPresenter: TaskDetailRobotSelectionPresenterProtocol {
    func viewWillAppear(taskId: String) {
        vc.changedProcessing(true)
        getCommands(taskId: taskId)
        getTask(taskId: taskId)
    }

    /// リストの行数
    var numberOfItems: Int {
        commands?.count ?? 0
    }

    /// Job名取得
    /// - Returns: Job名
    func jobName() -> String? {
        return task?.job.name
    }

    /// Robot名取得
    /// - Returns: Robot名
    func displayName(_ index: Int) -> String? {
        guard let robotId = commands?[index].robotId else { return nil }
        guard let name = dataUseCase.robots?.first(where: { $0.id == robotId })?.name else { return nil }
        return name
    }

    /// Robotのタイプ取得
    /// - Parameter index: 配列のIndex
    /// - Returns: Robotのタイプ名
    func type(_ index: Int) -> String? {
        guard let robotId = commands?[index].robotId else { return nil }
        guard let overview = dataUseCase.robots?.first(where: { $0.id == robotId })?.overview else { return nil }
        return overview
    }

    /// セルの選択
    /// - Parameter indexPath: インデックスパス
    func selectCell(indexPath: IndexPath) {
        data.taskId = commands?[indexPath.section].taskId
        data.robotId = commands?[indexPath.section].robotId
        vc.launchTaskDetail()
    }

    /// 更新時間取得
    /// - Parameters:
    ///   - textColor: テキストカラー
    ///   - font: フォント
    /// - Returns: 更新時間
    func updatedAt(textColor: UIColor, font: UIFont) -> NSAttributedString? {
        return string(date: toEpocTime(task?.updateTime), label: "", textColor: textColor, font: font)
    }

    /// 作成時間取得
    /// - Parameters:
    ///   - textColor: テキストカラー
    ///   - font: フォント
    /// - Returns: 作成時間
    func createdAt(textColor: UIColor, font: UIFont) -> NSAttributedString? {
        return string(date: toEpocTime(task?.createTime), label: "", textColor: textColor, font: font)
    }

    /// ステータス取得
    /// - Parameter index: 配列のIndex
    func status(_ index: Int) -> String? {
        return commands?[index].status
    }

    /// 成功数取得
    /// - Returns: 成功数
    func success(_ index: Int) -> Int? {
        return commands?[index].success
    }

    /// 失敗数取得
    /// - Returns: 失敗数
    func failure(_ index: Int) -> Int? {
        return commands?[index].fail
    }

    /// エラー数取得
    /// - Returns: エラー数
    func error(_ index: Int) -> Int? {
        return commands?[index].error
    }
    /// N/A数取得
    /// - Returns: N/A数
    func na(_ index: Int) -> Int? {
        let otherCount = (commands?[index].success ?? 0) + (commands?[index].fail ?? 0) + (commands?[index].error ?? 0)
        var naCount = (task?.exit.option.numberOfRuns ?? 0)

        if naCount != 0 {
            naCount = (task?.exit.option.numberOfRuns ?? 0) - otherCount
        }
        //TODO:現在APIから返ってくる値の整合性が取れていない（総数よりSuccess数の方が多い）のでマイナスの値にならないようにする
        if 0 > naCount {
            naCount = 0
        }
        return naCount
    }
    /// Robotの画像
    /// - Parameter completion: クロージャ
    func image(index: Int, _ completion: @escaping (Data?) -> Void) {
        guard let id = commands?[index].robotId else { return }

        dataUseCase.robotImage(id: id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                Logger.debug(target: self, "\(completion)")
                switch completion {
                case .finished: break
                case .failure(let error):
                    // TODO: エラーケース
                    Logger.error(target: self, "\(error.localizedDescription)")
                }
            }, receiveValue: { response in
                completion(response.data)
            }).store(in: &cancellables)
    }

    func tapCancelButton() {
        // vc.launchOrderEntry()
    }
}

// MARK: - Private Function
extension TaskDetailRobotSelectionPresenter {

    private func observeRobots() {
        dataUseCase.observeRobotData()
            .receive(on: DispatchQueue.main)
            .sink { response in
                // Logger.debug(target: self, "\(String(describing: response))")
            }.store(in: &cancellables)
    }

    func getCommands(taskId: String) {
        dataUseCase.commandsFromTask(taskId: taskId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(String(describing: response))")
                self.commands = response
            }).store(in: &cancellables)
    }

    func getTask(taskId: String) {
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
                self.task = response
                self.vc.viewReload()
                self.vc.reloadCollection()
            }).store(in: &cancellables)
    }

    func string(date: Date?, label: String, textColor: UIColor, font: UIFont) -> NSAttributedString? {
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(NSAttributedString(string: label, attributes: [
            .foregroundColor: textColor,
            .font: font
        ]))
        let queuedAt = toDateString(date)
        mutableAttributedString.append(NSAttributedString(string: queuedAt, attributes: [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 14.0)
        ]))
        return mutableAttributedString
    }

    func string(time: Int?, label: String, textColor: UIColor, font: UIFont) -> NSAttributedString? {
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(NSAttributedString(string: label, attributes: [
            .foregroundColor: textColor,
            .font: font
        ]))
        mutableAttributedString.append(NSAttributedString(string: String(time ?? 0), attributes: [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 14.0)
        ]))
        return mutableAttributedString
    }

    func toDateString(_ date: Int?) -> String {
        guard let date = date, date != 0 else { return "" }
        return toDateString(Date(timeIntervalSince1970: TimeInterval(date)))
    }

    func toDateString(_ date: Date?) -> String {
        guard let date = date, date.timeIntervalSince1970 != 0 else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        return formatter.string(from: date)
    }

    func toEpocTime(_ data: Int?) -> Date {
        return Date(timeIntervalSince1970: Double((data ?? 1000) / 1000))
    }
}
