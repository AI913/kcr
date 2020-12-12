//
//  TaskDetailRunHistoryTaskTableViewCell.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/12/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class TaskDetailRunHistoryTaskTableViewCell: TaskDetailRunHistoryTableViewCell {

    // MARK: - IBOutlet
    @IBOutlet private weak var orderValueLabel: UILabel!
    @IBOutlet private weak var assignValueLabel: UILabel!
    @IBOutlet private weak var statusImageView: UIImageView!

    // MARK: - Variable
    override var identifier: String {
        get { return "TaskDetailRunHistoryTaskTableViewCell" }
        set { super.identifier = newValue }
    }

    // MARK: - Function
    override func setRow(_ indexPath: IndexPath) {
        orderValueLabel.text = presenter.orderName(index: indexPath.section)
        assignValueLabel.text = presenter.assignName(index: indexPath.section)

        let key = presenter.taskStatus(index: indexPath.section)
        let status = MainViewData.TaskExecution.Status(key ?? "unknown")
        statusImageView.image = status.imageName
        statusImageView.tintColor = status.imageColor
    }

}
