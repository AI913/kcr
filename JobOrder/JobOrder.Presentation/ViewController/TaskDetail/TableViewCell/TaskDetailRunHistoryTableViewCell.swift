//
//  TaskDetailRunHistoryTableViewCell.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/12/07.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class TaskDetailRunHistoryTableViewCell: UITableViewCell {

    // MARK: - Variable
    var identifier = ""
    var presenter: TaskDetailRunHistoryPresenterProtocol!

    func inject(presenter: TaskDetailRunHistoryPresenterProtocol) {
        self.presenter = presenter
    }

    // MARK: - Function
    func setRow(_ indexPath: IndexPath) {}

}
