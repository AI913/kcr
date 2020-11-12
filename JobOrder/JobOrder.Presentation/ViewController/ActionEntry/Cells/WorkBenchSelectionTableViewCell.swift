//
//  WorkBenchSelectionTableViewCell.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class WorkBenchSelectionTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    @IBOutlet weak var displayNameLabel: UILabel!

    // MARK: - Variable
    private var data: ActionEntryViewData!

    // MARK: - Constant
    static let identifier: String = "WorkBenchSelectionTableViewCell"

    func inject(data: ActionEntryViewData) {
        self.data = data
    }
}

// MARK: - Function
extension WorkBenchSelectionTableViewCell {

    func setRow(_ indexPath: IndexPath) {
        displayNameLabel?.text = data?.destTray[indexPath.row].name
    }
}
