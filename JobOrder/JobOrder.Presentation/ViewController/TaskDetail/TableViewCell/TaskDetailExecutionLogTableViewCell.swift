//
//  TaskDetailExecutionLogTableViewCell.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/12/15.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class TaskDetailExecutionLogTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    @IBOutlet private weak var executedAtValueLabel: UILabel!
    @IBOutlet private weak var statusImageView: UIImageView!

    // MARK: - Variable
    var identifier = "TaskDetailExecutionLogTableViewCell"
    var presenter: TaskDetailExecutionLogPresenterProtocol!

    func inject(presenter: TaskDetailExecutionLogPresenterProtocol) {
        self.presenter = presenter
    }

    // MARK: - Function
    func setRow(_ indexPath: IndexPath) {
        executedAtValueLabel.text = presenter.executedAt(index: indexPath.section)

        let key = presenter.result(index: indexPath.section)
        let status = MainViewData.TaskExecution.Result(key ?? "unknown")
        statusImageView.image = status.imageName
        statusImageView.tintColor = status.imageColor
    }

}
