//
//  RobotDetailSystemDetailTableViewCell.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/11/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class RobotDetailSystemDetailTableViewCell: UITableViewCell {

    // MARK: - Variable
    var identifier = "RobotDetailSystemDetailTableViewCell"
    var presenter: RobotDetailSystemPresenterProtocol!
    var dataset: RobotDetailSystemPresenter.Dataset!

    // MARK: - IBOutlet
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var detailValueLabel: UILabel!

    // MARK: - Function
    func setRow(_ indexPath: IndexPath) {
        let (detail, value) = presenter.detail(in: dataset, indexPath: indexPath)
        detailLabel.text = detail
        detailValueLabel.text = value
    }
}
