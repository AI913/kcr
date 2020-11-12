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
    /// OrderEntry画面へ遷移
    func launchOrderEntry()
    /// TaskDetail画面へ遷移
    /// - Parameter jobId: Job ID
    func launchTaskDetail(jobId: String?, robotId: String?)
}

class RobotDetailWorkViewController: RobotDetailContainerViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var assignedTaskLabel: UILabel!
    @IBOutlet weak var runHistoryLabel: UILabel!
    @IBOutlet weak var orderButton: UIButton!
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

// MARK: - Action
extension RobotDetailWorkViewController {

    @IBAction private func touchUpInsideOrderButton(_ sender: UIButton) {
        presenter?.tapOrderEntryButton()
    }
}

// MARK: - Implement UITableViewDataSource, UITableViewDelegate
extension RobotDetailWorkViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        let num = presenter?.numberOfSections() ?? 0
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
        cell.setRow(indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.selectRow(indexPath: indexPath)
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

    func launchOrderEntry() {
        let navigationController = StoryboardScene.OrderEntry.initialScene.instantiate()
        if let vc = navigationController.topViewController as? OrderEntryJobSelectionViewController {
            vc.inject(jobId: nil, robotId: presenter?.data.id)
            self.present(navigationController, animated: true, completion: nil)
        }
    }

    func launchTaskDetail(jobId: String?, robotId: String?) {
        guard let jobId = jobId else { return }
        guard let robotId = robotId else { return }
        let navigationController = StoryboardScene.TaskDetail.initialScene.instantiate()
        if let vc = navigationController.topViewController as? TaskDetailViewController {
            vc.inject(jobId: jobId, robotId: robotId)
            self.present(navigationController, animated: true, completion: nil)
        }
    }
}

// MARK: - Private Function
extension RobotDetailWorkViewController {

    //        // ****** API GET robot/{thingName}/execution/list ******
    //
    //        RobotAPI.getExecutionList(data.thingName, limit: 5, nextToken: nil) { (thingName, param, result, error) in
    //
    //            DispatchQueue.main.async {
    //                if let error = error {
    //                    self.presentSingleAlert(error)
    //                    return
    //                }
    //
    //                guard let result = result else {
    //                    // TODO show message
    //                    return
    //                }
    //
    //                self.runHistoryMaster = result.data.reduce(into: [String : RunHistory]()) {
    //                    $0[$1.awsJobId] = RunHistory($1)
    //                }
    //            }
    //        }
    //    }

    //    private func sortRunHistory() {
    //        self.runHistoryDisplay = self.runHistoryMaster.values.sorted { $0.lastUpdateAt > $1.lastUpdateAt }
    //    }
    //
    //    private func configureRunHistoryView() {
    //
    //        self.runHistoryViewContainer.arrangedSubviews.forEach {
    //
    //            guard let view = $0 as? RunHistoryView, let data = view.data else {
    //                return
    //            }
    //
    //            guard (self.runHistoryDisplay.filter { $0 == data }).count == 0 else {
    //                return
    //            }
    //
    //            self.runHistoryViewContainer.removeArrangedSubview(view)
    //            view.removeFromSuperview()
    //        }
    //
    //        self.runHistoryDisplay.forEach {
    //
    //            if let view = self.findHistoryDisplayView($0) {
    //                view.data = $0
    //                return
    //            }
    //
    //            let view = RunHistoryView()
    //            view.data = $0
    //            view.delegate = self
    //
    //            self.runHistoryViewContainer.addArrangedSubview(view)
    //        }
    //
    //        self.runHistoryNoAnswerLabel.isHidden = self.runHistoryDisplay.count > 0
    //    }
    //
    //    private func findHistoryDisplayView(_ data: RunHistory) -> RunHistoryView? {
    //        for subview in self.runHistoryViewContainer.arrangedSubviews {
    //            guard let view = subview as? RunHistoryView, view.data == data else {
    //                continue
    //            }
    //            return view
    //        }
    //        return nil
    //    }
}
