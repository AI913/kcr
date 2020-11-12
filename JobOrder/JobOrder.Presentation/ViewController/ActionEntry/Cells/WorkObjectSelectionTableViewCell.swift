//
//  WorkObjectSelectionTableViewCell.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class WorkObjectSelectionTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    @IBOutlet private weak var checkMark: UIImageView!
    @IBOutlet private weak var displayNameLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    // MARK: - Variable
    private var data: ActionEntryViewData!

    // MARK: - Constant
    static let identifier: String = "WorkObjectSelectionTableViewCell"

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
extension WorkObjectSelectionTableViewCell {

    func setRow(_ indexPath: IndexPath) {
        displayNameLabel?.text = data.works[indexPath.row].work.name
        subtitleLabel?.text = data.works[indexPath.row].tray?.name
        subtitleLabel?.isHidden = data.works[indexPath.row].tray == nil
    }

    func selectRow(_ indexPath: IndexPath) {
    }
}
