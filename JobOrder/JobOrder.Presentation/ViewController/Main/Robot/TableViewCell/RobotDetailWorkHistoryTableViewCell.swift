//
//  RobotDetailWorkHistoryTableViewCell.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/22.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class RobotDetailWorkHistoryTableViewCell: RobotDetailWorkTableViewCell {

    // MARK: - IBOutlet
    @IBOutlet private weak var statusImageView: UIImageView!
    @IBOutlet private weak var jobNameValueLabel: UILabel!
    @IBOutlet private weak var identifierValueLabel: UILabel!
    @IBOutlet private weak var lastUpdateAtValueLabel: UILabel!

    // MARK: - Variable
    override var identifier: String {
        get { return "RobotDetailWorkHistoryTableViewCell" }
        set { super.identifier = newValue }
    }

    // MARK: - Function
    override func setRow(_ indexPath: IndexPath) {
        jobNameValueLabel.text = presenter?.identifier(indexPath.section)
        identifierValueLabel.attributedText = presenter?.queuedAt(indexPath.section, textColor: lastUpdateAtValueLabel.textColor, font: lastUpdateAtValueLabel.font)
        lastUpdateAtValueLabel.text = presenter?.resultInfo(indexPath.section)
        if let presenter = presenter {
            let status: MainViewData.TaskExecution.Status = .init(presenter.status(indexPath.section))
            statusImageView.image = status.imageName.withRenderingMode(.alwaysTemplate)
            statusImageView.tintColor = status.imageColor
        }
    }
}
