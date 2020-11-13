//
//  RobotDetailSystemDetailTableViewHeader.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/11/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class RobotDetailSystemDetailTableViewHeader: UITableViewHeaderFooterView {

    // MARK: - Variable
    var identifier = "RobotDetailSystemDetailTableViewHeader"
    var presenter: RobotDetailSystemPresenterProtocol!
    var dataset: RobotDetailSystemPresenter.Dataset!
    var section: Int!

    // MARK: - IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var titleValueLabel: UILabel!
    @IBOutlet private weak var extendedLabel: UILabel!

    // MARK: - Private Variable
    private var tapable: Bool = false

    // MARK: - Function
    override func awakeFromNib() {
        super.awakeFromNib()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RobotDetailSystemDetailTableViewHeader.onTap(_:)))
        addGestureRecognizer(tapGesture)
    }

    func setRow(_ section: Int, accessory: String? = nil, tapable: Bool = false) {
        let (title, value) = presenter.title(in: dataset, section: section)

        titleLabel.text = title

        if let value = value {
            titleValueLabel.text = value
            titleValueLabel.isHidden = false
        } else {
            titleValueLabel.isHidden = true
        }

        if let accessory = accessory {
            extendedLabel.isHidden = false
            extendedLabel.text = accessory
        } else {
            extendedLabel.isHidden = true
        }

        self.section = section
        self.tapable = tapable
    }

    @objc
    func onTap(_ sender: UITapGestureRecognizer) {
        if tapable {
            presenter?.tapHeader(in: dataset, section: section)
        }
    }
}
