//
//  TaskDetailRunHistoryViewController.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/12/07.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit
import JobOrder_Utility

/// TaskDetailRunHistoryViewControllerProtocol
/// @mockable
protocol TaskDetailRunHistoryViewControllerProtocol: class {
    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error)
    /// テーブルを更新
    func reloadTable()
    /// テーブル行の更新
    /// - Parameters:
    ///   - at: 更新行
    func reloadRows(at: [IndexPath])
    /// TaskDetail TaskInformation画面へ遷移
    /// - Parameter jobID: job ID
    /// - Parameter robotId: robot ID
    func launchTaskDetailTaskInformation(jobId: String, robotId: String)
    /// TaskDetail RobotSelection画面へ遷移
    /// - Parameter taskId: task ID
    func launchTaskDetailRobotSelection(taskId: String)
}

class TaskDetailRunHistoryViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!

    // MARK: - Variable
    var jobData: MainViewData.Job?
    var robotData: MainViewData.Robot?
    var presenter: TaskDetailRunHistoryPresenterProtocol!

    func inject(jobData: MainViewData.Job) {
        self.jobData = jobData
        presenter = TaskDetailBuilder.TaskDetailRunHistory().build(vc: self, jobData: jobData)
    }

    func inject(robotData: MainViewData.Robot) {
        self.robotData = robotData
        presenter = TaskDetailBuilder.TaskDetailRunHistory().build(vc: self, robotData: robotData)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updatePagination()
    }

}

// MARK: - View Controller Event
extension TaskDetailRunHistoryViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch StoryboardSegue.TaskDetail(segue) {
        case .taskDetailRunHistoryCellToTaskInformation:
            guard let (jobId, robotId) = sender as? (String, String) else { return }
            Logger.debug(target: self, "jobId: \(jobId), robotId: \(robotId)")
            let vc = segue.destination as! TaskDetailTaskInformationViewController
            vc.inject(jobId: jobId, robotId: robotId)
        case .taskDetailRunHistoryCellToRobotSelection:
            guard let taskId = sender as? String else { return }
            Logger.debug(target: self, "taskId: \(taskId)")
            let vc = segue.destination as! TaskDetailRobotSelectionViewController
            vc.inject(taskId: taskId)
        default: break
        }
    }

}

// MARK: - Action
extension TaskDetailRunHistoryViewController {

    @IBAction private func touchUpInsidePrevButton(_ sender: UIButton) {
        blockPagination()
        presenter.viewPrevPage()
    }

    @IBAction private func touchUpInsideNextButton(_ sender: UIButton) {
        blockPagination()
        presenter.viewNextPage()
    }

    @IBAction private func selectorCancelBarButtonItem(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

// MARK: - Implement UITableViewDataSource, UITableViewDelegate
extension TaskDetailRunHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let num = presenter.numberOfSections()
        let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        noDataLabel.text = num == 0 ? "N/A" : ""
        noDataLabel.textColor = .systemGray
        noDataLabel.textAlignment = .center
        tableView.backgroundView = noDataLabel
        return num
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = presenter.browsing == .tasks ? TaskDetailRunHistoryTaskTableViewCell().identifier : TaskDetailRunHistoryCommandTableViewCell().identifier
        let _cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let cell = _cell as? TaskDetailRunHistoryTableViewCell {
            cell.inject(presenter: presenter)
            cell.setRow(indexPath)
        }
        return _cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.selectRow(indexPath: indexPath)
    }

}

extension TaskDetailRunHistoryViewController: TaskDetailRunHistoryViewControllerProtocol {

    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error) {
        presentAlert(error)
    }

    /// テーブルを更新
    func reloadTable() {
        tableView.reloadData()
        updatePagination()
    }

    /// テーブル行の更新
    /// - Parameters:
    ///   - at: 更新行
    func reloadRows(at: [IndexPath]) {
        guard !at.isEmpty else { return }
        tableView.reloadRows(at: at, with: .none)
    }

    /// TaskDetail TaskInformation画面へ遷移
    /// - Parameter jobId: job ID
    /// - Parameter robotId: robot ID
    func launchTaskDetailTaskInformation(jobId: String, robotId: String) {
        self.perform(segue: StoryboardSegue.TaskDetail.taskDetailRunHistoryCellToTaskInformation, sender: (jobId, robotId))
    }

    /// TaskDetail RobotSelection画面へ遷移
    /// - Parameter taskId: task ID
    func launchTaskDetailRobotSelection(taskId: String) {
        self.perform(segue: StoryboardSegue.TaskDetail.taskDetailRunHistoryCellToRobotSelection, sender: taskId)
    }

}

// MARK: - Private Function
extension TaskDetailRunHistoryViewController {

    private func updatePagination() {
        prevButton.isEnabled = presenter.canGoPrev()
        nextButton.isEnabled = presenter.canGoNext()
        pageLabel.text = presenter.pageText()
    }

    private func blockPagination() {
        prevButton.isEnabled = false
        nextButton.isEnabled = false
    }
}
