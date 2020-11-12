//
//  WorkBenchEntryTableViewCell.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class WorkBenchEntryTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    @IBOutlet private weak var checkMark: UIImageView!
    @IBOutlet private weak var displayNameLabel: UILabel!

    // MARK: - Variable
    private var data: ActionEntryViewData!

    // MARK: - Constant
    static let identifier: String = "WorkBenchEntryTableViewCell"

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.checkMark?.image = selected ?
            UIImage(systemName: "checkmark.circle.fill") :
            UIImage(systemName: "circle")
    }

    func inject(data: ActionEntryViewData) {
        self.data = data
    }
}

// MARK: - Function
extension WorkBenchEntryTableViewCell {

    func setRow(_ indexPath: IndexPath) {
        displayNameLabel?.text = ActionEntryViewData.Tray(index: indexPath.row).name
    }

    func selectRow(_ indexPath: IndexPath) {
    }
}
