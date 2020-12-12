//
//  TaskDetailRunHistoryCommandTableViewCell.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/12/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class TaskDetailRunHistoryCommandTableViewCell: TaskDetailRunHistoryTableViewCell {

    // MARK: - IBOutlet
    @IBOutlet private weak var jobNameValueLabel: UILabel!
    @IBOutlet private weak var createdAtValueLabel: UILabel!
    @IBOutlet private weak var resultInfoValueLabel: UILabel!
    @IBOutlet private weak var statusImageView: UIImageView!

    // MARK: - Variable
    override var identifier: String {
        get { return "TaskDetailRunHistoryCommandTableViewCell" }
        set { super.identifier = newValue }
    }

    // MARK: - Function
    override func setRow(_ indexPath: IndexPath) {
        jobNameValueLabel.text = presenter.jobName(index: indexPath.section)
        createdAtValueLabel.text = presenter.createdAt(index: indexPath.section)
        resultInfoValueLabel.text = presenter.result(index: indexPath.section)

        let key = presenter.commandStatus(index: indexPath.section)
        let status = MainViewData.TaskExecution.Status(key ?? "unknown")
        statusImageView.image = status.imageName
        statusImageView.tintColor = status.imageColor
    }

}
