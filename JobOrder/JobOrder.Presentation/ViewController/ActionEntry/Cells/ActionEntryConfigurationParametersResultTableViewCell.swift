//
//  RobotListViewCell.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/07.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class ActionEntryConfigurationParametersResultTableViewCell: UITableViewCell {

    // MARK: - IBOutlet

    @IBOutlet weak var parameterDetailButton: UIButton!
    @IBOutlet weak var parameterNameLabel: UILabel!
    @IBOutlet weak var parameterValueLabel: UILabel!

    // MARK: - Constant
    static let identifier: String = "ActionParaViewCell"

    // MARK: - Variable
    private var presenter: ActionEntryConfigurationParametersResultPresenterProtocol!

    func inject(presenter: ActionEntryConfigurationParametersResultPresenterProtocol) {
        self.presenter = presenter
    }

    // MARK: - Function
    func setRow(_ indexPath: IndexPath) {

        let mutableAttributedString = NSMutableAttributedString()

        parameterNameLabel.text = "WorkBench"
        parameterValueLabel.text = "Placeholder"

    }
}
