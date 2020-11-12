//
//  OrderEntryRobotSelectionRobotCollectionViewCell.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class OrderEntryRobotSelectionRobotCollectionViewCell: UICollectionViewCell, UICollectionViewCellWithAutoSizing {

    // MARK: - IBOutlet
    @IBOutlet private weak var displayNameLabel: UILabel!
    @IBOutlet private weak var typeAndClassificationLabel: UILabel!
    @IBOutlet private weak var checkmarkImage: UIImageView!

    // MARK: - Constant
    static let identifier: String = "OrderEntryRobotSelectionRobotCollectionViewCell"

    // MARK: - Variable
    private var presenter: OrderEntryRobotSelectionPresenterProtocol!

    func inject(presenter: OrderEntryRobotSelectionPresenterProtocol) {
        self.presenter = presenter
    }

    // MARK: - Override function (view lifecycle)
    override func awakeFromNib() {
        super.awakeFromNib()
        let selectedBackgroundView = UIView(frame: self.bounds)
        selectedBackgroundView.backgroundColor = .secondarySystemFill
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
