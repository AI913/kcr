//
//  TaskDetailExecutionLogViewController.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/12/15.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit
import JobOrder_Utility

/// TaskDetailExecutionLogViewControllerProtocol
/// @mockable
protocol TaskDetailExecutionLogViewControllerProtocol: class {
    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error)
    /// テーブルを更新
    func reloadTable()
    /// Robot名を更新
    /// - Parameter name: Robot名
    func setRobot(name: String?)
    /// Job名を更新
    /// - Parameter name: Job名
    func setJob(name: String?)
}

class TaskDetailExecutionLogViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var robotLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!

    // MARK: - Variable
    var presenter: TaskDetailExecutionLogPresenterProtocol!

    func inject(viewData: TaskDetailViewData) {
        presenter = TaskDetailBuilder.TaskDetailExecutionLog().build(vc: self, viewData: viewData)
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

// MARK: - Action
extension TaskDetailExecutionLogViewController {

    @IBAction private func touchUpInsidePrevButton(_ sender: UIButton) {
        blockPagination()
        presenter.viewPrevPage()
    }

    @IBAction private func touchUpInsideNextButton(_ sender: UIButton) {
        blockPagination()
        presenter.viewNextPage()
    }

}

// MARK: - Implement UITableViewDataSource, UITableViewDelegate
extension TaskDetailExecutionLogViewController: UITableViewDelegate, UITableViewDataSource {

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
        let identifier = TaskDetailExecutionLogTableViewCell().identifier
        let _cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let cell = _cell as? TaskDetailExecutionLogTableViewCell {
            cell.inject(presenter: presenter)
            cell.setRow(indexPath)
        }
        return _cell
    }

}

extension TaskDetailExecutionLogViewController: TaskDetailExecutionLogViewControllerProtocol {

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

    /// Robot名を更新
    /// - Parameter name: Robot名
    func setRobot(name: String?) {
        robotLabel.text = name
    }

    /// Job名を更新
    /// - Parameter name: Job名
    func setJob(name: String?) {
        jobLabel.text = name
    }

}

// MARK: - Private Function
extension TaskDetailExecutionLogViewController {

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
