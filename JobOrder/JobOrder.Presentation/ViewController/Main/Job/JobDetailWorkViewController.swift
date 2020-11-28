//
//  JobDetailWorkViewController.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/11/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit
import JobOrder_Utility

/// JobDetailWorkViewControllerProtocol
/// @mockable
protocol JobDetailWorkViewControllerProtocol: class {
    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error)
    /// テーブルを更新
    func reloadTable()
    /// テーブル行の更新
    /// - Parameters:
    ///   - dataset: 設定情報識別子
    ///   - at: 更新行
    func reloadRows(dataset: JobDetailWorkPresenter.Dataset, at: [IndexPath])
    /// TaskDetail画面へ遷移
    /// - Parameter taskId: Task ID
    func launchTaskDetail(taskId: String?, robotIds: [String]?)
}

class JobDetailWorkViewController: JobDetailContainerViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var taskTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var historyTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var seeAllButton: UIButton!

    // MARK: - Variable
    var presenter: JobDetailWorkPresenterProtocol!
    private var containerWithoutTableViewHeight: CGFloat = 0

    override func inject(viewData: MainViewData.Job) {
        super.inject(viewData: viewData)
        presenter = MainBuilder.JobDetailWork().build(vc: self, viewData: viewData)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()

        // 可変なテーブル以外の合計サイズを取得
        if let containerViewHeight = self.view.subviews.first?.frame.height {
            containerWithoutTableViewHeight = containerViewHeight - taskTableView.frame.height - historyTableView.frame.height
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // テーブルを含めたサイズを設定
        taskTableView.layoutIfNeeded()
        taskTableViewHeight.constant = taskTableView.contentSize.height
        historyTableView.layoutIfNeeded()
        historyTableViewHeight.constant = historyTableView.contentSize.height

        let height =
            containerWithoutTableViewHeight +
            taskTableView.contentSize.height +
            historyTableView.contentSize.height
        preferredContentSize.height = max(height, initialHeight)
    }
}

// MARK: - Action
extension JobDetailWorkViewController {

    @IBAction private func touchUpInsideSeeAll(_ sender: UIButton) {
        // TODO: See all
    }

}

// MARK: - Implement UITableViewDataSource, UITableViewDelegate
extension JobDetailWorkViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        let num = presenter.numberOfSections(in: dataset(by: tableView))
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
        let identifier =
            tableView.isEqual(taskTableView) ? JobDetailWorkTaskTableViewCell().identifier :
            tableView.isEqual(historyTableView) ? JobDetailWorkHistoryTableViewCell().identifier :
            ""
        let _cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let cell = _cell as? JobDetailWorkTableViewCell {
            cell.presenter = presenter
            cell.dataset = dataset(by: tableView)
            cell.setRow(indexPath)
        }
        return _cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.selectRow(in: dataset(by: tableView), indexPath: indexPath)
    }

}

extension JobDetailWorkViewController: JobDetailWorkViewControllerProtocol {

    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error) {
        presentAlert(error)
    }

    /// テーブルを更新
    func reloadTable() {
        taskTableView.reloadData()
        historyTableView.reloadData()
        viewDidLayoutSubviews()
        //self.view.setNeedsLayout()	// FIXME: こっちだとレイアウトが崩れる（アコーディオンも同じ？）
    }

    /// テーブル行の更新
    /// - Parameters:
    ///   - dataset: 設定情報識別子
    ///   - at: 更新行
    func reloadRows(dataset: JobDetailWorkPresenter.Dataset, at: [IndexPath]) {
        guard !at.isEmpty else { return }

        switch dataset {
        case .task:
            taskTableView.reloadRows(at: at, with: .none)
        case .history:
            historyTableView.reloadRows(at: at, with: .none)
        }
    }

    /// TaskDetail画面へ遷移
    /// - Parameter jobId: Job ID
    func launchTaskDetail(taskId: String?, robotIds: [String]?) {
        Logger.debug(target: self, "taskId: \(taskId ?? "nil"), robotIds: \(robotIds?.joined(separator: ",") ?? "nil")")

        guard let taskId = taskId else { return }
        guard let robotIds = robotIds else { return }
        //robotIdsが一つしか格納されていないのであればRobotSelection画面を飛ばす
        if robotIds.count == 1 {
            guard let jobid = presenter.data.id else { return }
            let navigationController = StoryboardScene.TaskDetail.initialScene.instantiate()
            if let vc = navigationController.topViewController as? TaskDetailViewController {
                vc.inject(jobId: jobid, robotId: robotIds[0])
                self.present(navigationController, animated: true, completion: nil)
            }
        } else {
            let sb = StoryboardScene.TaskDetail.initialScene.instantiate()
            if let vc = sb.storyboard?.instantiateViewController(identifier: "RobotSelect") as? TaskDetailRobotSelectionViewController {
                vc.inject(taskId: taskId)
                let navController = UINavigationController(rootViewController: vc)
                // Creating a navigation controller with vc at the root of the navigation stack.
                self.present(navController, animated: true, completion: nil)
            }
        }
    }

}

// MARK: - Private Function
extension JobDetailWorkViewController {

    private func dataset(by tableView: UITableView) -> JobDetailWorkPresenter.Dataset {
        tableView.isEqual(self.taskTableView) ? .task : .history
    }

}
