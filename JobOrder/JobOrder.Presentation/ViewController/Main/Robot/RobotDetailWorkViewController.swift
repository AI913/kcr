//
//  RobotDetailWorkViewController.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/20.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

/// RobotDetailWorkViewControllerProtocol
/// @mockable
protocol RobotDetailWorkViewControllerProtocol: class {
    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error)
    /// テーブルを更新
    func reloadTable()
    /// テーブル行の更新
    /// - Parameters:
    ///   - dataset: 設定情報識別子
    ///   - at: 更新行
    func reloadRows(dataset: RobotDetailWorkPresenter.Dataset)
    //    func reloadRows(dataset: RobotDetailWorkPresenter.Dataset, at: [IndexPath])
    /// TaskDetail画面へ遷移
    /// - Parameter jobId: Job ID
    func launchTaskDetail(jobId: String?, robotId: String?)
}

class RobotDetailWorkViewController: RobotDetailContainerViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var assignedTaskLabel: UILabel!
    @IBOutlet weak var runHistoryLabel: UILabel!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var taskTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var historyTableViewHeight: NSLayoutConstraint!

    // MARK: - Variable
    var presenter: RobotDetailWorkPresenterProtocol!
    private var containerWithoutTableViewHeight: CGFloat = 0

    override func inject(viewData: MainViewData.Robot) {
        super.inject(viewData: viewData)
        presenter = MainBuilder.RobotDetailWork().build(vc: self, viewData: viewData)
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

// MARK: - View Controller Event
extension RobotDetailWorkViewController {

    @IBAction private func touchUpInsideSeeAllButton(_ sender: UIButton) {
        let navigationController = StoryboardScene.TaskDetail.taskDetailRunHistoryNavi.instantiate()
        if let vc = navigationController.topViewController as? TaskDetailRunHistoryViewController {
            vc.inject(robotData: viewData)
            self.present(navigationController, animated: true, completion: nil)
        }
    }

}

// MARK: - Implement UITableViewDataSource, UITableViewDelegate
extension RobotDetailWorkViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        let num = presenter?.numberOfSections(in: dataset(by: tableView)) ?? 0
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
            tableView.isEqual(taskTableView) ? RobotDetailWorkTaskTableViewCell().identifier :
            tableView.isEqual(historyTableView) ? RobotDetailWorkHistoryTableViewCell().identifier :
            ""
        let _cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        guard let cell = _cell as? RobotDetailWorkTableViewCell else {
            return _cell
        }
        cell.presenter = presenter
        cell.dataset = dataset(by: tableView)
        cell.setRow(indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.selectRow(in: dataset(by: tableView), indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension RobotDetailWorkViewController: RobotDetailWorkViewControllerProtocol {

    func showErrorAlert(_ error: Error) {
        presentAlert(error)
    }

    func reloadTable() {
        taskTableView.reloadData()
        historyTableView.reloadData()
        viewDidLayoutSubviews() // TODO: 別のAPIがないか要調査
    }

    /// テーブル行の更新
    /// - Parameters:
    ///   - dataset: 設定情報識別子
    ///   - at: 更新行
    func reloadRows(dataset: RobotDetailWorkPresenter.Dataset) {
        switch dataset {
        case .tasks:
            taskTableView.reloadData()
        case .history:
            historyTableView.reloadData()
        }
    }

    func launchTaskDetail(jobId: String?, robotId: String?) {
        guard let jobId = jobId else { return }
        guard let robotId = robotId else { return }
        let navigationController = StoryboardScene.TaskDetail.initialScene.instantiate()
        if let vc = navigationController.topViewController as? TaskDetailTaskInformationViewController {
            vc.inject(jobId: jobId, robotId: robotId)
            self.present(navigationController, animated: true, completion: nil)
        }
    }
}

// MARK: - Private Function
extension RobotDetailWorkViewController {

    private func dataset(by tableView: UITableView) -> RobotDetailWorkPresenter.Dataset {
        tableView.isEqual(self.taskTableView) ? .tasks : .history
    }

}
