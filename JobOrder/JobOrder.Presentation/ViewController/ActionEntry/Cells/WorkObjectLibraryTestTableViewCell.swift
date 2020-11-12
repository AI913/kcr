//
//  WorkObjectLibraryTestTableViewCell.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class WorkObjectLibraryTestTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    @IBOutlet private weak var displayNameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    // MARK: - Variable
    private var data: ActionEntryViewData!

    // MARK: - Constant
    static let identifier: String = "WorkObjectLibraryTestTableViewCell"

    func inject(data: ActionEntryViewData) {
        self.data = data
    }
}

// MARK: - Function
extension WorkObjectLibraryTestTableViewCell {

    func setRow(_ indexPath: IndexPath) {
        displayNameLabel?.text = data.works[indexPath.row].work.name
        subtitleLabel?.text = data.works[indexPath.row].work.parsent
    }

    func selectRow(_ indexPath: IndexPath) {
    }
}
