//
//  RecognitionLibrarySelectionCollectionViewCell.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/02/19.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class WorkObjectLibraryCollectionViewCell: UICollectionViewCell, UICollectionViewCellWithAutoSizing {

    // MARK: - IBOutlet
    @IBOutlet private weak var actionImage: UIImageView!
    @IBOutlet private weak var displayNameLabel: UILabel!
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var checkmarkImage: UIImageView!
    @IBOutlet private weak var testButton: UIButton!

    // MARK: - Variable
    private var data: ActionEntryViewData!

    // MARK: - Constant
    static let identifier: String = "WorkObjectLibraryCollectionViewCell"

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

    func inject(data: ActionEntryViewData) {
        self.data = data
    }
}

// MARK: - Function
extension WorkObjectLibraryCollectionViewCell {

    func setRow(_ indexPath: IndexPath) {
        testButton?.tag = indexPath.row
        testButton?.setTitle(L10n.WorkObjectLibrarySelection.test, for: .normal)
        let library = ActionEntryViewData.WorkLibrary.allCases[indexPath.row]
        displayNameLabel?.text = library.name
        actionImage.image = library.image.image
    }
}
