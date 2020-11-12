//
//  ActionEntryActionLibraryCollectionViewCell.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/02/13.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class ActionEntryActionLibraryCollectionViewCell: UICollectionViewCell, UICollectionViewCellWithAutoSizing {

    // MARK: - IBOutlet
    @IBOutlet private weak var actionImage: UIImageView!
    @IBOutlet private weak var displayNameLabel: UILabel!
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var checkmarkImage: UIImageView!

    // MARK: - Constant
    static let identifier: String = "ActionEntryActionLibraryCollectionViewCell"

    // MARK: - Override function (view lifecycle)
    override func awakeFromNib() {
        super.awakeFromNib()

        let selectedBackgroundView = UIView(frame: self.bounds)
        selectedBackgroundView.backgroundColor = .secondarySystemFill
        selectedBackgroundView.alpha = self.alpha * 0.5
        self.selectedBackgroundView = selectedBackgroundView
    }

    override var isSelected: Bool {
        didSet {
            checkmarkImage?.image = self.isSelected ? UIImage(systemName: "checkmark") : .none
        }
    }
}

// MARK: - Function
extension ActionEntryActionLibraryCollectionViewCell {

    func setRow(_ indexPath: IndexPath) {
        let library = ActionEntryViewData.ActionLibrary.allCases[indexPath.row]
        displayNameLabel?.text = library.name
        actionImage?.image = UIImage(systemName: library.image, withConfiguration: UIImage.SymbolConfiguration(weight: .thin))
    }
}
