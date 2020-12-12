//
//  RobotDetailWorkTaskTableViewCell.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/22.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class RobotDetailWorkTaskTableViewCell: RobotDetailWorkTableViewCell {

    // MARK: - IBOutlet
    @IBOutlet private weak var identifierValueLabel: UILabel!
    @IBOutlet private weak var queuedAtValueLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!

    // MARK: - Variable
    override var identifier: String {
        get { return "RobotDetailWorkTaskTableViewCell" }
        set { super.identifier = newValue }
    }

    // MARK: - Function
    override func setRow(_ indexPath: IndexPath) {
        identifierValueLabel.text = presenter?.jobName(indexPath.section)
        queuedAtValueLabel.attributedText = presenter?.queuedAt(in: dataset, indexPath.section, textColor: queuedAtValueLabel.textColor, font: queuedAtValueLabel.font)
        if let presenter = presenter {
            let status: MainViewData.TaskExecution.Status = .init(presenter.status(in: dataset, indexPath.section))
            statusImageView.image = status.imageName.withRenderingMode(.alwaysTemplate)
            statusImageView.tintColor = status.imageColor
        }
    }
}
