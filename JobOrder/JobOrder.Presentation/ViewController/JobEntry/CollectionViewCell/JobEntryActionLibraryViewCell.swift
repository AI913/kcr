//
//  JobEntryActionLibraryViewCell.swift
//  JobOrder.Presentation
//
//  Created by Frontarc on 2021/02/02.
//

import UIKit

class JobEntryActionLibraryViewCell: UICollectionViewCell, UICollectionViewCellWithAutoSizing {

    // MARK: - IBOutlet
    @IBOutlet weak var actionLibraryImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    // MARK: - Constant
    static let identifier: String = "ActionLibraryViewCell"

    // MARK: - Variable
    private var presenter: JobEntryActionLibraryPresenterProtocol!

    func inject(presenter: JobEntryActionLibraryPresenterProtocol) {
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
    override func layoutSubviews() {
        super.layoutSubviews()
        if let selectedBackgroundView = self.selectedBackgroundView {
            selectedBackgroundView.frame = self.bounds
        }
    }

    func setItem(_ indexPath: IndexPath) {
//        infoButton.setNilValueForKey(toLabelText(presenter?.displayName(indexPath.row)))
        infoButton.tag = indexPath.row
        actionLibraryImage.image = UIImage(systemName: "checkmark")
        // actionLibraryImage.image = UIImage(named: presenter?.actionLibraryImagePath(indexPath.row) ?? "")
        nameLabel?.text = toLabelText(presenter?.displayName(indexPath.row))
        versionLabel?.text = toLabelText(presenter?.version(indexPath.row))
    }
}
