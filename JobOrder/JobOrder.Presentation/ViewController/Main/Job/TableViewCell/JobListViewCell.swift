//
//  JobListViewCell.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class JobListViewCell: UITableViewCell {

    // MARK: - IBOutlet
    @IBOutlet private weak var displayNameLabel: UILabel!
    @IBOutlet private weak var requirementLabel: UILabel!

    // MARK: - Constant
    static let identifier: String = "JobListViewCell"

    // MARK: - Variable
    private var presenter: JobListPresenterProtocol!

    func inject(presenter: JobListPresenterProtocol) {
        self.presenter = presenter
    }

    // MARK: - Function
    func setRow(_ indexPath: IndexPath) {
        displayNameLabel?.text = toLabelText(presenter?.displayName(indexPath.row))
        requirementLabel?.text = toLabelText(presenter?.requirementText(indexPath.row))
    }
}
