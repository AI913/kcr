//
//  JobEntryGeneralInformationFormRobotCollectionViewCell.swift
//  JobOrder.Presentation
//
//  Created by frontarc on 2021/01/19.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import UIKit

class JobEntryRobotSelectionRobotCollectionViewCell: UICollectionViewCell, UICollectionViewCellWithAutoSizing {

    // MARK: - IBOutlet
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var typeAndClassificationLabel: UILabel!
    @IBOutlet weak var checkmarkImage: UIImageView!
    
    // MARK: - Constant
    static let identifier: String = "JobEntryRobotSelectionRobotCollectionViewCell"

    // MARK: - Variable
    private var presenter: JobEntryGeneralInformationFormPresenter!

    func inject(presenter: JobEntryGeneralInformationFormPresenter) {
        self.presenter = presenter
    }

    // MARK: - Override function (view lifecycle)
    override func awakeFromNib() {
        super.awakeFromNib()
        let selectedBackgroundView = UIView(frame: self.bounds)
        selectedBackgroundView.backgroundColor = .black
        selectedBackgroundView.alpha = self.alpha * 0.5
        self.selectedBackgroundView = selectedBackgroundView
    }

    // MARK: - Override function
    override var isHighlighted: Bool {
        didSet {}
    }

    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                checkmarkImage.image = UIImage(systemName: "checkmark")
            } else {
                checkmarkImage.image = .none
            }
        }
    }

    func setItem(_ indexPath: IndexPath) {
        displayNameLabel?.text = toLabelText(presenter?.displayName(indexPath.row))
        typeAndClassificationLabel?.text = toLabelText(presenter?.type(indexPath.row))
    }
}
