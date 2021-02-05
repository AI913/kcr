//
//  TaskDetailPresenter.swift
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
/// @mockable
public protocol TaskDetailTaskInformationPresenterProtocol {
    /// 起動時
    /// - Parameters:
    ///   - taskId: TaskID
    ///   - robotId: RobotID
    func viewWillAppear(taskId: String, robotId: String)
    /// Job名取得
    func jobName() -> String?
    /// Robot名取得
    func RobotName() -> String?
    /// 更新時間取得
    /// - Parameters:
    ///   - textColor: テキストカラー
    ///   - font: フォント
    func updatedAt(textColor: UIColor, font: UIFont) -> NSAttributedString?
    /// 作成時間取得
    /// - Parameters:
    ///   - textColor: テキストカラー
    ///   - font: フォント
    func createdAt(textColor: UIColor, font: UIFont) -> NSAttributedString?
    /// 開始時間取得
    /// - Parameters:
    ///   - textColor: テキストカラー
    ///   - font: フォント
    func startedAt(textColor: UIColor, font: UIFont) -> NSAttributedString?
    /// 完了時間取得
    /// - Parameters:
    ///   - textColor: テキストカラー
    ///   - font: フォント
    func exitedAt(textColor: UIColor, font: UIFont) -> NSAttributedString?
    /// 経過時間取得
    /// - Parameters:
    ///   - textColor: テキストカラー
    ///   - font: フォント
    func duration(textColor: UIColor, font: UIFont) -> NSAttributedString?
    /// ステータス取得
    func status() -> String?
    /// 成功数取得
    func success() -> Int?
    /// 失敗数取得
    func failure() -> Int?
    /// エラー数取得
    func error() -> Int?
    /// N/A数取得
    func na() -> Int?
    /// N/A数取得
    func remarks() -> String?

    func tapOrderEntryButton()

    //    /// セルを選択
    //    /// - Parameter index: 配列のIndex
    //    func selectCell(indexPath: IndexPath)

}

// MARK: - Implementation
class TaskDetailTaskInformationPresenter {
    private let dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol
    private let vc: TaskDetailViewControllerProtocol
    private var cancellables: Set<AnyCancellable> = []
    var command: JobOrder_Domain.DataManageModel.Output.Command?
    var task: JobOrder_Domain.DataManageModel.Output.Task?
    var robot: JobOrder_Domain.DataManageModel.Output.Robot?
    var job: JobOrder_Domain.DataManageModel.Output.Job?

    required init(dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: TaskDetailViewControllerProtocol) {
        self.dataUseCase = dataUseCase
        self.vc = vc
        observeRobots()
    }
}

// MARK: - Protocol Function
extension TaskDetailTaskInformationPresenter: TaskDetailTaskInformationPresenterProtocol {
    /// 起動時
    /// - Parameters:
    ///   - taskId: TaskID
    ///   - robotId: RobotID
    func viewWillAppear(taskId: String, robotId: String) {
        vc.changedProcessing(true)
        getCommandAndTask(taskId: taskId, robotId: robotId)
    }
    /// Job名取得
    /// - Returns: Job名
    func jobName() -> String? {
        return task?.job.name
    }

    /// Robot名取得
    /// - Returns: Robot名
    func RobotName() -> String? {
        return command?.robot?.name
    }

    /// 更新時間取得
    /// - Parameters:
    ///   - textColor: テキストカラー
    ///   - font: フォント
    /// - Returns: 更新時間
    func updatedAt(textColor: UIColor, font: UIFont) -> NSAttributedString? {
        return string(date: command?.updateTime.toEpocTime, label: "", textColor: textColor, font: font)
    }

    /// 作成時間取得
    /// - Parameters:
    ///   - textColor: テキストカラー
    ///   - font: フォント
    /// - Returns: 作成時間
    func createdAt(textColor: UIColor, font: UIFont) -> NSAttributedString? {
        return string(date: command?.createTime.toEpocTime, label: "", textColor: textColor, font: font)
    }
    /// 開始時間取得
    /// - Parameters:
    ///   - textColor: テキストカラー
    ///   - font: フォント
    /// - Returns: 開始時間
    func startedAt(textColor: UIColor, font: UIFont) -> NSAttributedString? {
        return string(date: command?.started?.toEpocTime, label: "", textColor: textColor, font: font)
    }
    /// 完了時間取得
    /// - Parameters:
    ///   - textColor: テキストカラー
    ///   - font: フォント
    /// - Returns: 完了時間
    func exitedAt(textColor: UIColor, font: UIFont) -> NSAttributedString? {
        return string(date: command?.exited?.toEpocTime, label: "", textColor: textColor, font: font)
    }
    /// 経過時間取得
    /// - Parameters:
    ///   - textColor: テキストカラー
    ///   - font: フォント
    /// - Returns: 経過時間
    func duration(textColor: UIColor, font: UIFont) -> NSAttributedString? {
        return string(time: command?.execDuration, label: "", textColor: textColor, font: font)
    }

    /// ステータス取得
    /// - Returns: ステータス
    func status() -> String? {
        return command?.status
    }

    /// 成功数取得
    /// - Returns: 成功数
    func success() -> Int? {
        return command?.success
    }

    /// 失敗数取得
    /// - Returns: 失敗数
    func failure() -> Int? {
        return command?.fail
    }

    /// エラー数取得
    /// - Returns: エラー数
    func error() -> Int? {
        return command?.error
    }
    /// N/A数取得
    /// - Returns: N/A数
    func na() -> Int? {
        guard let numberOfRuns = task?.exit.option.numberOfRuns else { return nil }
        guard let command = command else { return numberOfRuns }
        let naCount = numberOfRuns - (command.success + command.fail + command.error)
        guard naCount >= 1 else { return nil }
        return naCount
    }

    /// 備考取得
    /// - Parameter id: RobotID
    /// - Returns: 備考
    func remarks() -> String? {
        return robot?.remarks
    }

    func tapOrderEntryButton() {
        // vc.launchOrderEntry()
    }

    //    /// セルを選択
    //    /// - Parameter index: 配列のIndex
    //    func selectCell(indexPath: IndexPath) {
    //        let taskId = commands?[indexPath.section].taskId
    //        let robotId = commands?[indexPath.section].robotId
    //        vc.launchTaskDetail(jobId: taskId, robotId: robotId)
    //    }
}

// MARK: - Private Function
extension TaskDetailTaskInformationPresenter {

    private func observeRobots() {
        dataUseCase.observeRobotData()
            .receive(on: DispatchQueue.main)
            .sink { response in
                // Logger.debug(target: self, "\(String(describing: response))")
            }.store(in: &cancellables)
    }

    func getCommandAndTask(taskId: String, robotId: String) {
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
                self.command = response
                self.dataUseCase.task(taskId: taskId)
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
                    }).store(in: &self.cancellables)
            }).store(in: &cancellables)
    }

    func string(date: Date?, label: String, textColor: UIColor, font: UIFont) -> NSAttributedString? {
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

    func string(time: Int?, label: String, textColor: UIColor, font: UIFont) -> NSAttributedString? {
        let date = Date(timeIntervalSince1970: Double(time ?? 0))
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "HH:mm:ss"

        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(NSAttributedString(string: label, attributes: [
            .foregroundColor: textColor,
            .font: font
        ]))
        mutableAttributedString.append(NSAttributedString(string: formatter.string(from: date), attributes: [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 14.0)
        ]))
        return mutableAttributedString
    }

}
