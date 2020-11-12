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
    func numberOfSections() -> Int
    /// セルを選択
    /// - Parameter index: 配列のIndex
    func selectRow(indexPath: IndexPath)
    /// Task名取得
    /// - Parameter index: 配列のIndex
    func taskName(_ index: Int) -> String?
    /// Task ID取得
    /// - Parameter index: 配列のIndex
    func identifier(_ index: Int) -> String?
    /// Task登録時刻取得
    /// - Parameter index: 配列のIndex
    /// - Parameter textColor: テキストカラー
    /// - Parameter font: フォント
    func queuedAt(_ index: Int, textColor: UIColor, font: UIFont) -> NSAttributedString?

    /// 実行結果取得
    /// - Parameter index: 配列のIndex
    func resultInfo(_ index: Int) -> String?
    /// コマンドのステータス取得
    /// - Parameter index: 配列のIndex
    func status(_ index: Int) -> String

    /// OrderEntryボタンをタップ
    /// - Parameter index: 配列のIndex
    func tapOrderEntryButton()
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
    /// 実行コマンドリスト
    var commands: [DataManageModel.Output.Command]?

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
        getTaskExecutions(id: id)
    }

    /// セクション数取得
    /// - Returns: セクション数
    func numberOfSections() -> Int {
        return self.commands?.count ?? 0
    }

    /// セルを選択
    /// - Parameter index: 配列のIndex
    func selectRow(indexPath: IndexPath) {
        let taskId = commands?[indexPath.section].taskId
        let robotId = commands?[indexPath.section].robotId
        vc.launchTaskDetail(jobId: taskId, robotId: robotId)
    }

    /// Task名取得
    /// - Parameter index: 配列のIndex
    /// - Returns: Task名
    func taskName(_ index: Int) -> String? {
        let date = toEpocTime(commands?[index].createTime)
        return "Created at : " + toDateString(date)
    }

    /// Task ID取得
    /// - Parameter index: 配列のIndex
    /// - Returns: Task ID
    func identifier(_ index: Int) -> String? {
        return commands?[index].taskId
    }

    /// Task登録時刻取得
    /// - Parameter index: 配列のIndex
    /// - Parameter textColor: テキストカラー
    /// - Parameter font: フォント
    /// - Returns: Task登録時刻時刻
    func queuedAt(_ index: Int, textColor: UIColor, font: UIFont) -> NSAttributedString? {
        let date = Date(timeIntervalSince1970: Double((commands?[index].createTime ?? 1000) / 1000))
        return string(date: date, label: "Created at : ", textColor: textColor, font: font)
    }

    /// 実行結果取得
    /// - Parameter index: 配列のIndex
    /// - Returns: 実行結果
    func resultInfo(_ index: Int) -> String? {
        return commands?[index].resultInfo
    }

    /// 状態取得
    /// - Parameter index: 配列のindex
    /// - Returns: 状態
    func status(_ index: Int) -> String {
        return commands?[index].status ?? ""
    }

    /// OrderEntryボタンをタップ
    func tapOrderEntryButton() {
        vc.launchOrderEntry()
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

    func getTaskExecutions(id: String) {
        guard let id = data.id else { return }
        dataUseCase.commandFromRobot(id: id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(String(describing: response))")
                self.sortTaskExecutions(response)
                self.vc.reloadTable()
            }).store(in: &cancellables)
    }

    private func getRunHistories(id: String) {}

    private func sortTaskExecutions(_ executions: [DataManageModel.Output.Command]?) {
        commands = executions?.sorted {
            toEpocTime($0.createTime) < toEpocTime($1.createTime)
        }
    }

    private func string(date: Date?, label: String, textColor: UIColor, font: UIFont) -> NSAttributedString? {
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

    private func toDateString(_ date: Int?) -> String {
        guard let date = date, date != 0 else { return "" }
        return toDateString(Date(timeIntervalSince1970: TimeInterval(date)))
    }

    private func toDateString(_ date: Date?) -> String {
        guard let date = date, date.timeIntervalSince1970 != 0 else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        return formatter.string(from: date)
    }

    private func toEpocTime(_ data: Int?) -> Date {
        return Date(timeIntervalSince1970: Double((data ?? 1000) / 1000))
    }
}
