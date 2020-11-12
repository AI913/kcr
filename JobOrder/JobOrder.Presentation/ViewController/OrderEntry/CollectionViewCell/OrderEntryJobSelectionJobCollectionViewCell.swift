//
//  OrderEntryJobSelectionJobCollectionViewCell.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class OrderEntryJobSelectionJobCollectionViewCell: UICollectionViewCell, UICollectionViewCellWithAutoSizing {

    // MARK: - IBOutlet
    @IBOutlet private weak var displayNameLabel: UILabel!
    @IBOutlet private weak var requirementLabel: UILabel!
    @IBOutlet private weak var checkmarkImage: UIImageView!

    // MARK: - Constant
    static let identifier: String = "OrderEntryJobSelectionJobCollectionViewCell"

    // MARK: - Variable
    private var presenter: OrderEntryJobSelectionPresenterProtocol!

    func inject(presenter: OrderEntryJobSelectionPresenterProtocol) {
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
                checkmarkImage?.image = UIImage(systemName: "checkmark")
            } else {
                checkmarkImage?.image = .none
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let selectedBackgroundView = self.selectedBackgroundView {
            selectedBackgroundView.frame = self.bounds
        }
    }

    func setItem(_ indexPath: IndexPath) {
        displayNameLabel?.text = toLabelText(presenter?.displayName(indexPath.row))
        requirementLabel?.text = toLabelText(presenter?.requirementText(indexPath.row))
    }
}
